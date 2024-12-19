/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

class transaction;

rand bit [3:0] a;
rand bit [3:0] b;
     bit [6:0] c;
	 
function void display(string name);
$display("----------------------");
$display("---- [ %s ] ----", name);
$display("----------------------");
$display("- a = %0d, b = %0d ", a,b);
$display("- c = %0d ", c);
$display("----------------------");
endfunction

endclass


