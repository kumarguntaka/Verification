/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

interface mem_intf(input logic clk,rst);

logic [1:0] addr;
logic       wr_en;
logic       rd_en;
logic [7:0] wr_data;
logic [7:0] rd_data;

clocking driver_cb @(posedge clk);
	default input #1 output #1;
	output addr;
	output wr_en;
	output rd_en;
	output wr_data;
	input  rd_data;
endclocking

clocking monitor_cb @(posedge clk);
	default input #1 output #1;
	input addr;
	input wr_en;
	input rd_en;
	input wr_data;
	input rd_data;
endclocking

modport DRIVER  (clocking  driver_cb, input clk, rst);
modport MONITOR (clocking monitor_cb, input clk, rst);

endinterface