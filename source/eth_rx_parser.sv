// eth_rx_parser.sv - Parses incoming Ethernet frames from mac_wrapper's byte-wide RX
// stream (rx_tdata/rx_tvalid/rx_tready/rx_tlast, one byte per beat, FCS already
// stripped/checked by the MAC).
//
// Behavior:
//   1. Reads destination MAC (6B), source MAC (6B), EtherType (2B).
//   2. Frames not addressed to local_mac or the broadcast address are discarded.
//   3. EtherType 0x0806 (ARP): the 28-byte ARP body is captured into a single
//      arp_struct beat. Only ARP REQUESTs whose target IP == local_ip are
//      forwarded via arp_tvalid/arp_tready; everything else (replies, requests
//      for other IPs) is silently discarded here.
//   4. EtherType 0x0800 (IPv4): the Ethernet header is stripped and the
//      remaining bytes (the IPv4 datagram, including its own header) are
//      passed through unmodified on ipv4_rx_tdata/tvalid/tready/tlast.
//   5. Anything else is discarded.
//
// Clocking: all logic is in a single clock domain, clk. rx_clk is expected to
// be tied to the same clock at the instantiation site (as endpoint.sv does by
// connecting both to user_clk out of mac_wrapper) and is not used internally;
// it is kept in the port list purely for interface/documentation symmetry
// with mac_wrapper's naming.
//
// Backpressure: if a previously-captured ARP request has not yet been accepted
// by arp_responder (arp_pending && !arp_tready), rx_tready is held low for the
// *next* frame's first byte, stalling the upstream RX FIFO rather than
// dropping the pending ARP request. ARP traffic is low rate, so this never
// meaningfully affects IPv4 throughput.
 
import ethernet_types_pkg::*;
 
