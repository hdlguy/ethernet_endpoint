//
`timescale 1ns/1ps

import ethernet_types_pkg::*;

module eth_tx_tb();

    localparam logic [47:0] local_mac       = 48'h00_0A_35_01_02_03;
    localparam logic [31:0] local_ip        = 32'h10_00_00_80;    
    localparam logic [47:0] host_mac        = 48'h94_10_3e_b7_e2_01;
    localparam logic [31:0] host_ip         = 32'h10_00_00_c8;
    localparam logic [47:0] broadcast_mac   = 48'hff_ff_ff_ff_ff_ff;

    logic       reset;
    logic       arp_tvalid=0;
    logic       arp_tready;
    arp_struct  arp_tdata;
    logic        ping_tvalid=0;
    logic        ping_tready;
    ping_struct ping_tdata;
    logic       ipv4_tvalid;
    logic       ipv4_tready;
    logic[7:0]  ipv4_tdata;
    logic       ipv4_tlast;
    logic       tx_tvalid;
    logic       tx_tready=1;
    logic[7:0]  tx_tdata;
    logic       tx_tlast;

    localparam time clk_period=10ns; logic clk=1'b0; always #(clk_period/2) clk=~clk; // really 8ns

    eth_tx #(.local_mac(local_mac), .local_ip(local_ip)) uut (.*);
    
    assign ipv4_tvalid = 0;
    assign ipv4_tdata = 0;
    assign ipv4_tlast = 0;
    
    assign arp_tdata.sha = host_mac;
    assign arp_tdata.spa = host_ip;
    assign arp_tdata.tpa = local_ip;    
    
    assign ping_tdata.sha = host_mac;
    assign ping_tdata.spa = host_ip;
    assign ping_tdata.tpa = local_ip;
    assign ping_tdata.id  = 16'h5748;
    assign ping_tdata.seq = 16'h0010;
    assign ping_tdata.ts  = 128'h9d_cd_71_6a_00_00_00_00_a2_41_0c_00_00_00_00_00;
    
    logic arp_trig, ping_trig;
    initial begin

        reset = 1;
        arp_trig = 0;
        ping_trig = 0;
        #(clk_period*10);
        reset = 0;
        #(clk_period*10);
        
        forever begin
            arp_trig = 1;
            #(clk_period*1);
            arp_trig = 0;
            #(clk_period*150);
            
            ping_trig = 1;
            #(clk_period*1);
            ping_trig = 0;
            #(clk_period*150);            
        end

    end
    
    always_ff @(posedge clk) begin
    
//        tx_tready <= ~tx_tready;
        tx_tready <= 1;
        
        if (arp_trig) begin
            arp_tvalid <= 1;
        end else begin
            if (arp_tready) arp_tvalid <= 0;
        end
        
        if (ping_trig) begin
            ping_tvalid <= 1;
        end else begin
            if (ping_tready) ping_tvalid <= 0;
        end
                
    end    
    
endmodule

