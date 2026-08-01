// eth_rx_parser.sv
 
//import ethernet_types_pkg::*;
 
module eth_rx_parser #(
    parameter logic [47:0] local_mac,
    parameter logic [31:0] local_ip
) (
    //
    input  logic clk,
    input  logic reset,    
    // byte stream from mac_wrapper (same clock domain as clk - see header comment)
    input  logic        rx_tvalid,
    output logic        rx_tready,
    input  logic [7:0]  rx_tdata,
    input  logic        rx_tlast,    
    // parsed ARP request - one-beat handoff per matching frame
    output logic        arp_tvalid,
    input  logic        arp_tready,
    output logic[47:0]  arp_sha,
    output logic[31:0]  arp_spa,
    output logic[31:0]  arp_tpa,    
    //output arp_struct   arp_tdata,    
    // ipv4 payload passthrough (Ethernet header stripped)
    output logic        ipv4_tvalid,
    input  logic        ipv4_tready,
    output logic [7:0]  ipv4_tdata,
    output logic        ipv4_tlast
);
 
    localparam logic [47:0] BROADCAST_MAC = 48'hFF_FF_FF_FF_FF_FF;    
    localparam int Narp = 42;  // the number of bytes in an Arp packet.

    logic[Narp-1:0][7:0] wr_byte = 0; // byte array.
 
    assign rx_tready = 1; // always ready
    
    // rename ethernet header fields from rx
    logic[47:0] dest_mac;
    assign dest_mac = {wr_byte[0], wr_byte[1], wr_byte[2], wr_byte[3], wr_byte[4], wr_byte[5]};    
    logic[47:0] src_mac;
    assign src_mac =  {wr_byte[6], wr_byte[7], wr_byte[8], wr_byte[9], wr_byte[10], wr_byte[11]};    
    logic[15:0] frame_type;
    assign frame_type = {wr_byte[12], wr_byte[13]}; 
    
    // rename arp fields. 
    logic[15:0] htype;
    assign htype = {wr_byte[14], wr_byte[15]};
    logic[15:0] ptype;
    assign ptype = {wr_byte[16], wr_byte[17]};
    logic[7:0] hlen;
    assign hlen = wr_byte[18];
    logic[7:0] plen;
    assign plen = wr_byte[19];
    logic[15:0] oper;
    assign oper = {wr_byte[20], wr_byte[21]};    
    logic[47:0] sha;
    assign sha = {wr_byte[22], wr_byte[23], wr_byte[24], wr_byte[25], wr_byte[26], wr_byte[27]};
    logic[31:0] spa;
    assign spa = {wr_byte[28], wr_byte[29], wr_byte[30], wr_byte[31]};
    logic[47:0] tha;
    assign tha = {wr_byte[32], wr_byte[33], wr_byte[34], wr_byte[35], wr_byte[36], wr_byte[37]};
    logic[31:0] tpa;
    assign tpa = {wr_byte[38], wr_byte[39], wr_byte[40], wr_byte[41]};

    
    logic arp_cmp;
    assign arp_cmp = ((dest_mac==BROADCAST_MAC) &&  (frame_type==16'h0806) && (tpa==local_ip));
        
    logic dv_in;
    assign dv_in = (rx_tvalid & rx_tready);
 
    // header parsing
    logic[15:0] byte_count=0;
    always_ff @(posedge clk) begin    
    
        if (dv_in) begin
                    
            if (rx_tlast) begin
                byte_count <= 0;
            end else begin
                byte_count <= byte_count + 1;
            end
            
            wr_byte[byte_count] <= rx_tdata;               
            
        end
        
    end
    
    // arp handshake
    logic arp_tvalid_int=0;
    always_ff @(posedge clk) begin   
        // latch out arp data and assert tvalid
        if ((dv_in) && (rx_tlast) && (arp_cmp)) begin
                arp_tvalid_int <= 1;        
                arp_sha <= sha;
                arp_spa <= spa;
                arp_tpa <= tpa;            
        end
        
        if (arp_tready) arp_tvalid_int <= 0;
        
    end
    assign arp_tvalid = arp_tvalid_int;
    
    // ipv4 passthrough
    logic ipv4_tvalid_int=0;
    always_ff @(posedge clk) begin 
    
        ipv4_tdata <= rx_tdata;
        
        if ((byte_count > 13) && (frame_type == 16'h0800)) begin
            ipv4_tvalid_int <= 1;
        end 
        
        if ((dv_in) && (rx_tlast)) begin
            ipv4_tvalid_int <= 0;
        end
    end
    assign ipv4_tvalid = ipv4_tvalid_int;
    
 
endmodule : eth_rx_parser
 

