class ifft_sequence_item extends uvm_sequence_item;
 `uvm_object_utils(ifft_sequence_item)

 //instantiation////
rand bit Clk; 
rand bit Reset;
rand bit Pushin; 
rand bit FirstData;
rand bit signed [16:0] DinR;
rand bit signed [16:0] DinI;
     bit PushOut;
     bit [47:0] DataOut;
	 
rand bit [47:0] DataE;

 function new(string name = "ifft_sequence_item");
   super.new(name);
 endfunction : new

endclass : ifft_sequence_item
