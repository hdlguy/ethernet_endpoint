//
package ethernet_types_pkg;
 
    // EtherType values (in the Ethernet header, big-endian on the wire)
    localparam logic [15:0] ETHERTYPE_IPV4 = 16'h0800;
    localparam logic [15:0] ETHERTYPE_ARP  = 16'h0806;
    
    // ARP opcodes
    localparam logic [15:0] ARP_OPCODE_REQUEST = 16'h0001;
    localparam logic [15:0] ARP_OPCODE_REPLY   = 16'h0002;
    
    // ARP hardware/protocol type constants
    localparam logic [15:0] ARP_HTYPE_ETHERNET = 16'h0001;
    localparam logic [15:0] ARP_PTYPE_IPV4     = 16'h0800;
    localparam logic [7:0]  ARP_HLEN_ETHERNET  = 8'h06;
    localparam logic [7:0]  ARP_PLEN_IPV4      = 8'h04;
    
    // IPv4 protocol numbers (IP header "protocol" field)
    localparam logic [7:0] IP_PROTO_ICMP = 8'h01;
    localparam logic [7:0] IP_PROTO_UDP  = 8'h11;
    
    // ICMP type/code values used for echo request/reply (ping)
    localparam logic [7:0] ICMP_TYPE_ECHO_REPLY   = 8'h00;
    localparam logic [7:0] ICMP_TYPE_ECHO_REQUEST = 8'h08;
    localparam logic [7:0] ICMP_CODE_ECHO         = 8'h00;
 
    // data needed for arp reply
    typedef struct packed {  
        logic[47:0]  sha; // sender hardware address
        logic[31:0]  spa; // sender protocol address
        logic[31:0]  tpa; // target protocol address
    } arp_struct;
    
    // data needed for ping reply
    typedef struct packed {  
        logic[47:0]  sha;
        logic[31:0]  spa;
        logic[31:0]  tpa;    
        logic[15:0]  id;  // icmp id
        logic[15:0]  seq; // icmp sequence number
        logic[127:0] ts;  // icmp time stamp
    } ping_struct;
 
 
endpackage
 

