/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class scoreboard;

mailbox mon2scb;

int no_transactions;

bit [7:0] mem [4];

  function new(mailbox mon2scb);
	this.mon2scb=mon2scb;
	foreach(mem[i]) mem[i]=8'hFF;
endfunction

task main();
	transaction trans;
	forever begin
		#50;
		mon2scb.get(trans);
		if(trans.rd_en) begin
			if(mem[trans.addr]==trans.wr_data)
				$error("[SCB::FAIL] addr = %0h, \n \t Data:: Expected = %0h Actual =%0h", trans.addr, mem[trans.addr], trans.rd_data);
			else
				$display("[SCB::PASS] addr = %0h, \n \t Data:: Expected = %0h Actual =%0h", trans.addr, mem[trans.addr], trans.rd_data);
			end
		else if(trans.wr_en)
			mem[trans.addr]=trans.wr_data;
			
		no_transactions++;
	end
endtask

endclass