/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

module memory 
#(
parameter ADDR_WIDTH = 2,
parameter DATA_WIDTH = 8
)(
input                       clk,
input                       rst,
input [ADDR_WIDTH-1:0]     addr,
input                     wr_en,
input                     rd_en,
input [DATA_WIDTH-1:0]  wr_data,
output reg [DATA_WIDTH-1:0]  rd_data
);

reg [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];

always@(posedge rst)
	for(int i=0; i<2**ADDR_WIDTH; i=i+1) mem[i]=8'hFF;
	
always@(posedge clk)
	if(wr_en) mem[addr]=wr_data;
	
always@(posedge clk)
	if(rd_en) rd_data=mem[addr];

endmodule