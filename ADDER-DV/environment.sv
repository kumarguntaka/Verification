/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class environment;

generator gen;
driver driv;

monitor mon;
scoreboard scb;

mailbox gen2driv;
mailbox mon2scb;

virtual intf vif;

function new(virtual intf vif);
	this.vif = vif;
	
	gen2driv = new();
	mon2scb = new();
	
	gen = new(gen2driv);
	driv = new(vif,gen2driv);	
	mon = new(vif,mon2scb);	
	driv = new(mon2scb);	
endfunction

task pre_test();
	driv.reset();
endtask

task test();
	fork
		driv.main();
		gen.main();
		mon.main();
		scb.main();
	join_any
endtask

task post_test();
	wait(gen.ended.triggered);
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