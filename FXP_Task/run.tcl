set_fml_appmode FXP

read_file -top fsm -format sverilog -sva -vcs {../design/fsm.sv}

set_fml_var fxp_compute_rootcause_auto true

create_clock clk -period 100
create_reset rst_n -sense high

sim_run -stable
sim_save_reset

fxp_generate

set_fml_var fxp_compute_rootcause_auto true