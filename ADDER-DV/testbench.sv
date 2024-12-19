/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "interface.sv"
`include "test.sv"

module testbench;

intf i_intf(clk,rst);

test t1(i_intf);

always #5 clk = ~clk;

initial begin
	   rst = 1;
	#5 rst = 0;
end

adder DUT(
.clk(i_intf.clk),
.rst(i_intf.rst),
.valid(i_intf.valid),
.a(i_intf.a),
.b(i_intf.b),
.c(i_intf.c)
);

initial begin
	$dumpfile(test.vcd); 
	$dumpvars;
end

endmodule