

#add wave -noupdate -group my_uvm_tb
#add wave -noupdate -group my_uvm_tb -radix hexadecimal /my_uvm_tb/*


add wave -noupdate -group my_uvm_tb/cordic_top
add wave -noupdate -group my_uvm_tb/cordic_top -radix decimal /my_uvm_tb/cordic_top/*
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_radin
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_radin -radix decimal /my_uvm_tb/cordic_top/fifo_radin/*
add wave -noupdate -group my_uvm_tb/cordic_top/cordic
add wave -noupdate -group my_uvm_tb/cordic_top/cordic -radix hexadecimal /my_uvm_tb/cordic_top/cordic/*
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_cos
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_cos -radix decimal /my_uvm_tb/cordic_top/fifo_cos/*
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_sin
add wave -noupdate -group my_uvm_tb/cordic_top/fifo_sin -radix decimal /my_uvm_tb/cordic_top/fifo_sin/*