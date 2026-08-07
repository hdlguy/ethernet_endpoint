// eth_tx.sv - this module waits for events on the ARP and IPv4 interfaces and
// then formats frames to mac_wrapper for transmission.
//
module eth_tx #(
    parameter logic [47:0] local_mac,
    parameter logic [31:0] local_ip
) (
    input   logic       clk,
    input   logic       reset,
    // arp data from eth_rx
    input   logic       arp_tvalid,
    output  logic       arp_tready,
    input   logic[47:0] arp_sha,
    input   logic[31:0] arp_spa,
    input   logic[31:0] arp_tpa,
    // ping data from eth_rx
    input  logic        ping_tvalid,
    output logic        ping_tready,
    input  logic[47:0]  ping_sha,
    input  logic[31:0]  ping_spa,
    input  logic[31:0]  ping_tpa,
    input  logic[15:0]  ping_id,
    input  logic[15:0]  ping_seq,
    input  logic[127:0] ping_ts,
    // IPv4 data
    input   logic       ipv4_tvalid,
    output  logic       ipv4_tready,
    input   logic[7:0]  ipv4_tdata,
    input   logic       ipv4_tlast,
    // interface to tx side of mac_wrapper
    output  logic       tx_tvalid,
    input   logic       tx_tready,
    output  logic[7:0]  tx_tdata,
    output  logic       tx_tlast
);

    // temporary
    assign ipv4_tready = 0;

    logic[47:0] sha;
    logic[31:0] spa, tpa;
    logic[15:0] id, seq;
    logic[127:0] time;
    always_ff @(posedge clk) begin

        // latch the arp data from the event
        if ((arp_tvalid) && (arp_tready)) begin
            sha <= arp_sha;
            spa <= arp_spa;
            tpa <= arp_tpa;
        end

        // latch the ping data from the event
        if ((ping_tvalid) && (ping_tready)) begin
            sha <= ping_sha;
            spa <= ping_spa;
            tpa <= ping_tpa;
            id  <= ping_id;
            seq <= ping_seq;
            ts  <= ping_ts;
        end

    end

    // assign values to the 98 byte ping frame.
    localparam int Lping = 98;
    logic[0:Lping-1][7:0] ping_bytes;
    assign ping_bytes[ 0: 5] = sha;
    assign ping_bytes[ 6:11] = local_mac;
    assign ping_bytes[12:13] = 16'h0800;
    assign ping_bytes[   14] = 8'h45;
    assign ping_bytes[   15] = 8'h00;
    assign ping_bytes[16:17] = 16'h0054;
    assign ping_bytes[18:19] = 16'h2455;
    assign ping_bytes[20:21] = 16'h0000;
    assign ping_bytes[   22] = 8'hff;
    assign ping_bytes[   23] = 8'h01;


    // assign values to the 42 byte arp frame.
    localparam int Larp = 42;
    logic[0:Larp-1][7:0] arp_bytes;
    assign arp_bytes[ 0: 5] = sha;
    assign arp_bytes[ 6:11] = local_mac;
    assign arp_bytes[12:13] = 16'h0806;
    assign arp_bytes[14:15] = 16'h0001;
    assign arp_bytes[16:17] = 16'h0800;
    assign arp_bytes[   18] = 8'h06;
    assign arp_bytes[   19] = 8'h04;
    assign arp_bytes[20:21] = 16'h0002;
    assign arp_bytes[22:27] = local_mac;
    assign arp_bytes[28:31] = tpa; //local_ip;
    assign arp_bytes[32:37] = sha;
    assign arp_bytes[38:41] = spa;

    // a state machine
    logic clear_count, arp_active;
    logic[3:0] state=0, next_state;
    always_comb begin
        // defaults
        next_state = state;
        arp_tready = 0;
        clear_count = 0;
        arp_active = 0;

        case (state) 

            0: begin
                next_state = 1;
            end

            // check if an arp event is waiting
            1: begin
                if (arp_tvalid) begin
                    next_state = 2;
                    arp_tready = 1;
                end else begin
                    next_state = 8;
                end
            end

            2: begin
                next_state = 3;
                clear_count = 1;
            end

            3: begin
                arp_active = 1;
                if ((byte_count >= (Larp-1)) && (tx_tready)) begin
                    next_state = 4;
                end
            end


            // check if an ping event is waiting
            4: begin
                if (ping_tvalid) begin
                    next_state = 5;
                    ping_tready = 1;
                end else begin
                    next_state = 8;
                end
            end

            5: begin
                next_state = 6;
                clear_count = 1;
            end

            6: begin
                ping_active = 1;
                if ((byte_count >= (Lping-1)) && (tx_tready)) begin
                    next_state = 8;
                end
            end
            
            
            // check if an ipv4 event is waiting
            8:begin
                next_state = 0;
            end

            default: begin
                next_state = 0;
            end

        endcase
    end

    always_ff @(posedge clk) state <= next_state;

    // byte counter
    logic[15:0] byte_count=0;
    always_ff @(posedge clk) begin
        if (clear_count) begin
            byte_count <= 0;
        end else begin
            if ((tx_tready) && (tx_tvalid)) begin
                byte_count <= byte_count + 1;
            end
        end
    end
    assign tx_tvalid = arp_active | ping_active;

    
    always_comb begin
        if (arp_active) begin
            tx_tdata = arp_bytes[byte_count];
            tx_tlast = (byte_count == (Larp-1));
        end else begin
            tx_tdata = 0;
            tx_tlast = 0;
        end    
    end
    
    
    // debug
//    eth_tx_ila ila_inst(.clk(clk), .probe0({state, byte_count, arp_active, tx_tdata_int, tx_tvalid_int, tx_tlast_int, tx_tready})); // 32

endmodule

/* reply to "sudo arping -W 2 -i eno2 192.168.1.112"
00 d8 61 59 63 7a - sender mac
30 05 5c 22 58 43 - target mac (printer)
08 06 - arp
00 01 - hw type
08 00 - protocol type
06 - hw address length
04 - protocol address length
00 02 - opcode = arp reply
30 05 5c 22 58 43 - target mac (printer)
c0 a8 01 70 - target ip
00 d8 61 59 63 7a - host mac
c0 a8 01 c5 - host ip
00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  00 00 - padding
*/
