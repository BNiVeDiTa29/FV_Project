set_fml_appmode COV

set design fsm

read_file -top $design -format sverilog \
		-sva -vcs {../design/fsm.sv} -cov all

create_clock clk -period 100
create_reset rst_n -sense high

sim_run -stable
sim_save_reset

set_fml_var fml_cov_gen_trace on