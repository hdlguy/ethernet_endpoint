# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -part xc7a100tcsg324-2 -force proj
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

#read_ip ../eth_ila/eth_ila.xci
#upgrade_ip -quiet  [get_ips *]
#generate_target {all} [get_ips *]

read_verilog ../../../third_party/verilog-ethernet/rtl/iddr.v
read_verilog ../../../third_party/verilog-ethernet/rtl/lfsr.v
read_verilog ../../../third_party/verilog-ethernet/rtl/ssio_ddr_in.v
read_verilog ../../../third_party/verilog-ethernet/rtl/oddr.v
read_verilog ../../../third_party/verilog-ethernet/rtl/axis_gmii_rx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/axis_gmii_tx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/mac_ctrl_tx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/mac_ctrl_rx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/mac_pause_ctrl_tx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/mac_pause_ctrl_rx.v
read_verilog ../../../third_party/verilog-ethernet/rtl/eth_mac_1g_rgmii.v
read_verilog ../../../third_party/verilog-ethernet/rtl/rgmii_phy_if.v
read_verilog ../../../third_party/verilog-ethernet/rtl/eth_mac_1g.v

read_verilog -sv ../mac_wrapper.sv
read_verilog -sv ../raw_frame_gen.sv
read_verilog -sv ../mac_wrapper_tb.sv

add_files -fileset sim_1 -norecurse ./mac_wrapper_tb_behav.wcfg

close_project

#########################



