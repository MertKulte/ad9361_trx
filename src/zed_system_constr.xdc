
# constraints

# spdif

set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports spdif]

# i2s

set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS33} [get_ports i2s_mclk]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS33} [get_ports i2s_bclk]
set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]
set_property -dict {PACKAGE_PIN Y8 IOSTANDARD LVCMOS33} [get_ports i2s_sdata_out]
set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS33} [get_ports i2s_sdata_in]

# iic

set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS33} [get_ports iic_scl]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports iic_sda]
set_property PACKAGE_PIN AA18 [get_ports {iic_mux_scl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {iic_mux_scl[1]}]
set_property PULLUP true [get_ports {iic_mux_scl[1]}]
set_property PACKAGE_PIN Y16 [get_ports {iic_mux_sda[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {iic_mux_sda[1]}]
set_property PULLUP true [get_ports {iic_mux_sda[1]}]
set_property PACKAGE_PIN AB4 [get_ports {iic_mux_scl[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {iic_mux_scl[0]}]
set_property PULLUP true [get_ports {iic_mux_scl[0]}]
set_property PACKAGE_PIN AB5 [get_ports {iic_mux_sda[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {iic_mux_sda[0]}]
set_property PULLUP true [get_ports {iic_mux_sda[0]}]

# otg

set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS25} [get_ports otg_vbusoc]

# gpio (switches, leds and such)

set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[0]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[1]}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[2]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[3]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[4]}]
set_property -dict {PACKAGE_PIN U10 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[5]}]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[6]}]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[7]}]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[8]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[9]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[10]}]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[11]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[12]}]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[13]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[14]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[15]}]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[16]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[17]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[18]}]

set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[19]}]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[20]}]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[21]}]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[22]}]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[23]}]
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[24]}]
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[25]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {gpio_bd[26]}]

set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[27]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[28]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[29]}]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[30]}]

set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS25} [get_ports {gpio_bd[31]}]

# Define SPI clock
create_clock -period 40.000 -name spi0_clk [get_pins -hier */EMIOSPI0SCLKO]
create_clock -period 40.000 -name spi1_clk [get_pins -hier */EMIOSPI1SCLKO]


create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list i_system_wrapper/system_i/util_ad9361_divclk/inst/clk_out]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[0]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[1]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[2]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[3]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[4]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[5]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[6]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[7]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[8]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[9]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[10]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[11]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[12]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[13]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[14]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 16 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[0]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[1]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[2]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[3]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[4]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[5]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[6]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[7]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[8]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[9]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[10]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[11]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[12]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[13]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[14]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q1[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[0]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[1]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[2]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[3]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[4]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[5]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[6]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[7]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[8]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[9]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[10]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[11]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[12]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[13]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[14]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_q0[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[0]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[1]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[2]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[3]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[4]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[5]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[6]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[7]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[8]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[9]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[10]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[11]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[12]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[13]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[14]} {i_system_wrapper/system_i/ad9361_tx_signal_gen_1_dac_data_i1[15]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out]
