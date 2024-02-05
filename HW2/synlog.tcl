history clear
project -load /home/sfs6562/CE495-Digital-design-and-Verification/HW2/proj_1.prj
project_file -remove /home/sfs6562/CE495-Digital-design-and-Verification/HW2/muti.sv
add_file -verilog ./src/matmul.sv
project -run  
project -run  
add_file -verilog ./src/Top.sv
add_file -verilog ./src/bram.sv
project -run  
set_option -frequency 1.000000
set_option -frequency 37
project -run  
project -save /home/sfs6562/CE495-Digital-design-and-Verification/HW2/proj_1.prj 
project -close /home/sfs6562/CE495-Digital-design-and-Verification/HW2/proj_1.prj
