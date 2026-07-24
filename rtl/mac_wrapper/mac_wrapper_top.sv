// a design to test the mac_wrapper in hardware.

module mac_wrapper_top (
    input   logic       clkin200_p,
    input   logic       clkin200_n,
    input   logic       rgmii_rx_clk,
    input   logic[3:0]  rgmii_rxd,
    input   logic       rgmii_rx_ctl,
    output  logic       rgmii_tx_clk,
    output  logic[3:0]  rgmii_txd,
    output  logic       rgmii_tx_ctl,    
    output  logic       rgmii_reset_n,
    output  logic       rgmii_mdio_clock,
    output  logic       rgmii_mdio_data,
    //
    output  logic       user_led
);

    assign rgmii_mdio_clock = 1'bz;
    assign rgmii_mdio_data  = 1'bz;

    logic       refclk200;
    logic       userclk125;

    logic       tx_rst;
    logic       tx_clk;
    logic[7:0]  tx_tdata=0;
    logic       tx_tvalid=0;
    logic       tx_tready;
    logic       tx_tlast;

    logic       rx_rst;
    logic       rx_clk;
    logic[7:0]  rx_tdata;
    logic       rx_tvalid;
    logic       rx_tlast;
    
    mac_wrapper uut (
        //
        .clkin200_p         (clkin200_p),
        .clkin200_n         (clkin200_n),
        //
        .refclk200          (refclk200),
        .userclk125         (userclk125),
        //
        .rgmii_rx_clk       (rgmii_rx_clk),
        .rgmii_rxd          (rgmii_rxd),
        .rgmii_rx_ctl       (rgmii_rx_ctl),
        .rgmii_tx_clk       (rgmii_tx_clk),
        .rgmii_txd          (rgmii_txd),
        .rgmii_tx_ctl       (rgmii_tx_ctl),
        .rgmii_reset_n      (rgmii_reset_n),
        //
        .tx_rst             (tx_rst),
        .tx_clk             (tx_clk),
        .tx_tdata           (tx_tdata),
        .tx_tvalid          (tx_tvalid),
        .tx_tready          (tx_tready),
        .tx_tlast           (tx_tlast),
        //
        .rx_rst             (rx_rst),
        .rx_clk             (rx_clk),
        .rx_tdata           (rx_tdata),
        .rx_tvalid          (rx_tvalid),
        .rx_tlast           (rx_tlast)
    );
    
    
    // lets loop back through a fifo
    axis_fifo #(
        .width(8),
        .depth(4096)
    ) fifo_inst (
        //
        .s_aresetn  (~rx_rst),
        .s_aclk     (rx_clk),
        .s_tvalid   (rx_tvalid),
        .s_tready   (),
        .s_tdata    (rx_tdata),
        .s_tlast    (rx_tlast),
        //
        .m_aclk     (tx_clk),
        .m_tvalid   (tx_tvalid),
        .m_tready   (tx_tready),
        .m_tdata    (tx_tdata),
        .m_tlast    (tx_tlast)
    );

    // flash the LED
    logic[26:0] led_count=0;
    always_ff @(posedge userclk125) begin
        led_count <= led_count + 1;
        user_led  <= led_count[26];
    end
    
    // debug
    mac_ila ila_inst (.clk(userclk125), .probe0({tx_rst, tx_tdata, tx_tvalid, tx_tready, tx_tlast, rx_rst, rx_tdata, rx_tvalid, rx_tlast})); // 23

endmodule
