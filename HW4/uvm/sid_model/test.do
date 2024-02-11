setenv LMC_TIMEUNIT -9
vlib work
vmap work work
# compile 
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/grayscale.sv"
vlog -work work "../sv/test_top.sv"
vlog -work work "../sv/padding.sv"
vlog -work work "../sv/test_tb.sv"
#vlog -work work "../sv/shift_reg.sv"
#vlog -work work "../sv/sobel_filter.sv"
#vlog -work work "../sv/sobel.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.test_tb -wlf test_tb.wlf
# wave
add wave -noupdate -group test_tb/
add wave -noupdate -group test_tb/ -radix decimal /test_tb/*
add wave -noupdate -group test_tb/edge_detect
add wave -noupdate -group test_tb/edge_detect -radix hexadecimal /test_tb/edge_detect/*
add wave -noupdate -group test_tb/edge_detect/pad
add wave -noupdate -group test_tb/edge_detect/pad -radix decimal /test_tb/edge_detect/pad/*

run -all