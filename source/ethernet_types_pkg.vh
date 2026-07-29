// ethernet_types_pkg.sv - shared type and constant definitions for the ethernet endpoint
// (ARP, ICMP/Ping, UDP). Imported by eth_rx_parser, arp_responder, and downstream
// IP/ICMP/UDP modules.
 
package ethernet_types_pkg;
 
  // ---------------------------------------------------------------
  // EtherType values (in the Ethernet header, big-endian on the wire)
  // ---------------------------------------------------------------
  localparam logic [15:0] ETHERTYPE_IPV4 = 16'h0800;
  localparam logic [15:0] ETHERTYPE_ARP  = 16'h0806;
 
  // ---------------------------------------------------------------
  // ARP opcodes
  // ---------------------------------------------------------------
  localparam logic [15:0] ARP_OPCODE_REQUEST = 16'h0001;
  localparam logic [15:0] ARP_OPCODE_REPLY   = 16'h0002;
 
  // ARP hardware/protocol type constants, useful if a module wants to build
  // a fully-formed ARP reply packet from scratch.
  localparam logic [15:0] ARP_HTYPE_ETHERNET = 16'h0001;
  localparam logic [15:0] ARP_PTYPE_IPV4     = 16'h0800;
  localparam logic [7:0]  ARP_HLEN_ETHERNET  = 8'h06;
  localparam logic [7:0]  ARP_PLEN_IPV4      = 8'h04;
 
  // ---------------------------------------------------------------
  // IPv4 protocol numbers (IP header "protocol" field)
  // ---------------------------------------------------------------
  localparam logic [7:0] IP_PROTO_ICMP = 8'd1;
  localparam logic [7:0] IP_PROTO_UDP  = 8'd17;
 
  // ICMP type/code values used for echo request/reply (ping)
  localparam logic [7:0] ICMP_TYPE_ECHO_REPLY   = 8'd0;
  localparam logic [7:0] ICMP_TYPE_ECHO_REQUEST = 8'd8;
  localparam logic [7:0] ICMP_CODE_ECHO         = 8'd0;
 
  // ---------------------------------------------------------------
  // Parsed ARP packet - single-beat handoff from eth_rx_parser to arp_responder.
  // Only ARP REQUEST packets addressed to our IP are ever produced by the parser,
  // so arp_responder can treat every beat here as "please reply to this".
  // ---------------------------------------------------------------
  typedef struct packed {
    logic [15:0] opcode;      // always ARP_OPCODE_REQUEST as produced by eth_rx_parser
    logic [47:0] sender_mac;  // remote host's MAC  (becomes our reply's target MAC)
    logic [31:0] sender_ip;   // remote host's IP   (becomes our reply's target IP)
    logic [47:0] target_mac;  // usually all-zero in a request; kept for completeness
    logic [31:0] target_ip;   // IP being queried - equals local_ip by construction
  } arp_struct;
 
endpackage : ethernet_types_pkg
 

