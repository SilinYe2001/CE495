setenv LMC_TIMEUNIT -9
vlib work
vmap work work
# compile 
vlog -work work "../sv/fifo.sv"
vlog -work work "../sv/fifo_ctrl.sv"
#vlog -work work "../sv/parameters.sv"
vlog -work work "../sv/read_data.sv"
vlog -work work "../sv/udp_tb.sv"
vlog -work work "../sv/udp_top.sv"


# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.udp_tb -wlf udp_tb.wlf
# wave
add wave -noupdate -group udp_tb/
add wave -noupdate -group udp_tb/ -radix decimal /udp_tb/*
add wave -noupdate -group udp_tb/udp_top
add wave -noupdate -group udp_tb/udp_top -radix decimal /udp_tb/udp_top/*
add wave -noupdate -group udp_tb/udp_top/fifo_ctrl
add wave -noupdate -group udp_tb/udp_top/fifo_ctrl -radix decimal /udp_tb/udp_top/fifo_ctrl/*
add wave -noupdate -group udp_tb/udp_top/read_data
add wave -noupdate -group udp_tb/udp_top/read_data -radix hexadecimal /udp_tb/udp_top/read_data/*
add wave -noupdate -group udp_tb/udp_top/fifo_data_out
add wave -noupdate -group udp_tb/udp_top/fifo_data_out -radix decimal /udp_tb/udp_top/fifo_data_out/*

run -all
