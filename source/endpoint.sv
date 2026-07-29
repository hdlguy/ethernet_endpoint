// endpoint.sv - this is the complete ethernet endpoint incorporating
// ARP, Ping, and UDP protocols.

import net_pak::*;

module endpoint #(
    parameter logic[0:5][7:0] local_mac = {8'h00, 8'h0A, 8'h35, 8'h01, 8'h02, 8'h03};
    parameter logic[0:3][7:0] local_ip  = {8'h10, 8'h00, 8'h00, 8'h80}; // 16.0.0.128
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
    logic[7:0]  ipv4_rx_tdata;
    eth_rx_parser eth_rx_parser_inst (
        //
        .clk                (user_clk),
        .reset              (user_reset),
        // stream interface from mac_wrapper
        .rx_clk             (user_clk),
        .rx_tvalid          (rx_tvalid),
        .rx_tready          (rx_tready),
        .rx_tdata           (rx_tdata),
        .rx_tlast           (rx_tlast),
        // arp data
        .arp_tvalid         (arp_tvalid),
        .arp_tready         (arp_tready),
        .arp_tdata          (arp_tdata),
        // ipv4 data
        .ipv4_rx_tvalid     (ipv4_rx_tvalid),
        .ipv4_rx_tready     (ipv4_rx_tready),
        .ipv4_rx_tdata      (ipv4_rx_tdata),
        .ipv4_rx_tlast      (ipv4_rx_tlast)
    ); 
    
endmodule

