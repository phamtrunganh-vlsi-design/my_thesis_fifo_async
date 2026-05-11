#!/bin/bash

# Compile
iverilog -g2012 -I../sim -o ../async_fifo_tb *.v ../sim/async_fifo_unit_test.sv ../sim/svut_h.sv
if [ $? -ne 0 ]; then
    echo "Compile failed!"
    exit 1
fi

# Run
vvp ../async_fifo_tb
if [ $? -ne 0 ]; then
    echo "Simulation failed!"
    exit 1
fi

# Open GTKWave  
gtkwave async_fifo_unit_test.vcd

