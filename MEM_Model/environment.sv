/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;

virtual mem_intf mem_vif;

mailbox gen2driv;
mailbox mon2scb;

generator gen;
driver driv;
monitor mon;
scoreboard scb;

event gen_ended;

function new(virtual mem_intf mem_vif);
	this.mem_vif=mem_vif;
	gen2driv=new();
	mon2scb=new();
	gen=new(gen2driv,gen_ended);
	driv=new(mem_vif,gen2driv);
	mon=new(mem_vif,mon2scb);
	scb=new(mon2scb);
endfunction

task pre_test();
	driv.reset;
endtask

task test();
	fork
		gen.main();
		driv.main();
		mon.main();
		scb.main();
	join_any
endtask

task post_test();
	wait(gen_ended.triggered);
	wait(gen.repeat_count==driv.no_transactions);
	wait(gen.repeat_count==scb.no_transactions);
endtask

task run;
	pre_test();
	test();
	post_test();
	$finish;
endtask

endclass