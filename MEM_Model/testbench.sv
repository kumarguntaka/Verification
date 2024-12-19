/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "interface.sv"
`include "test.sv"

module testbench;

bit clk;
bit rst;

always #5 clk=~clk;

mem_intf intf(clk,rst);

test t1(intf);

initial begin
   rst=1;
#5 rst=0;
end

memory DUT (
.clk(intf.clk),
.rst(intf.rst),
.addr(intf.addr),
.wr_en(intf.wr_en),
.rd_en(intf.rd_en),
.wr_data(intf.wr_data),
.rd_data(intf.rd_data)
);

initial begin
	$dumpfile("test.vcd");
	$dumpvars;
end

endmodule