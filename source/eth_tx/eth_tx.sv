// eth_tx.sv - this module waits for events on ARP and IPv4 ports and
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

    logic[47:0] sha;
    logic[31:0] spa, tpa;

    always_ff @(posedge clk) begin

        if ((arp_tvalid) && (arp_tready)) begin
            sha <= arp_sha;
            spa <= arp_spa;
            tpa <= arp_tpa;
        end

    end

    logic[3:0] state=0, next_state;
    always_comb begin
        // defaults
        next_state = state;
        arp_tready = 0;

        case (state) 

            0: begin
                next_state = 1;
            end

            1: begin
                arp_tready = 1;
                if (arp_tvalid) begin
                    next_state = 2;
                end
            end

            default: begin
                next_state = 0;
            end

        endcase
    end

    always_ff @(posedge clk) state <= next_state;


endmodule

