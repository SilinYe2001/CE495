history clear
project -load "/home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/FM Radio/proj_1.prj"
project -close "/home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/FM Radio/proj_1.prj"
project -load /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_2.prj
project -run  
project -new /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_1.prj
project -save /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_1.prj 
project_data -active /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_2.prj
project -close /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_2.prj
add_file -verilog ../uvm/sv/cordic.sv
add_file -verilog ../uvm/sv/cordic_stage.sv
add_file -verilog ../uvm/sv/cordic_top.sv
add_file -verilog ../uvm/sv/fifo.sv
project -run  
project -save /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_1.prj 
project -close /home/sfs6562/CE495-Digital-design-and-Verification-with-FPGA/HW6/synplify/proj_1.prj
