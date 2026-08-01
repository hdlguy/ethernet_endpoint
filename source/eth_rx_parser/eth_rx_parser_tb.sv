//
`timescale 1ns/1ps

import ethernet_types_pkg::*;

module eth_rx_parser_tb();

    localparam logic [0:5][7:0] local_mac = 48'h00_0A_35_01_02_03;
    localparam logic [0:3][7:0] local_ip  = 32'h10_00_00_80;    
    localparam logic [0:5][7:0] host_mac  = {8'h94, 8'h10, 8'h3e, 8'hb7, 8'he2, 8'h01};
    localparam logic [0:3][7:0] host_ip   = {8'h10, 8'h00, 8'h00, 8'hc8};
    localparam logic [0:5][7:0] broadcast_mac  = {8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff};

    logic       reset;
    logic       rx_tvalid;
    logic       rx_tready;
    logic [7:0] rx_tdata;
    logic       rx_tlast;
    logic       arp_tvalid;
    logic       arp_tready=0;
    logic[47:0] arp_sha;
    logic[31:0] arp_spa;
    logic[31:0] arp_tpa;
//    arp_struct  arp_tdata;
    logic       ipv4_tvalid;
    logic       ipv4_tready;
    logic [7:0] ipv4_tdata;
    logic       ipv4_tlast;

    localparam time clk_period=10ns; logic clk=1'b0; always #(clk_period/2) clk=~clk; // really 8ns

    eth_rx_parser #(.local_mac(local_mac), .local_ip(local_ip)) uut (.*);

    localparam int arplen = 60;

    logic[0:arplen-1][7:0] arp_req_frame = {
        broadcast_mac, 
        host_mac, 
        8'h08, 8'h06,
        8'h00, 8'h01,
        8'h08, 8'h00,
        8'h06, 8'h04,
        8'h00, 8'h01,
        host_mac,
        host_ip,
        {6{8'h00}},
        local_ip,
        {18{8'h00}}
    };
    
    logic[0:arplen-1][7:0] arp_req_frame2 = {
        broadcast_mac, 
        host_mac, 
        8'h08, 8'h06,
        8'h00, 8'h01,
        8'h08, 8'h00,
        8'h06, 8'h04,
        8'h00, 8'h01,
        host_mac,
        host_ip,
        {6{8'h00}},
        local_ip+1, // doesn't match local ip so arp rejected
        {18{8'h00}}
    };

    initial begin
        reset = 1;
        rx_tvalid = 0;
        rx_tdata = 8'bxxxx_xxxx;
        rx_tlast = 1'bx;
        arp_tready = 0;
        #(clk_period*10);
        reset = 0;
        #(clk_period*10);
        
        forever begin

            for (int i=0; i<arplen; i++) begin
                rx_tvalid = 1;
                rx_tdata = arp_req_frame[i];
                if (i==(arplen-1)) rx_tlast=1; else rx_tlast=0;
                #(clk_period*1);
            end
            rx_tvalid = 0;
            rx_tdata = 8'bxxxx_xxxx;
            rx_tlast = 1'bx;
            #(clk_period*20);

            for (int i=0; i<arplen; i++) begin
                rx_tvalid = 1;
                rx_tdata = arp_req_frame2[i];
                if (i==(arplen-1)) rx_tlast=1; else rx_tlast=0;
                #(clk_period*1);
            end
            rx_tvalid = 0;
            rx_tdata = 8'bxxxx_xxxx;
            rx_tlast = 1'bx;
            #(clk_period*20);
                
        end
        
    end
    
    // acknowledge arp
    always_ff @(posedge clk) begin
        arp_tready <= arp_tvalid;
    end
    
    assign ipv4_tready = 1;
    
endmodule


/*
    logic[0:31][7:0] arp_req_frame = {
        8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 8'hff, 
        8'h00, 8'hd8, 8'h61, 8'h59, 8'h63, 8'h7a, 
        8'h08, 8'h06,         
        8'h00, 8'h01, 
        8'h08, 8'h00, 
        8'h06, 8'h04, 
        8'h00, 8'h01, 
        8'h00, 8'hd8, 8'h61, 8'h59, 8'h63, 8'h7a, 
        8'hc0 8'ha8, 8'h01, 8'hc5,
        8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hc0, 8'ha8, 8'h01, 8'h6f 
    };
*/
    
//ff ff ff ff ff ff 00 d8 61 59 63 7a 08 06 00 01
//08 00 06 04 00 01 00 d8 61 59 63 7a c0 a8 01 c5
//00 00 00 00 00 00 c0 a8 01 6f 00 00 00 00 00 00
//00 00 00 00 00 00 00 00 00 00
    



/*
*/
