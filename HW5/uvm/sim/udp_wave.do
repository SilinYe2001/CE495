

#add wave -noupdate -group my_uvm_tb
#add wave -noupdate -group my_uvm_tb -radix hexadecimal /my_uvm_tb/*


add wave -noupdate -group my_uvm_tb/udp_top
add wave -noupdate -group my_uvm_tb/udp_top -radix decimal /my_uvm_tb/udp_top/*
add wave -noupdate -group my_uvm_tb/udp_top/fifo_ctrl
add wave -noupdate -group my_uvm_tb/udp_top/fifo_ctrl -radix decimal /my_uvm_tb/udp_top/fifo_ctrl/*
add wave -noupdate -group my_uvm_tb/udp_top/read_data
add wave -noupdate -group my_uvm_tb/udp_top/read_data -radix hexadecimal /my_uvm_tb/udp_top/read_data/*
add wave -noupdate -group my_uvm_tb/udp_top/fifo_data_out
add wave -noupdate -group my_uvm_tb/udp_top/fifo_data_out -radix decimal /my_uvm_tb/udp_top/fifo_data_out/*