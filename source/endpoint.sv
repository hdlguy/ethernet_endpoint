// endpoint.sv - this is the complete ethernet endpoint incorporating
// ARP, Ping, and UDP protocols.

import ethernet_types_pkg::*;

module endpoint #(
    parameter logic[47:0] local_mac = {8'h00, 8'h0A, 8'h35, 8'h01, 8'h02, 8'h03};
    parameter logic[31:0] local_ip  = {8'h10, 8'h00, 8'h00, 8'h80}; // 16.0.0.128
) (
    input   logic       clkin200_p,
    input   logic       clkin200_n,
    // rgmii
    input   logic       rgmii_rx_clk,
    input   logic[3:0]  rgmii_rxd,
    input   logic       rgmii_rx_ctl,
    output  logic       rgmii_tx_clk,
    output  logic[3:0]  rgmii_txd,
    output  logic       rgmii_tx_ctl,    
    output  logic       rgmii_reset_n,
    tri     logic       rgmii_mdio_clock,
    tri     logic       rgmii_mdio_data,
    // udp rx
    output  logic       udp_rx_tvalid,
    input   logic       udp_rx_tready,
    output  logic[7:0]  udp_rx_tdata,
    output  logic       udp_rx_tlast,
    // udp tx
    input   logic       udp_tx_tvalid,
    output  logic       udp_tx_tready,
    input   logic[7:0]  udp_tx_tdata,
    input   logic       udp_tx_tlast,
);


    logic user_clk, user_reset;
    logic tx_tvalid, tx_tready, tx_tlast;
    logic[7:0] tx_tdata;
    logic rx_tvalid, rx_tready, rx_tlast;
    logic[7:0] rx_tdata;

    // wrapper with AF MAC, clock generation and fifos
    mac_wrapper mac_wrapper_inst (
        //
        .clkin200_p         (clkin200_p),
        .clkin200_n         (clkin200_n),
        //
        .refclk             (),
        .user_clk           (user_clk),
        .user_reset         (user_reset),
        //
        .rgmii_rx_clk       (rgmii_rx_clk),
        .rgmii_rxd          (rgmii_rxd),
        .rgmii_rx_ctl       (rgmii_rx_ctl),
        .rgmii_tx_clk       (rgmii_tx_clk),
        .rgmii_txd          (rgmii_txd),
        .rgmii_tx_ctl       (rgmii_tx_ctl),
        .rgmii_reset_n      (rgmii_reset_n),
        //
        .tx_clk             (user_clk),
        .tx_tvalid          (tx_tvalid),
        .tx_tready          (tx_tready),
        .tx_tdata           (tx_tdata),
        .tx_tlast           (tx_tlast),
        //
        .rx_clk             (user_clk),
        .rx_tvalid          (rx_tvalid),
        .rx_tready          (rx_tready),
        .rx_tdata           (rx_tdata),
        .rx_tlast           (rx_tlast),
        // mac status
        .tx_error_underflow (),
        .rx_error_bad_frame (),
        .rx_error_bad_fcs   (),
        .speed              ()
    );

    // rx packet filter
    logic arp_tvalid, arp_tready;
    arp_struct arp_tdata;
    logic ipv4_rx_tvalid, ipv4_rx_tready, ipv4_rx_tlast;
    logic[7:0] ipv4_rx_tdata;
    eth_rx #(.local_mac(local_mac), .local_ip(local_ip)) eth_rx_inst (
        //
        .clk            (user_clk),
        .reset          (user_reset),
        // stream interface from mac_wrapper
        .rx_clk         (user_clk),
        .rx_tvalid      (rx_tvalid),
        .rx_tready      (rx_tready),
        .rx_tdata       (rx_tdata),
        .rx_tlast       (rx_tlast),
        // arp data
        .arp_tvalid     (arp_tvalid),
        .arp_tready     (arp_tready),
        .arp_sha        (arp_sha),
        .arp_spa        (arp_spa),
        .arp_tpa        (arp_tpa),
        // ipv4 data received
        .ipv4_rx_tvalid (ipv4_rx_tvalid),
        .ipv4_rx_tready (ipv4_rx_tready),
        .ipv4_rx_tdata  (ipv4_rx_tdata),
        .ipv4_rx_tlast  (ipv4_rx_tlast)
    ); 

    // temporary
    assign ipv4_rx_tready = 1;

    // tx packet multiplexor
    logic ipv4_tx_tvalid, ipv4_tx_tready, ipv4_tx_tlast;
    logic[7:0] ipv4_tx_tdata;
    eth_tx #(.local_mac(local_mac), .local_ip(local_ip)) eth_tx_inst (
        //
        .clk            (user_clk),
        .reset          (user_reset),
        // arp data
        .arp_tvalid     (arp_tvalid),
        .arp_tready     (arp_tready),
        .arp_sha        (arp_sha),
        .arp_spa        (arp_spa),
        .arp_tpa        (arp_tpa),
        // ipv4 data for transmit
        .ipv4_tvalid    (ipv4_tx_tvalid),
        .ipv4_tready    (ipv4_tx_tready),
        .ipv4_tdata     (ipv4_tx_tdata),
        .ipv4_tlast     (ipv4_tx_tlast),
        // stream interface to mac_wrapper
        .tx_tvalid      (tx_tvalid),
        .tx_tready      (tx_tready),
        .tx_tdata       (tx_tdata),
        .tx_tlast       (tx_tlast)
    );

    // temporary
    assign ipv4_tx_tvalid = 1;
    assign ipv4_tx_tdata = 1;
    assign ipv4_tx_tlast = 1;

    // debug
    endpoint_ila ila_inst (.clk(user_clk), .probe0({arp_tvalid, arp_tready, arp_sha, arp_spa, arp_tpa})); // 16
    
endmodule

/*
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
*/
