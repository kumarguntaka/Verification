/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class generator;

rand transaction trans, tr;

mailbox gen2driv;

int repeat_count;

event ended;

function new(mailbox gen2driv, event ended);
	this.gen2driv=gen2driv;
	this.ended=ended;
	trans=new();
endfunction

task main();
	repeat(repeat_count) begin
		if(!trans.randomize) $fatal("GEN::Failed to Randomize!");
		tr=trans.do_copy();
		gen2driv.put(tr);
	end
	->ended;
endtask

endclass