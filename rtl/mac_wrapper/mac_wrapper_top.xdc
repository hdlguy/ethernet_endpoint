create_clock -period 5.000 -name clkin200_p   -waveform {0.00 2.50}  [get_ports clkin200_p]
create_clock -period 8.000 -name rgmii_rx_clk -waveform {0.00 4.00}  [get_ports rgmii_rx_clk]

set_property IOSTANDARD DIFF_HSTL_I_12  [get_ports {clkin200_*}]
set_property ODT RTT_NONE               [get_ports {clkin200_*}]
set_property PACKAGE_PIN AE5            [get_ports clkin200_p]
set_property PACKAGE_PIN AF5            [get_ports clkin200_n]

set_property IOSTANDARD LVCMOS33    [get_ports user_led]
set_property PACKAGE_PIN AE12       [get_ports user_led]

set_property IOSTANDARD LVCMOS18    [get_ports rgmii_*]
#set_property PACKAGE_PIN E8         [get_ports rgmii_tx_clk]  ;# ?????????? A7
set_property PACKAGE_PIN A7         [get_ports rgmii_tx_clk]  ;# ?????????? A7
set_property PACKAGE_PIN A8         [get_ports rgmii_txd[3]]
set_property PACKAGE_PIN A9         [get_ports rgmii_txd[2]]
set_property PACKAGE_PIN D9         [get_ports rgmii_txd[1]]
set_property PACKAGE_PIN E9         [get_ports rgmii_txd[0]]
set_property PACKAGE_PIN B9         [get_ports rgmii_tx_ctl]
                         
set_property PACKAGE_PIN E5         [get_ports rgmii_rx_clk]
set_property PACKAGE_PIN C9         [get_ports rgmii_rxd[3]]
set_property PACKAGE_PIN F8         [get_ports rgmii_rxd[2]]
set_property PACKAGE_PIN B5         [get_ports rgmii_rxd[1]]
set_property PACKAGE_PIN A5         [get_ports rgmii_rxd[0]]
set_property PACKAGE_PIN B8         [get_ports rgmii_rx_ctl]

set_property IOB TRUE               [get_ports rgmii_rxd[*]]
set_property IOB TRUE               [get_ports rgmii_rx_ctl]

set_property PACKAGE_PIN D5         [get_ports rgmii_reset_n]
set_property PACKAGE_PIN A6         [get_ports rgmii_mdio_clock]
set_property PACKAGE_PIN C8         [get_ports rgmii_mdio_data]



##################################

 
#set_property PACKAGE_PIN A6 [get_ports {mdio_mdc                    }]
#set_property PACKAGE_PIN C8 [get_ports {mdio_mdio_io            }]
#set_property PACKAGE_PIN D5 [get_ports {phy_reset_n                  }]
#set_property PACKAGE_PIN E5 [get_ports {rgmii_rxc                  }]
#set_property PACKAGE_PIN B8 [get_ports {rgmii_rx_ctl            }]
#set_property PACKAGE_PIN A5 [get_ports {rgmii_rd[0]              }]
#set_property PACKAGE_PIN B5 [get_ports {rgmii_rd[1]              }]
#set_property PACKAGE_PIN F8 [get_ports {rgmii_rd[2]              }]
#set_property PACKAGE_PIN C9 [get_ports {rgmii_rd[3]              }]
#set_property PACKAGE_PIN A7 [get_ports {rgmii_txc                  }]
#set_property PACKAGE_PIN B9 [get_ports {rgmii_tx_ctl            }]
#set_property PACKAGE_PIN E9 [get_ports {rgmii_td[0]              }]
#set_property PACKAGE_PIN D9 [get_ports {rgmii_td[1]              }]
#set_property PACKAGE_PIN A9 [get_ports {rgmii_td[2]              }]
#set_property PACKAGE_PIN A8 [get_ports {rgmii_td[3]              }]

#set_property IOSTANDARD LVCMOS18 [get_ports {mdio_mdc                    }]
#set_property IOSTANDARD LVCMOS18 [get_ports {mdio_mdio_io            }]
#set_property IOSTANDARD LVCMOS18 [get_ports {phy_reset_n                  }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rxc                  }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rx_ctl            }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rd[0]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rd[1]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rd[2]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_rd[3]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_txc                  }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_tx_ctl            }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_td[0]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_td[1]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_td[2]              }]
#set_property IOSTANDARD LVCMOS18 [get_ports {rgmii_td[3]              }]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports mdio_mdio_io]


##idelay
#set_property DELAY_VALUE 500 [get_cells design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/delay_rgmii_rx_ctl]
#set_property DELAY_VALUE 500 [get_cells {design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[0].delay_rgmii_rxd}]
#set_property DELAY_VALUE 500 [get_cells {design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[1].delay_rgmii_rxd}]
#set_property DELAY_VALUE 500 [get_cells {design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[2].delay_rgmii_rxd}]
#set_property DELAY_VALUE 500 [get_cells {design_1_i/axi_ethernet_0/inst/mac/inst/tri_mode_ethernet_mac_i/rgmii_interface/rxdata_bus[3].delay_rgmii_rxd}]
~                                                                                                                                       
~                                                                                                                                       
~                                     
