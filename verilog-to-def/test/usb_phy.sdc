###################################################################

# Created by write_sdc on Tue Apr  9 16:04:10 2019

###################################################################
set sdc_version 2.0

set_units -time ps -resistance kOhm -capacitance fF -voltage V -current mA
set_max_area 0
create_clock [get_ports clk]  -period 1500  -waveform {0 750}
set_clock_uncertainty 0  [get_clocks clk]
set_input_delay -clock clk  -max 0  [get_ports clk]
set_input_delay -clock clk  -max 0  [get_ports rst]
set_input_delay -clock clk  -max 0  [get_ports phy_tx_mode]
set_input_delay -clock clk  -max 0  [get_ports rxd]
set_input_delay -clock clk  -max 0  [get_ports rxdp]
set_input_delay -clock clk  -max 0  [get_ports rxdn]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_7_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_6_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_5_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_4_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_3_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_2_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_1_]
set_input_delay -clock clk  -max 0  [get_ports DataOut_i_0_]
set_input_delay -clock clk  -max 0  [get_ports TxValid_i]
set_output_delay -clock clk  -max 0  [get_ports usb_rst]
set_output_delay -clock clk  -max 0  [get_ports txdp]
set_output_delay -clock clk  -max 0  [get_ports txdn]
set_output_delay -clock clk  -max 0  [get_ports txoe]
set_output_delay -clock clk  -max 0  [get_ports TxReady_o]
set_output_delay -clock clk  -max 0  [get_ports RxValid_o]
set_output_delay -clock clk  -max 0  [get_ports RxActive_o]
set_output_delay -clock clk  -max 0  [get_ports RxError_o]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_7_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_6_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_5_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_4_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_3_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_2_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_1_]
set_output_delay -clock clk  -max 0  [get_ports DataIn_o_0_]
set_output_delay -clock clk  -max 0  [get_ports LineState_o_1_]
set_output_delay -clock clk  -max 0  [get_ports LineState_o_0_]
