/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`define DRIV_IF mem_vif.DRIVER.driver_cb

class driver;

virtual mem_intf mem_vif;

mailbox gen2driv;

int no_transactions;

function new(virtual mem_intf mem_vif, mailbox gen2driv);
	this.mem_vif=mem_vif;
	this.gen2driv=gen2driv;
endfunction

task reset;
	wait(mem_vif.rst);
	$display("--------- [Driver - Reset Started ] ----------");
	`DRIV_IF.addr<=0;
	`DRIV_IF.wr_en<=0;
	`DRIV_IF.rd_en<=0;
	`DRIV_IF.wr_data<=0;
	wait(!mem_vif.rst);
	$display("--------- [Driver - Reset Ended ] ----------");
endtask

task drive;
		transaction trans;
		`DRIV_IF.wr_en<=0;
		`DRIV_IF.rd_en<=0;
		gen2driv.get(trans);
		
		$display("--------- [Driver - Transfer: %0d] ----------", no_transactions);
		@(posedge mem_vif.DRIVER.clk);
		`DRIV_IF.addr<=trans.addr;
		
		if(trans.wr_en) begin
			`DRIV_IF.wr_en<=trans.wr_en;
			`DRIV_IF.wr_data<=trans.wr_data;
			$display("\t addr = %0h, \t wr_data = %0h", trans.addr, trans.wr_data);
			@(posedge mem_vif.DRIVER.clk);
		end
		
		if(trans.rd_en) begin
			`DRIV_IF.rd_en<=trans.rd_en;
			@(posedge mem_vif.DRIVER.clk);
			`DRIV_IF.rd_en<=0;
			@(posedge mem_vif.DRIVER.clk);
			trans.rd_data=`DRIV_IF.rd_data;
			$display("\t addr = %0h, \t rd_data = %0h", trans.addr, `DRIV_IF.rd_data);
		end
		$display("--------------------------------------------");
		
		no_transactions++;
endtask

task main;
	forever begin
		fork
			begin
				wait(mem_vif.rst);
			end
			
			begin
				forever drive();
			end
		join_any
	end
endtask

endclass