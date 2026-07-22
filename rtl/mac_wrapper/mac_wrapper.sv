//
module mac_wrapper (
    // rgmii
    input  wire        rgmii_rx_clk,
    input  wire [3:0]  rgmii_rxd,
    input  wire        rgmii_rx_ctl,
    output wire        rgmii_tx_clk,
    output wire [3:0]  rgmii_txd,
    output wire        rgmii_tx_ctl,
    // tx into mac - make an interface
    input  wire [7:0]  tx_axis_tdata,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,
    // rx from mac - make an interface
    output wire [7:0]  rx_axis_tdata,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,
);

    // Alex Forencich Gigabit MAC
    eth_mac_1g_rgmii #(
        .TARGET("XILINX"),
        .IODDR_STYLE("IODDR"),
        .CLOCK_INPUT_STYLE("BUFG"),
        .USE_CLK90("TRUE"),
        .ENABLE_PADDING(1),
        .MIN_FRAME_LENGTH(64)
    ) mac_inst (
        //
        .gtx_clk            (),
        .gtx_clk90          (),
        .gtx_rst            (),
        .rx_clk             (),
        .rx_rst             (),
        .tx_clk             (),
        .tx_rst             (),
        // rgmii external IO
        .rgmii_rx_clk       (rgmii_rx_clk),
        .rgmii_rxd          (rgmii_rxd),
        .rgmii_rx_ctl       (rgmii_rx_ctl),
        .rgmii_tx_clk       (rgmii_tx_clk),
        .rgmii_txd          (rgmii_txd),
        .rgmii_tx_ctl       (rgmii_tx_ctl),
        // tx
        .tx_axis_tdata      (),
        .tx_axis_tvalid     (),
        .tx_axis_tready     (),
        .tx_axis_tlast      (),
        .tx_axis_tuser      (),
        // rx
        .rx_axis_tdata      (),
        .rx_axis_tvalid     (),
        .rx_axis_tlast      (),
        .rx_axis_tuser      (),
        // status
        .tx_error_underflow (),
        .rx_error_bad_frame (),
        .rx_error_bad_fcs   (),
        .speed              (),
        // configuration
        .cfg_ifg            (),
        .cfg_tx_enable      (),
        .cfg_rx_enable      ()
    );

endmodule

/*
module eth_mac_1g_rgmii #
(
    // target ("SIM", "GENERIC", "XILINX", "ALTERA")
    parameter TARGET = "GENERIC",
    // IODDR style ("IODDR", "IODDR2")
    // Use IODDR for Virtex-4, Virtex-5, Virtex-6, 7 Series, Ultrascale
    // Use IODDR2 for Spartan-6
    parameter IODDR_STYLE = "IODDR2",
    // Clock input style ("BUFG", "BUFR", "BUFIO", "BUFIO2")
    // Use BUFR for Virtex-6, 7-series
    // Use BUFG for Virtex-5, Spartan-6, Ultrascale
    parameter CLOCK_INPUT_STYLE = "BUFG",
    // Use 90 degree clock for RGMII transmit ("TRUE", "FALSE")
    parameter USE_CLK90 = "TRUE",
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        gtx_clk,
    input  wire        gtx_clk90,
    input  wire        gtx_rst,
    output wire        rx_clk,
    output wire        rx_rst,
    output wire        tx_clk,
    output wire        tx_rst,

    /*
     * AXI input
     */
    input  wire [7:0]  tx_axis_tdata,
    input  wire        tx_axis_tvalid,
    output wire        tx_axis_tready,
    input  wire        tx_axis_tlast,
    input  wire        tx_axis_tuser,

    /*
     * AXI output
     */
    output wire [7:0]  rx_axis_tdata,
    output wire        rx_axis_tvalid,
    output wire        rx_axis_tlast,
    output wire        rx_axis_tuser,

    /*
     * RGMII interface
     */
    input  wire        rgmii_rx_clk,
    input  wire [3:0]  rgmii_rxd,
    input  wire        rgmii_rx_ctl,
    output wire        rgmii_tx_clk,
    output wire [3:0]  rgmii_txd,
    output wire        rgmii_tx_ctl,

    /*
     * Status
     */
    output wire        tx_error_underflow,
    output wire        rx_error_bad_frame,
    output wire        rx_error_bad_fcs,
    output wire [1:0]  speed,

    /*
     * Configuration
     */
    input  wire [7:0]  cfg_ifg,
    input  wire        cfg_tx_enable,
    input  wire        cfg_rx_enable
);
*/
