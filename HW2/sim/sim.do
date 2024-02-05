setenv LMC_TIMEUNIT -9
vlib work
vmap work work
# compile 
vlog -work work "../src/bram.sv"
vlog -work work "../src/matmul.sv"
vlog -work work "../src/Top.sv"
vlog -work work "../src/matmul_tb.sv"
# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.matmul_tb -wlf matmul_tb.wlf
# wave
add wave -noupdate -group matmul_tb
add wave -noupdate -group matmul_tb -radix hexadecimal /matmul_tb/*
add wave -noupdate -group matmul_tb/Top/matmul_instance
add wave -noupdate -group matmul_tb/Top/matmul_instance -radix hexadecimal /matmul_tb/Top/matmul_instance/*
run -all