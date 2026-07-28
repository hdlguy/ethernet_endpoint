`timescale 100ps/1ps;

module mac_wrapper_top_tb();

    // a valid gmii frame from AF simulation
    localparam int Ngmii = 76;
    logic[7:0] gmii_frame[0:Ngmii-1] = {
        // preamble
        8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hd5, 
        // data
        8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08, 8'h09, 8'h0a, 8'h0b, 8'h0c, 8'h0d, 8'h0e, 8'h0f, 
        8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17, 8'h18, 8'h19, 8'h1a, 8'h1b, 8'h1c, 8'h1d, 8'h1e, 8'h1f, 
        8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27, 8'h28, 8'h29, 8'h2a, 8'h2b, 8'h2c, 8'h2d, 8'h2e, 8'h2f, 
        8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37, 8'h38, 8'h39, 8'h3a, 8'h3b, 8'h3c, 8'h3d, 8'h3e, 8'h3f, 
        // CRC
        8'h8c, 8'hce, 8'h0e, 8'h10
    };

    logic gmii_rx_en, gmii_rx_er;
    logic[7:0] gmii_rx_d;

    logic       clkin200_p;
    logic       clkin200_n;
    logic       rgmii_rx_clk;
    logic[3:0]  rgmii_rxd;
    logic       rgmii_rx_ctl;
    logic       rgmii_tx_clk;
    logic[3:0]  rgmii_txd;
    logic       rgmii_tx_ctl;    
    logic       rgmii_reset_n;
    tri         rgmii_mdio_clock;
    tri         rgmii_mdio_data;   
    logic       user_led;
    logic       fan_pwm;
    
    assign (pull1, pull0) rgmii_mdio_clock = '1;
    assign (pull1, pull0) rgmii_mdio_data = '1;
    
    localparam time clk_period=8ns; logic gmii_rx_clk=0; always #(clk_period/2) gmii_rx_clk=~gmii_rx_clk;
    localparam time clk200_period=5ns; logic clk200=0; always #(clk200_period/2) clk200=~clk200;
    assign clkin200_p = clk200; assign clkin200_n = ~clk200;
    
    rgmii_mux rgmii_mux_inst (.gmii_clk(gmii_rx_clk), .gmii_en(gmii_rx_en), .gmii_er(gmii_rx_er), .gmii_d(gmii_rx_d), .rgmii_clk(rgmii_rx_clk), .rgmii_ctl(rgmii_rx_ctl), .rgmii_d(rgmii_rxd));
    
    logic gmii_tx_clk, gmii_tx_en;
    logic[7:0] gmii_tx_d;
    rgmii_demux rgmii_demux_inst(.rgmii_clk(rgmii_tx_clk), .rgmii_ctl(rgmii_tx_ctl), .rgmii_d(rgmii_txd), .gmii_clk(gmii_tx_clk), .gmii_en(gmii_tx_en), .gmii_d(gmii_tx_d));
    
    
    initial begin
        gmii_rx_en = 0;
        gmii_rx_er = 0;
        gmii_rx_d = 8'bxxxx_xxxx;
        #(clk_period*200);
        
        forever begin
        
            for(int i=0; i<Ngmii; i++) begin
                gmii_rx_en = 1;
                gmii_rx_d = gmii_frame[i];
                #(clk_period*1);
            end
            
            for(int i=0; i<Ngmii; i++) begin
                gmii_rx_en = 0;
                gmii_rx_d = 8'bxxxx_xxxx;
                #(clk_period*1);
            end
        
        end        
    end
    
    mac_wrapper_top top_inst (        
        .clkin200_p         (clkin200_p),
        .clkin200_n         (clkin200_n),
        .rgmii_rx_clk       (rgmii_rx_clk),
        .rgmii_rxd          (rgmii_rxd),
        .rgmii_rx_ctl       (rgmii_rx_ctl),
        .rgmii_tx_clk       (rgmii_tx_clk),
        .rgmii_txd          (rgmii_txd),
        .rgmii_tx_ctl       (rgmii_tx_ctl),    
        .rgmii_reset_n      (rgmii_reset_n),
        .rgmii_mdio_clock   (rgmii_mdio_clock),
        .rgmii_mdio_data    (rgmii_mdio_data),
        .user_led           (user_led),
        .fan_pwm            (fan_pwm)
    );

endmodule

