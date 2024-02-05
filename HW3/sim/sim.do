setenv LMC_TIMEUNIT -9
vlib work
vmap work work
# compile 
vlog -work work "../src/Wrapper_tb.sv"
vlog -work work "../src/motion_detect_top_wrapper.sv"
vlog -work work "../src/highlight.sv"
vlog -work work "../src/highlight_top.sv"
vlog -work work "../src/vectorsub/fifo.sv"
vlog -work work "../src/vectorsub/vectorsub_top.sv"
vlog -work work "../src/vectorsub/vectorsub.sv"
vlog -work work "../src/grayscale/grayscale_top.sv"
vlog -work work "../src/grayscale/grayscale.sv"

# run simulation
vsim -classdebug -voptargs=+acc +notimingchecks -L work work.Wrapper_tb -wlf Wrapper_tb.wlf
# wave
add wave -noupdate -group Wrapper_tb/uut
add wave -noupdate -group Wrapper_tb/uut -radix hexadecimal /Wrapper_tb/uut/*
add wave -noupdate -group Wrapper_tb/uut/vectorsub_top_instance
add wave -noupdate -group Wrapper_tb/uut/vectorsub_top_instance -radix hexadecimal /Wrapper_tb/uut/vectorsub_top_instance/*
add wave -noupdate -group Wrapper_tb/uut/highlight_top_instance
add wave -noupdate -group Wrapper_tb/uut/highlight_top_instance -radix hexadecimal /Wrapper_tb/uut/highlight_top_instance/*
add wave -noupdate -group Wrapper_tb/uut/highlight_top_instance/highlight_instance
add wave -noupdate -group Wrapper_tb/uut/highlight_top_instance/highlight_instance -radix hexadecimal /Wrapper_tb/uut/highlight_top_instance/highlight_instance/*
run -all