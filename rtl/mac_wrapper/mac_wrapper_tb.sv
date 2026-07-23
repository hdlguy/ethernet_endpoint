
`timescale 100ps/1ps;

module mac_wrapper_tb ();

    logic       clkin200_p;
    logic       clkin200_n;
    
    logic       refclk200;
    logic       userclk125;
    
    logic       rgmii_rx_clk;
    logic[3:0]  rgmii_rxd;
    logic       rgmii_rx_ctl;
    logic       rgmii_tx_clk;
    logic[3:0]  rgmii_txd;
    logic       rgmii_tx_ctl;
    
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
    
    
    localparam time clk_period=50; logic clk=0; always #(clk_period/2) clk=~clk;
    assign clkin200_p = clk;
    assign clkin200_n = ~clk;
    
    // loop back the rgmii
    assign rgmii_rx_clk = rgmii_tx_clk;
    assign rgmii_rx_ctl = rgmii_tx_ctl;
    assign rgmii_rxd    = rgmii_txd;

    mac_wrapper uut (.*);
    
    localparam int Nframe = 64;
    always_ff @(posedge tx_clk) begin
        
        if (tx_rst) begin
            tx_tvalid <= 0;
            tx_tdata <= 0;
        end else begin            
            tx_tvalid <= 1;
            if ((tx_tvalid==1) && (tx_tready==1)) tx_tdata <= tx_tdata + 1;
        end
        
    end
    
    assign tx_tlast  = (tx_tdata%Nframe == (Nframe-1)) ? 1'b1 : 1'b0;
			


endmodule