interface ifft_interface();

//// instantiation//////
logic Clk; 
logic Reset;
logic Pushin; 
logic FirstData;
logic signed [16:0] DinR;
logic signed [16:0] DinI;
logic PushOut;
logic [47:0] DataOut;

endinterface : ifft_interface
