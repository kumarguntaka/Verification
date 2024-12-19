/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class transaction;

rand bit [1:0] addr;
rand bit       wr_en;
rand bit       rd_en;
rand bit [7:0] wr_data;
     bit [7:0] rd_data;
	 bit [1:0] cnt;      //Usage is not mentioned, what is the purpose?

constraint wr_rd_c {wr_en!=rd_en;};

function void post_randomize();
	$display("----------- [Trans] post_randomize ----------");
	if(wr_en) $display("\t adrr = %0h \t wr_en = %0h, wr_data = %0h \t", addr, wr_en, wr_data);
	if(rd_en) $display("\t adrr = %0h \t rd_en = %0h \t", addr, rd_en);
	$display("---------------------------------------------");
endfunction

function transaction do_copy();
	transaction trans;
	trans=new();
	trans.addr=this.addr;
	trans.wr_en=this.wr_en;
	trans.rd_en=this.rd_en;
	trans.wr_data=this.wr_data;
	return trans;
endfunction

endclass
