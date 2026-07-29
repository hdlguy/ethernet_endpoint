//


import ethernet_types_pkg::*;

module eth_rx_parser
(
    input  logic            clk,
    input  logic            reset,

    // Stream from mac_wrapper
    input  logic            rx_tvalid,
    output logic            rx_tready,
    input  logic [7:0]      rx_tdata,
    input  logic            rx_tlast,

    // Configuration
    input  logic [47:0]     local_mac,
    input  logic [31:0]     local_ip,

    // ARP request event
    output logic            arp_tvalid,
    input  logic            arp_tready,
    output arp_request_t    arp_tdata
);

    assign rx_tvalid = 1'b1; // always ready, no backpressure

    logic dv_in, dv_in_q=0;
    assign dv_in = rx_tvalid & rx_tready;

    always_ff @(posedge clk) begin
        dv_in_q <= dv_in;
    end

endmodule