module eth_rx_parser #(
    parameter logic [0:5][7:0] local_mac = {8'h00, 8'h0A, 8'h35, 8'h01, 8'h02, 8'h03},
    parameter logic [0:3][7:0] local_ip  = {8'h10, 8'h00, 8'h00, 8'h80}
) (
    input  logic clk,
    input  logic reset,
 
    // byte stream from mac_wrapper (same clock domain as clk - see header comment)
    input  logic        rx_tvalid,
    output logic        rx_tready,
    input  logic [7:0]  rx_tdata,
    input  logic        rx_tlast,
 
    // parsed ARP request - one-beat handoff per matching frame
    output logic        arp_tvalid,
    input  logic        arp_tready,
    output arp_struct   arp_tdata,
 
    // ipv4 payload passthrough (Ethernet header stripped)
    output logic        ipv4_rx_tvalid,
    input  logic        ipv4_rx_tready,
    output logic [7:0]  ipv4_rx_tdata,
    output logic        ipv4_rx_tlast
);
 
  // ---------------------------------------------------------------
  // local constants
  // ---------------------------------------------------------------
  localparam logic [47:0] BROADCAST_MAC = 48'hFF_FF_FF_FF_FF_FF;
 
  // ---------------------------------------------------------------
  // parser states
  // ---------------------------------------------------------------
  typedef enum logic [2:0] {
    ST_IDLE,
    ST_DST_MAC,
    ST_SRC_MAC,
    ST_ETHERTYPE,
    ST_ARP_BODY,
    ST_IPV4_PASS,
    ST_DISCARD
  } state_t;
 
  state_t state, state_nxt;
 
  // generic byte counter within the current state; cleared on every state change
  logic [4:0] byte_cnt;
 
  // header field shift registers (big-endian byte-serial accumulation:
  // first byte received ends up as the most-significant byte)
  logic [47:0] dst_mac;
  logic [15:0] ethertype;
 
  wire [47:0] dst_mac_next   = {dst_mac[39:0], rx_tdata};
  wire [15:0] ethertype_next = {ethertype[7:0], rx_tdata};
 
  // ARP body capture (28 bytes, offsets 0-27):
  //   0-1 htype, 2-3 ptype, 4 hlen, 5 plen, 6-7 oper,
  //   8-13 sha, 14-17 spa, 18-23 tha, 24-27 tpa
  logic [15:0] arp_oper;
  logic [47:0] arp_sha;
  logic [31:0] arp_spa;
  logic [47:0] arp_tha;
  logic [31:0] arp_tpa;
 
  wire [31:0] arp_tpa_next = {arp_tpa[23:0], rx_tdata};
 
  logic      arp_pending;  // captured ARP request waiting to be accepted by arp_responder
  arp_struct arp_tdata_r;
 
  wire byte_ok = rx_tvalid && rx_tready;
 
  // ---------------------------------------------------------------
  // rx_tready
  // ---------------------------------------------------------------
  always_comb begin
    unique case (state)
      ST_IDLE:      rx_tready = !arp_pending;   // stall a new frame until a pending ARP handoff clears
      ST_IPV4_PASS: rx_tready = ipv4_rx_tready; // true passthrough backpressure
      default:      rx_tready = 1'b1;           // header/ARP-body capture, discard: always sinkable
    endcase
  end
 
  // ---------------------------------------------------------------
  // next-state logic
  // ---------------------------------------------------------------
  always_comb begin
    state_nxt = state;
    unique case (state)
      ST_IDLE: begin
        if (rx_tvalid && rx_tready)
          state_nxt = ST_DST_MAC;
      end
 
      ST_DST_MAC: begin
        if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;  // aborted / too-short frame
        else if (byte_ok && byte_cnt == 5'd5)
          state_nxt = (dst_mac_next == local_mac || dst_mac_next == BROADCAST_MAC)
                      ? ST_SRC_MAC : ST_DISCARD;
      end
 
      ST_SRC_MAC: begin
        if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;
        else if (byte_ok && byte_cnt == 5'd5)
          state_nxt = ST_ETHERTYPE;
      end
 
      ST_ETHERTYPE: begin
        if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;
        else if (byte_ok && byte_cnt == 5'd1) begin
          if (ethertype_next == ETHERTYPE_ARP)
            state_nxt = ST_ARP_BODY;
          else if (ethertype_next == ETHERTYPE_IPV4)
            state_nxt = ST_IPV4_PASS;
          else
            state_nxt = ST_DISCARD;
        end
      end
 
      ST_ARP_BODY: begin
        if (byte_ok && byte_cnt == 5'd27)
          state_nxt = rx_tlast ? ST_IDLE : ST_DISCARD;  // full 28B captured
        else if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;  // aborted / too-short ARP body
      end
 
      ST_IPV4_PASS: begin
        if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;  // last byte of frame passed through this cycle
      end
 
      ST_DISCARD: begin
        if (byte_ok && rx_tlast)
          state_nxt = ST_IDLE;
      end
 
      default: state_nxt = ST_IDLE;
    endcase
  end
 
  // ---------------------------------------------------------------
  // sequential state, counters, and field capture
  // ---------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (reset) begin
      state       <= ST_IDLE;
      byte_cnt    <= '0;
      arp_pending <= 1'b0;
    end else begin
      state <= state_nxt;
 
      if (state_nxt != state)
        byte_cnt <= '0;
      else if (byte_ok)
        byte_cnt <= byte_cnt + 5'd1;
 
      if (byte_ok) begin
        unique case (state)
          ST_DST_MAC:   dst_mac   <= dst_mac_next;
          ST_ETHERTYPE: ethertype <= ethertype_next;
 
          ST_ARP_BODY: begin
            unique case (byte_cnt)
              5'd6:  arp_oper[15:8] <= rx_tdata;
              5'd7:  arp_oper[7:0]  <= rx_tdata;
              5'd8, 5'd9, 5'd10, 5'd11, 5'd12, 5'd13:
                     arp_sha <= {arp_sha[39:0], rx_tdata};
              5'd14, 5'd15, 5'd16, 5'd17:
                     arp_spa <= {arp_spa[23:0], rx_tdata};
              5'd18, 5'd19, 5'd20, 5'd21, 5'd22, 5'd23:
                     arp_tha <= {arp_tha[39:0], rx_tdata};
              5'd24, 5'd25, 5'd26, 5'd27:
                     arp_tpa <= arp_tpa_next;
              default: ;  // htype/ptype/hlen/plen not needed downstream
            endcase
          end
 
          default: ;
        endcase
      end
 
      // latch a completed, matching ARP request for handoff to arp_responder
      if (state == ST_ARP_BODY && byte_ok && byte_cnt == 5'd27) begin
        if (arp_oper == ARP_OPCODE_REQUEST && arp_tpa_next == local_ip) begin
          arp_tdata_r.opcode     <= arp_oper;
          arp_tdata_r.sender_mac <= arp_sha;
          arp_tdata_r.sender_ip  <= arp_spa;
          arp_tdata_r.target_mac <= arp_tha;
          arp_tdata_r.target_ip  <= arp_tpa_next;
          arp_pending            <= 1'b1;
        end
      end
 
      if (arp_pending && arp_tready)
        arp_pending <= 1'b0;
    end
  end
 
  // ---------------------------------------------------------------
  // output assignments
  // ---------------------------------------------------------------
  assign arp_tvalid = arp_pending;
  assign arp_tdata   = arp_tdata_r;
 
  assign ipv4_rx_tvalid = (state == ST_IPV4_PASS) && rx_tvalid;
  assign ipv4_rx_tdata  = rx_tdata;
  assign ipv4_rx_tlast  = rx_tlast;
 
endmodule : eth_rx_parser
 

