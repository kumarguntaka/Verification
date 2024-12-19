/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

module adder();

input [3:0] a, b;
output [6:0] c;

reg [6:0] temp_c;

input valid;
input clk,rstn;

always@(posedge clk, negedge rst)
	begin
		if(rst)
			c<=0;
		else if(valid)
			temp_c<=a+b;
	end
	
assign c=temp_c;

endmodule