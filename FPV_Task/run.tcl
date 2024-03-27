set_fml_appmode FPV

set design fsm

read_file -top $design -format sverilog -sva \
  -vcs {../design/fsm.sv +define+INLINE_SVA}

create_clock clk -period 100
create_reset rst_n -sense high

sim_run -stable
sim_save_reset