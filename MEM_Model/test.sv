/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy,            ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "environment.sv"

program test(mem_intf intf);

environment env;

initial begin
	env=new(intf);
	env.gen.repeat_count=4;	
	env.run();
end

endprogram