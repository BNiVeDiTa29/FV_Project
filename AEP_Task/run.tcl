set_fml_appmode AEP

set_fml_var fml_aep_unique_name true
read_file -top fsm -format sverilog -aep all -vcs {../design/fsm.sv}

create_clock clk -period 100
create_reset rst_n -sense high

sim_run -stable
sim_save_reset
