// mac_wrapper.sv - This block instantiates the Alex Forencich tri-mode ethernet MAC along with tx
// and rx fifo and an MMCM for clock generation. 
//
module mac_wrapper #(
    parameter int fifo_depth = 4096
) (
    // external 200MHz differential clock
    input   logic       clkin200_p,
    input   logic       clkin200_n,
    // generated clocks and reset
    output  logic       refclk,     // 200MHz reference clock for IO delay if needed
    output  logic       user_clk,   // 125MHz clock for all user logic
    output  logic       user_reset, // reset with deassertion synchronized to user_clock
    // external rgmii interface to PHY
    input   logic       rgmii_rx_clk,
    input   logic[3:0]  rgmii_rxd,
    input   logic       rgmii_rx_ctl,
    output  logic       rgmii_tx_clk,
    output  logic[3:0]  rgmii_txd,
    output  logic       rgmii_tx_ctl,
    output  logic       rgmii_reset_n,  // reset to the PHY
    // app side of the tx fifo
    input   logic       tx_clk,
    input   logic[7:0]  tx_tdata,
    input   logic       tx_tvalid,
    output  logic       tx_tready,
    input   logic       tx_tlast,
    // app side of the rx fifo
    input   logic       rx_clk,
    output  logic[7:0]  rx_tdata,
    output  logic       rx_tvalid,
    input   logic       rx_tready,
    output  logic       rx_tlast
);

    logic       gtx_clk;
    logic       gtx_clk90;
    logic       gtx_rst=1;

    // mac status, maybe should be outputs to next level
    logic       tx_error_underflow;
    logic       rx_error_bad_frame;
    logic       rx_error_bad_fcs;
    logic[1:0]  speed;
    // tx from fifo into mac
    logic       mac_tx_clk;
    logic       mac_tx_rst;
    logic[7:0]  mac_tx_tdata;
    logic       mac_tx_tvalid;
    logic       mac_tx_tready;
    logic       mac_tx_tlast;
    // rx from mac into fifo
    logic       mac_rx_clk;
    logic       mac_rx_rst;
    logic[7:0]  mac_rx_tdata;
    logic       mac_rx_tvalid;
    logic       mac_rx_tready; // not used by mac
    logic       mac_rx_tlast;

    // Alex Forencich Gigabit MAC
    eth_mac_1g_rgmii #(
        .TARGET("XILINX"),
        .IODDR_STYLE("IODDR"),
        .CLOCK_INPUT_STYLE("BUFG"),
        .USE_CLK90("TRUE"),
        .ENABLE_PADDING(1),
        .MIN_FRAME_LENGTH(64)
    ) mac_inst (
        // clocks and resets
        .gtx_clk            (gtx_clk),
        .gtx_clk90          (gtx_clk90),
        .gtx_rst            (gtx_rst),
        // rgmii external IO
        .rgmii_rx_clk       (rgmii_rx_clk),
        .rgmii_rxd          (rgmii_rxd),
        .rgmii_rx_ctl       (rgmii_rx_ctl),
        .rgmii_tx_clk       (rgmii_tx_clk),
        .rgmii_txd          (rgmii_txd),
        .rgmii_tx_ctl       (rgmii_tx_ctl),
        // tx
        .tx_rst             (mac_tx_rst),
        .tx_clk             (mac_tx_clk),
        .tx_axis_tdata      (mac_tx_tdata),
        .tx_axis_tvalid     (mac_tx_tvalid),
        .tx_axis_tready     (mac_tx_tready),
        .tx_axis_tlast      (mac_tx_tlast),
        .tx_axis_tuser      (0),
        // rx
        .rx_rst             (mac_rx_rst),
        .rx_clk             (mac_rx_clk),
        .rx_axis_tdata      (mac_rx_tdata),
        .rx_axis_tvalid     (mac_rx_tvalid),
        .rx_axis_tlast      (mac_rx_tlast),
        .rx_axis_tuser      (),
        // status
        .tx_error_underflow (tx_error_underflow),
        .rx_error_bad_frame (rx_error_bad_frame),
        .rx_error_bad_fcs   (rx_error_bad_fcs),
        .speed              (speed),
        // configuration
        .cfg_ifg            (8'd12),
        .cfg_tx_enable      (1'b1),
        .cfg_rx_enable      (1'b1)        
    );

    // tx fifo
    axis_fifo #( .width(8), .depth(fifo_depth)) tx_fifo_inst (
        // app side
        .s_aclk     (tx_clk),
        .s_tvalid   (tx_tvalid),
        .s_tready   (tx_tready),
        .s_tdata    (tx_tdata),
        .s_tlast    (tx_tlast),
        // mac side
        .s_aresetn  (~mac_tx_rst),
        .m_aclk     (mac_tx_clk),
        .m_tvalid   (mac_tx_tvalid),
        .m_tready   (mac_tx_tready),
        .m_tdata    (mac_tx_tdata),
        .m_tlast    (mac_tx_tlast)
    );

    // rx fifo
    axis_fifo #( .width(8), .depth(fifo_depth)) rx_fifo_inst (
        // mac side
        .s_aresetn  (~mac_rx_rst),
        .s_aclk     (mac_rx_clk),
        .s_tvalid   (mac_rx_tvalid),
        .s_tready   (mac_rx_tready),
        .s_tdata    (mac_rx_tdata),
        .s_tlast    (mac_rx_tlast),
        // app side
        .m_aclk     (rx_clk),
        .m_tvalid   (rx_tvalid),
        .m_tready   (rx_tready),
        .m_tdata    (rx_tdata),
        .m_tlast    (rx_tlast)
    );

    // make clocks
    logic clkin200;
    IBUFDS IBUFDS_inst (.O(clkin200), .I(clkin200_p), .IB(clkin200_n));
    logic clkfb, mmcm_locked, clkout0, clkout1, clkout2;    
    logic mmcm_rst = 1;
    MMCME4_ADV #(
        .BANDWIDTH("OPTIMIZED"),        // Jitter programming
        .CLKFBOUT_MULT_F(5.0),          // Multiply value for all CLKOUT
        .CLKFBOUT_PHASE(0.0),           // Phase offset in degrees of CLKFB
        .CLKFBOUT_USE_FINE_PS("FALSE"), // Fine phase shift enable (TRUE/FALSE)
        .CLKIN1_PERIOD(5.0),            // Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
        .CLKIN2_PERIOD(0.0),            // Input clock period in ns to ps resolution (i.e., 33.333 is 30 MHz).
      
        .CLKOUT0_DIVIDE_F(8.0),         // Divide amount for CLKOUT0
        .CLKOUT0_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT0
        .CLKOUT0_PHASE(0.0),            // Phase offset for CLKOUT0
        .CLKOUT0_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
      
        .CLKOUT1_DIVIDE(8),             // Divide amount for CLKOUT (1-128)
        .CLKOUT1_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT1_PHASE(90.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT1_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
      
        .CLKOUT2_DIVIDE(5),             // Divide amount for CLKOUT (1-128)
        .CLKOUT2_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT2_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT2_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
      
        .CLKOUT3_DIVIDE(1),             // Divide amount for CLKOUT (1-128)
        .CLKOUT3_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT3_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT3_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
      
        .CLKOUT4_CASCADE("FALSE"),      // Divide amount for CLKOUT (1-128)
        .CLKOUT4_DIVIDE(1),             // Divide amount for CLKOUT (1-128)
        .CLKOUT4_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT4_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT4_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
        .CLKOUT5_DIVIDE(1),             // Divide amount for CLKOUT (1-128)
        .CLKOUT5_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT5_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT5_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
        .CLKOUT6_DIVIDE(1),             // Divide amount for CLKOUT (1-128)
        .CLKOUT6_DUTY_CYCLE(0.5),       // Duty cycle for CLKOUT outputs (0.001-0.999).
        .CLKOUT6_PHASE(0.0),            // Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT6_USE_FINE_PS("FALSE"),  // Fine phase shift enable (TRUE/FALSE)
        .COMPENSATION("AUTO"),          // Clock input compensation
        .DIVCLK_DIVIDE(1),              // Master division value
        .IS_CLKFBIN_INVERTED(1'b0),     // Optional inversion for CLKFBIN
        .IS_CLKIN1_INVERTED(1'b0),      // Optional inversion for CLKIN1
        .IS_CLKIN2_INVERTED(1'b0),      // Optional inversion for CLKIN2
        .IS_CLKINSEL_INVERTED(1'b0),    // Optional inversion for CLKINSEL
        .IS_PSEN_INVERTED(1'b0),        // Optional inversion for PSEN
        .IS_PSINCDEC_INVERTED(1'b0),    // Optional inversion for PSINCDEC
        .IS_PWRDWN_INVERTED(1'b0),      // Optional inversion for PWRDWN
        .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
        .REF_JITTER1(0.0),              // Reference input jitter in UI (0.000-0.999).
        .REF_JITTER2(0.0),              // Reference input jitter in UI (0.000-0.999).
        .SS_EN("FALSE"),                // Enables spread spectrum
        .SS_MODE("CENTER_HIGH"),        // Spread spectrum frequency deviation and the spread type
        .SS_MOD_PERIOD(10000),          // Spread spectrum modulation period (ns)
        .STARTUP_WAIT("FALSE")          // Delays DONE until MMCM is locked
    ) MMCME4_ADV_inst (
        .CDDCDONE(),         // 1-bit output: Clock dynamic divide done
        .CLKFBOUT(clkfb),         // 1-bit output: Feedback clock
        .CLKFBOUTB(),       // 1-bit output: Inverted CLKFBOUT
        .CLKFBSTOPPED(), // 1-bit output: Feedback clock stopped
        .CLKINSTOPPED(), // 1-bit output: Input clock stopped

        .CLKOUT0(clkout0),           // 1-bit output: CLKOUT0
        .CLKOUT0B(),         // 1-bit output: Inverted CLKOUT0

        .CLKOUT1(clkout1),           // 1-bit output: CLKOUT1
        .CLKOUT1B(),         // 1-bit output: Inverted CLKOUT1

        .CLKOUT2(clkout2),           // 1-bit output: CLKOUT2
        .CLKOUT2B(),         // 1-bit output: Inverted CLKOUT2

        .CLKOUT3(),           // 1-bit output: CLKOUT3
        .CLKOUT3B(),         // 1-bit output: Inverted CLKOUT3
        .CLKOUT4(),           // 1-bit output: CLKOUT4
        .CLKOUT5(),           // 1-bit output: CLKOUT5
        .CLKOUT6(),           // 1-bit output: CLKOUT6
        .DO(),                     // 16-bit output: DRP data output
        .DRDY(),                 // 1-bit output: DRP ready
        .LOCKED(mmcm_locked),             // 1-bit output: LOCK
        .PSDONE(),             // 1-bit output: Phase shift done
        .CDDCREQ(0),           // 1-bit input: Request to dynamic divide clock
        .CLKFBIN(clkfb),           // 1-bit input: Feedback clock
        .CLKIN1(clkin200),             // 1-bit input: Primary clock
        .CLKIN2(0),             // 1-bit input: Secondary clock
        .CLKINSEL(1),         // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
        .DADDR(0),               // 7-bit input: DRP address
        .DCLK(0),                 // 1-bit input: DRP clock
        .DEN(0),                   // 1-bit input: DRP enable
        .DI(0),                     // 16-bit input: DRP data input
        .DWE(0),                   // 1-bit input: DRP write enable
        .PSCLK(0),               // 1-bit input: Phase shift clock
        .PSEN(0),                 // 1-bit input: Phase shift enable
        .PSINCDEC(0),         // 1-bit input: Phase shift increment/decrement
        .PWRDWN(0),             // 1-bit input: Power-down
        .RST(mmcm_rst)                    // 1-bit input: Reset
    );
    BUFG BUFG_gtx_clk (.O(gtx_clk), .I(clkout0));
    BUFG BUFG_gtx_clk90 (.O(gtx_clk90), .I(clkout1));
    BUFG BUFG_refclk (.O(refclk), .I(clkout2));
    assign user_clk = gtx_clk;
   
    // make resets
    logic[7:0] reset_count = -1;
    logic rgmii_reset_n_int = 0;
    logic user_reset_int=1;
    always_ff @(posedge gtx_clk) begin
        // release resets to the mac and app logic when the clocks are stable
        gtx_rst        <= ~mmcm_locked;
        user_reset_int <= ~mmcm_locked;
        // provide big delay on reset to PHY - is this needed?
        if (mmcm_locked == 0) begin
            reset_count <= -1;
            rgmii_reset_n_int = 0;
        end else begin
            reset_count <= reset_count - 1;
        end
        if (reset_count == 0) rgmii_reset_n_int <= 1;        

    end
    assign rgmii_reset_n = rgmii_reset_n_int;
    assign user_reset = user_reset_int;
    
    logic[7:0] clk200_count=-1;
    always_ff @(posedge clkin200) begin
        clk200_count <= clk200_count - 1;
        if (clk200_count == 0) mmcm_rst <= 0;
    end
    

//    // debug
//    mac_ila mac_rx_ila_inst (.clk(mac_rx_clk), .probe0({mac_rx_rst, mac_rx_tvalid, mac_rx_tready, mac_rx_tdata, mac_rx_tlast})); // 12
//    mac_ila rx_ila_inst (.clk(rx_clk), .probe0({mac_rx_rst, rx_tvalid, rx_tready, rx_tdata, rx_tlast})); // 12

         
endmodule

/*
*/
