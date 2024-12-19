/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class monitor;

virtual intf vif;

mailbox mon2scb;

function new(virtual intf vif, mailbox mon2scb);
	this.vif=vif;
	this.mon2scb=mon2scb;
endfunction

task main;
	forever begin
		transaction trans;
		trans=new();
		@(posedge vif.clk)
		wait(vif.valid);
		trans.a<=vif.a
		trans.b<=vif.b
		@(posedge vif.clk)
		wait(vif.valid);
		trans.c<=vif.c
		@(posedge vif.clk)
		mon2scb.put(trans);
		trans.display("Generator");
	end
endtask

endclass