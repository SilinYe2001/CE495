setenv LMC_TIMEUNIT -9
vlib work
vmap work work
# compile 
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/grayscale.sv"
vlog -work work "../sv/grayscale_top.sv"
vlog -work work "../sv/padding.sv"
vlog -work work "../sv/grayscale_tb.sv"
vlog -work work "../sv/shift_reg.sv"
vlog -work work "../sv/sobel_filter.sv"
vlog -work work "../sv/sobel.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.grayscale_tb -wlf grayscale_tb.wlf
# wave
add wave -noupdate -group grayscale_tb/
add wave -noupdate -group grayscale_tb/ -radix decimal /grayscale_tb/*
add wave -noupdate -group grayscale_tb/edge_detect
add wave -noupdate -group grayscale_tb/edge_detect -radix hexadecimal /grayscale_tb/edge_detect/*
add wave -noupdate -group grayscale_tb/edge_detect/pad
add wave -noupdate -group grayscale_tb/edge_detect/pad -radix decimal /grayscale_tb/edge_detect/pad/*
add wave -noupdate -group grayscale_tb/edge_detect/sobel
add wave -noupdate -group grayscale_tb/edge_detect/sobel -radix decimal /grayscale_tb/edge_detect/sobel/*
add wave -noupdate -group grayscale_tb/edge_detect/sobel/shift_reg
add wave -noupdate -group grayscale_tb/edge_detect/sobel/shift_reg -radix hexadecimal /grayscale_tb/edge_detect/sobel/shift_reg/*
add wave -noupdate -group grayscale_tb/edge_detect/sobel/sobel_filter
add wave -noupdate -group grayscale_tb/edge_detect/sobel/sobel_filter -radix hexadecimal /grayscale_tb/edge_detect/sobel/sobel_filter/*
run -all