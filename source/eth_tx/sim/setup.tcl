# This script sets up a Vivado project with all ip references resolved.
close_project -quiet
file delete -force proj.xpr *.os *.jou *.log proj.srcs proj.cache proj.runs
#
create_project -part xczu2cg-sfvc784-1-e -force proj
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]

add_file ../../ethernet_types_pkg.sv
read_verilog -sv ../eth_tx.sv
read_verilog -sv ../eth_tx_tb.sv

add_files -fileset sim_1 -norecurse ./eth_tx_tb_behav.wcfg

close_project

#########################



