history clear
project -load /home/sfs6562/CE495-Digital-design-and-Verification/HW1/proj_1.prj
set_option -result_file /home/sfs6562/CE495-Digital-design-and-Verification/HW1/rev_1/fibonacci_tb.vqm
set_option -resultformat vqm
set_option -technology CYCLONEIV-E
set_option -quartus_version 18.1
set_option -write_verilog 1
project -run synthesis -clean 
project -save /home/sfs6562/CE495-Digital-design-and-Verification/HW1/proj_1.prj 
project -run synthesis_check /home/sfs6562/CE495-Digital-design-and-Verification/HW1/sv/fibonacci.sv
project -run synthesis_check /home/sfs6562/CE495-Digital-design-and-Verification/HW1/sv/fibonacci.sv
project -run  
text_select 10 4 18 32
text_select 41 95 42 1
text_select 43 1 45 15
text_select 64 10 64 28
text_select 79 24 81 1
text_select 152 83 152 99
text_select 229 109 230 1
project_file -remove /home/sfs6562/CE495-Digital-design-and-Verification/HW1/sv/fibonacci_tb.sv
project -run  
project -save /home/sfs6562/CE495-Digital-design-and-Verification/HW1/proj_1.prj 
project -close /home/sfs6562/CE495-Digital-design-and-Verification/HW1/proj_1.prj
