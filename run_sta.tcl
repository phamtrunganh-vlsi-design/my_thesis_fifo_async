rootread_liberty lib/sky130_fd_sc_hd__tt_025C_1v80.lib
read_verilog async_fifo_sta.v
link_design async_fifo

read_sdc async_fifo_frequency.sdc

set_clock_groups -asynchronous \
  -group [get_clocks WCLK] \
  -group [get_clocks RCLK]

report_checks -path_delay max
report_power
