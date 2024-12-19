/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class scoreboard;

mailbox mon2scb;

int no_transactions;

function new(mailbox mon2scb);
	this.mon2scb=mon2scb;
endfunction

task main;
	transaction trans;
	forever begin
		mon2scb.get(trans);
		if((trans.a+trans.b)==trans.c)
			$display("Result is as Expected");
		else
			$error("Wrong Result. \n\tExpected: %0d Actual: %0d, (trans.a+trans.b), trans.c");
		no_transactions++
		trans.display("Scoreboard");
	end
endtask

endclass