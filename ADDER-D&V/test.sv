/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

program test; // usually intf can be defined inside test()

environment env;

intf intf;

function new(intf intf);
	env = new(intf);
	env.gen.repeat_count = 10;
	env.run();
endfunction

endprogram
