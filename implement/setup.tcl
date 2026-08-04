# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -part xczu2cg-sfvc784-1-e -force proj
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

source ../source/endpoint_ila.tcl
source ../source/mac_wrapper/mac_ila.tcl

read_verilog ../third_party/verilog-ethernet/rtl/iddr.v
read_verilog ../third_party/verilog-ethernet/rtl/lfsr.v
read_verilog ../third_party/verilog-ethernet/rtl/ssio_ddr_in.v
read_verilog ../third_party/verilog-ethernet/rtl/oddr.v
read_verilog ../third_party/verilog-ethernet/rtl/axis_gmii_rx.v
read_verilog ../third_party/verilog-ethernet/rtl/axis_gmii_tx.v
read_verilog ../third_party/verilog-ethernet/rtl/mac_ctrl_tx.v
read_verilog ../third_party/verilog-ethernet/rtl/mac_ctrl_rx.v
read_verilog ../third_party/verilog-ethernet/rtl/mac_pause_ctrl_tx.v
read_verilog ../third_party/verilog-ethernet/rtl/mac_pause_ctrl_rx.v
read_verilog ../third_party/verilog-ethernet/rtl/eth_mac_1g_rgmii.v
read_verilog ../third_party/verilog-ethernet/rtl/rgmii_phy_if.v
read_verilog ../third_party/verilog-ethernet/rtl/eth_mac_1g.v

read_verilog -sv ../source/ethernet_types_pkg.sv

read_verilog -sv ../source/mac_wrapper/axis_fifo.sv
read_verilog -sv ../source/mac_wrapper/mac_wrapper.sv

read_verilog -sv ../source/eth_rx/eth_rx.sv
read_verilog -sv ../source/eth_tx/eth_tx.sv

read_verilog -sv ../source/endpoint.sv
read_verilog -sv ../source/endpoint_top.sv

read_xdc ../source/endpoint_top.xdc

close_project

#########################



