// a design to test the endpoint in hardware.

module endpoint_top (
    input   logic       clkin200_p,
    input   logic       clkin200_n,
    input   logic       rgmii_rx_clk,
    input   logic[3:0]  rgmii_rxd,
    input   logic       rgmii_rx_ctl,
    output  logic       rgmii_tx_clk,
    output  logic[3:0]  rgmii_txd,
    output  logic       rgmii_tx_ctl,    
    output  logic       rgmii_reset_n,
    tri     logic       rgmii_mdio_clock,
    tri     logic       rgmii_mdio_data,
    //
    output  logic       user_led,
    output  logic       fan_pwm
);

    assign rgmii_mdio_clock = 1'bz;
    assign rgmii_mdio_data  = 1'bz;

    logic       user_clk;
    logic       user_reset;

    // udp rx
    logic       udp_rx_tvalid;
    logic       udp_rx_tready;
    logic[7:0]  udp_rx_tdata;
    logic       udp_rx_tlast;
    // udp tx
    logic       udp_tx_tvalid;
    logic       udp_tx_tready;
    logic[7:0]  udp_tx_tdata;
    logic       udp_tx_tlast;
    
    localparam logic[47:0] local_mac = {8'h00, 8'h0A, 8'h35, 8'h01, 8'h02, 8'h03}; // a Xilinx mac
    localparam logic[31:0] local_ip  = {8'h10, 8'h00, 8'h00, 8'h80}; // 16.0.0.128

    endpoint #(.local_mac(local_mac), .local_ip(local_ip)) uut (
        //
        .clkin200_p         (clkin200_p),
        .clkin200_n         (clkin200_n),
        //
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
        .rgmii_mdio_clock   (rgmii_mdio_clock),
        .rgmii_mdio_data    (rgmii_mdio_data),
        // udp rx
        .udp_rx_tvalid      (udp_rx_tvalid),
        .udp_rx_tready      (udp_rx_tready),
        .udp_rx_tdata       (udp_rx_tdata),
        .udp_rx_tlast       (udp_rx_tlast),
        // udp tx
        .udp_tx_tvalid      (udp_tx_tvalid),
        .udp_tx_tready      (udp_tx_tready),
        .udp_tx_tdata       (udp_tx_tdata),
        .udp_tx_tlast       (udp_tx_tlast)
    );

    // temporary
    assign udp_rx_tready = 1;
    assign udp_tx_tvalid = 0;
    assign udp_tx_tdata = 0;
    assign udp_tx_tlast = 0;
    
    
    logic[26:0] led_count=0;
    always_ff @(posedge user_clk) begin
        // free running counter
        led_count <= led_count + 1;
        // flash the LED
        user_led  <= led_count[26];
        // slow down the fan
        fan_pwm <= led_count[17] & led_count[16] & led_count[15];
    end    

    
    // debug
    mac_ila ila_inst (.clk(user_clk), .probe0({tx_rst, tx_tdata, tx_tvalid, tx_tready, tx_tlast, rx_rst, rx_tdata, rx_tvalid, rx_tready, rx_tlast})); // 24

endmodule

/*
module endpoint #(
    parameter logic[47:0] local_mac = {8'h00, 8'h0A, 8'h35, 8'h01, 8'h02, 8'h03}; // a Xilinx mac
    parameter logic[31:0] local_ip  = {8'h10, 8'h00, 8'h00, 8'h80}; // 16.0.0.128
) (
    input   logic       clkin200_p,
    input   logic       clkin200_n,
    //
    output  logic       user_clk,
    output  logic       user_reset,
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
*/
