
`timescale 100ps/1ps;

module mac_wrapper_tb ();

    logic       clkin200_p;
    logic       clkin200_n;
    
    logic       refclk;
    logic       user_clk;
    logic       user_reset;
    
    logic       rgmii_rx_clk;
    logic[3:0]  rgmii_rxd;
    logic       rgmii_rx_ctl;
    logic       rgmii_tx_clk;
    logic[3:0]  rgmii_txd;
    logic       rgmii_tx_ctl;
    logic       rgmii_reset_n;
    
    logic       tx_clk;
    logic[7:0]  tx_tdata=0;
    logic       tx_tvalid=0;
    logic       tx_tready;
    logic       tx_tlast;
    
    logic       rx_clk;
    logic[7:0]  rx_tdata;
    logic       rx_tvalid;
    logic       rx_tready;
    logic       rx_tlast;
    
    
    localparam time clk_period=50; logic clk=0; always #(clk_period/2) clk=~clk;
    assign clkin200_p = clk;
    assign clkin200_n = ~clk;
    
    assign tx_clk = user_clk;
    assign rx_clk = user_clk;
    
    assign rx_tready = 1;
    
    // loop back the rgmii
    assign rgmii_rx_clk = rgmii_tx_clk;
    assign rgmii_rx_ctl = rgmii_tx_ctl;
    assign rgmii_rxd    = rgmii_txd;

    mac_wrapper uut (.*);

    localparam int Lframe = 64;
    raw_frame_gen #(.Lframe(Lframe)) gen_inst (.reset(user_reset), .clk(tx_clk), .tvalid(tx_tvalid), .tready(tx_tready), .tdata(tx_tdata), .tlast(tx_tlast));
    
endmodule

