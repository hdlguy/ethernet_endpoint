//
`timescale 1ns/1ps

import ethernet_types_pkg::*;

module eth_rx_tb();

    localparam logic [47:0] local_mac = 48'h00_0A_35_01_02_03;
    localparam logic [31:0] local_ip  = 32'h10_00_00_80;    
    localparam logic [47:0] host_mac  = {8'h94, 8'h10, 8'h3e, 8'hb7, 8'he2, 8'h01};
    localparam logic [31:0] host_ip   = {8'h10, 8'h00, 8'h00, 8'hc8};
    localparam logic [47:0] broadcast_mac  = {8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff};

    logic       reset;
    logic       arp_tvalid=0;
    logic       arp_tready;
    logic[47:0] arp_sha;
    logic[31:0] arp_spa;
    logic[31:0] arp_tpa;
    logic       ipv4_tvalid;
    logic       ipv4_tready;
    logic[7:0]  ipv4_tdata;
    logic       ipv4_tlast;
    logic       tx_tvalid;
    logic       tx_tready;
    logic[7:0]  tx_tdata;
    logic       tx_tlast;    

    localparam time clk_period=10ns; logic clk=1'b0; always #(clk_period/2) clk=~clk; // really 8ns

    eth_tx #(.local_mac(local_mac), .local_ip(local_ip)) uut (.*);
    
    assign arp_sha = host_mac;
    assign arp_spa = host_ip;
    assign arp_tpa = local_ip;
    
    logic arp_trig;
    initial begin
        reset = 1;
        arp_trig = 0;
        #(clk_period*10);
        reset = 0;
        #(clk_period*10);
        
        forever begin
            arp_trig = 1;
            #(clk_period*1);
            arp_trig = 0;
            #(clk_period*100);
        end                        
    end
    
    always_ff @(posedge clk) begin
        if (arp_trig) begin
            arp_tvalid <= 1;
        end else begin
            if (arp_tready) arp_tvalid <= 0;
        end
    end    
    
endmodule    
