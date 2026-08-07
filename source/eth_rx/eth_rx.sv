// eth_rx.sv - this module accepts ethernet frames from mac_wrapper. When it detects an ARP
// request it latches the arp data and signals an arp event. Otherwise, it forwards ipv4 frames.
 
import ethernet_types_pkg::*;
 
module eth_rx #(
    parameter logic[47:0] local_mac,
    parameter logic[31:0] local_ip
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
    output arp_struct   arp_tdata,    
    // parsed PING request - one-beat handoff per matching frame
    output logic        ping_tvalid,
    input  logic        ping_tready,
    output ping_struct  ping_tdata,
//    output logic[47:0]  ping_sha,
//    output logic[31:0]  ping_spa,
//    output logic[31:0]  ping_tpa,    
//    output logic[15:0]  ping_id,
//    output logic[15:0]  ping_seq,    
//    output logic[127:0] ping_ts,
    // ipv4 payload passthrough (Ethernet header stripped)
    output logic        ipv4_tvalid,
    input  logic        ipv4_tready,
    output logic [7:0]  ipv4_tdata,
    output logic        ipv4_tlast
);
 
    localparam logic [47:0] BROADCAST_MAC = 48'hFF_FF_FF_FF_FF_FF;    
    localparam int Narp = 42;  // the number of bytes in an Arp packet.
    localparam int Nping = 98;  // the number of bytes in an ping packet.

    logic[Nping-1:0][7:0] wr_byte = 0; // byte array.
 
    assign rx_tready = 1; // always ready
    
    // rename ethernet header fields
    logic[47:0] dest_mac;
    assign dest_mac = {wr_byte[0], wr_byte[1], wr_byte[2], wr_byte[3], wr_byte[4], wr_byte[5]};    
    logic[47:0] src_mac;
    assign src_mac =  {wr_byte[6], wr_byte[7], wr_byte[8], wr_byte[9], wr_byte[10], wr_byte[11]};    
    logic[15:0] frame_type;
    assign frame_type = {wr_byte[12], wr_byte[13]}; 
    
    // rename arp fields 
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
    
    // rename ping fields
    logic[7:0] ip_type;
    assign ip_type = wr_byte[23];
    logic[7:0] icmp_type;
    assign icmp_type = wr_byte[34];
    logic[31:0] ip_src_ip, ip_dest_ip;
    assign ip_src_ip  = {wr_byte[26], wr_byte[27], wr_byte[28], wr_byte[29]};
    assign ip_dest_ip = {wr_byte[30], wr_byte[31], wr_byte[32], wr_byte[33]};
    logic[15:0] icmp_id;
    assign icmp_id = {wr_byte[38], wr_byte[39]};
    logic[15:0] icmp_seq;
    assign icmp_seq = {wr_byte[40], wr_byte[41]};
    logic[127:0] icmp_ts;
    assign icmp_ts = {wr_byte[42], wr_byte[43], wr_byte[44], wr_byte[45], wr_byte[46], wr_byte[47], wr_byte[48], wr_byte[49], wr_byte[50], wr_byte[51], wr_byte[52], wr_byte[53], wr_byte[54], wr_byte[55], wr_byte[56], wr_byte[57]};
    

    // save input header into byte array
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
    
    
    // detect arp request
    logic arp_cmp;
    assign arp_cmp = ((dest_mac==BROADCAST_MAC) &&  (frame_type==16'h0806) && (tpa==local_ip) && (byte_count>13));
    
    // detect ipv4 
    logic ipv4_cmp;
    assign ipv4_cmp = ((dest_mac==local_mac) && (frame_type==16'h0800) && (byte_count>13));
        
    // detect ping 
    logic ping_cmp;
    assign ping_cmp = ((dest_mac==local_mac) && (frame_type==16'h0800) && (ip_type==8'h01) && (icmp_type==8'h08) && (byte_count>34));
        
    logic dv_in;
    assign dv_in = (rx_tvalid & rx_tready);

    
    // arp handshake
    logic arp_tvalid_int=0;
    always_ff @(posedge clk) begin   
        // latch out arp data and assert tvalid
        if ((dv_in) && (rx_tlast) && (arp_cmp)) begin
                arp_tvalid_int <= 1;
                arp_tdata.sha <= sha;    
                arp_tdata.spa <= spa;    
                arp_tdata.tpa <= tpa;                  
        end
        
        if (arp_tready) arp_tvalid_int <= 0;
        
    end
    assign arp_tvalid = arp_tvalid_int;
    
    

    // ping handshake
    logic ping_tvalid_int=0;
    always_ff @(posedge clk) begin   
        // latch out ping data and assert tvalid
        if ((dv_in) && (rx_tlast) && (ping_cmp)) begin
                ping_tvalid_int <= 1; 
                ping_tdata.sha <= src_mac;
                ping_tdata.spa <= ip_src_ip;
                ping_tdata.tpa <= ip_dest_ip;            
                ping_tdata.id  <= icmp_id;
                ping_tdata.seq <= icmp_seq;
                ping_tdata.ts  <= icmp_ts;  
//                ping_sha <= src_mac;
//                ping_spa <= ip_src_ip;
//                ping_tpa <= ip_dest_ip;            
//                ping_id  <= icmp_id;
//                ping_seq <= icmp_seq;
//                ping_ts  <= icmp_ts;
        end
        
        if (ping_tready) ping_tvalid_int <= 0;
        
    end
    assign ping_tvalid = ping_tvalid_int;    
    
    
    
    // ipv4 passthrough
    logic ipv4_tvalid_int=0;
    logic dv_in_q=0, rx_tlast_q=0;
    always_ff @(posedge clk) begin 
    
        ipv4_tdata <= rx_tdata;
        ipv4_tlast <= rx_tlast;
        
        dv_in_q <= dv_in;
        rx_tlast_q <= rx_tlast;
        
        if ((dv_in_q) && (rx_tlast_q)) begin
            ipv4_tvalid_int <= 0;
        end else begin
            if ((byte_count > 13) && (frame_type == 16'h0800)) begin
                ipv4_tvalid_int <= 1;
            end 
        end        

    end
    assign ipv4_tvalid = ipv4_tvalid_int;
    
 
endmodule
 

