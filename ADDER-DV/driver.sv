/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class driver;

virtual intf vif;

mailbox gen2driv;

int no_transactions;

function new(virtual intf vif, mailbox gen2driv);
	this.vif=vif;
	this.gen2driv=gen2driv;
endfunction

task reset;
	wait(vif.rst);
	$display("[RESET] ---- Reset Started ----");
	vif.a<=0;
	vif.b<=0;
	vif.valid<=0;
	wait(!vif.rst);
	$display("[RESET] ---- Reset Ended ----");
endtask

task main;
	forever begin
		transacrion	trans;
		gen2driv.get(trans);
		@(posedge vif.clk)
		vif.valid<=1;
		vif.a<=trans.a;
		vif.b<=trans.b;
		@(posedge vif.clk)
		vif.valid<=0;
		trans.c<=vif.c;
		@(posedge vif.clk)
		trans.display(Driver);
		no_transactions++;
	end
endtask	

endclass