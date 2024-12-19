/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`define MON_IF mem_vif.MONITOR.monitor_cb

class monitor;

virtual mem_intf mem_vif;

mailbox mon2scb;

function new(virtual mem_intf mem_vif, mailbox mon2scb);
	this.mem_vif=mem_vif;
	this.mon2scb=mon2scb;
endfunction

task main();
	forever begin
		transaction trans;
		trans=new();
		
		@(posedge mem_vif.MONITOR.clk);
		wait(`MON_IF.wr_en || `MON_IF.rd_en);
			trans.addr=`MON_IF.addr;
			trans.wr_en=`MON_IF.wr_en;
			trans.wr_data=`MON_IF.wr_data;
		
		if(`MON_IF.rd_en) begin
			trans.rd_en=`MON_IF.rd_en;
			@(posedge mem_vif.MONITOR.clk);
			@(posedge mem_vif.MONITOR.clk);
			trans.rd_data=`MON_IF.rd_data;
		end
		mon2scb.put(trans);
	end
endtask

endclass