// net_pak.vh - this contains a package of structures for network header metadata.

package ethernet_types_pkg;

typedef struct packed {
    logic [47:0] sender_mac;
    logic [31:0] sender_ip;
} arp_request_t;

endpackage



