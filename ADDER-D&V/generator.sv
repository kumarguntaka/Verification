/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class generator;

rand transaction trans;

mailbox gen2driv;

event ended;

int repeat_count;

function new(mailbox gen2driv);
	this.gen2driv = gen2driv;
endfunction

task main();
	repeat(repeat_count) begin
		trans = new();
		if(!trans.randomize()) 
			$fatal("GEN:: trans randomization failed");
		gen2driv.put(trans);
		trans.display("Generator");
		end
	->ended;
endtask

endclass 