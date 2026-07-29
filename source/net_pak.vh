// net_pak.vh - this contains a package of structures for network header metadata.

package net_pak;

struct {
	logic[0:5][7:0] sender_mac;
	logic[0:3][7:0] sender_ip;
	logic[0:5][7:0] target_mac;
	logic[0:3][7:0] target_ip;
} arp_struct;

endpackage



