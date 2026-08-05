//
module ping_rx (
);

endmodule

/* ping request from workstation 192.168.1.197(C0 A8 01 C5) to 192.168.1.112(C0 A8 01 70)
Ethernet frame
30 05 5c 22 58 43 - printer (destination)
00 d8 61 59 63 7a - linux workstation 00:d8:61:59:63:7a
08 00 - type = ethertype

IP Header
45 - version and header length
00 - servides
00 54 - total length
6c 24 - id
40 00 - flags don't fragment
40 - time to live
01 - protocol ICMP
49 ff - checksum
c0 a8 01 c5 - source address, linux ip
c0 a8 01 70 - destination, printer ip

ICMP
08 - type = ping request
00 - code = 0
24 5b - checksum
57 48 - identifier
00 10 - sequence number
9d cd 71 6a 00 00 00 00  a2 41 0c 00 00 00 00 00 - timestamp
10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37 - data (40 bytes)
*/



/* ping reply to above
00 d8 61 59 63 7a - linux workstation 00:d8:61:59:63:7a
30 05 5c 22 58 43 - printer
08 00 - type = ethertype

45 - version, header length
00 - congestion
00 54 - total length
24 55 - id
00 00 - fragment offset
ff - TTL
01 - protocol = icmp
12 ce - header checksum
c0 a8 01 70 - printer IP
c0 a8 01 c5 - workstation IP

00 - echo reply
00 - code
2c 5b - checksum
57 48 - ID
00 10 - sequence number
9d cd 71 6a 00 00 00 00 a2 41 0c 00 00 00 00 00 - timestamp

10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f 20 21 22 23 24 25 26 27 28 29 2a 2b 2c 2d 2e 2f 30 31 32 33 34 35 36 37 - data (40 bytes)
*/

