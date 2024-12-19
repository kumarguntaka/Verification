-timescale=1ns/1ns +vcs+flush+all +warn=all -sverilog

vcs -licqueue '-timescale=1ns/1ns' '+vcs+flush+all' '+warn=all' '-sverilog' design.sv testbench.sv  && ./simv +vcs+lic+wait