class ifft_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(ifft_scoreboard)

  uvm_tlm_analysis_fifo #(ifft_sequence_item) scoreboard_port;
  uvm_tlm_analysis_fifo #(ifft_sequence_item) sref_port;
  ifft_sequence_item tr, tf;
  reg[47:0] DataC;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCBD_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCBD_CLASS", "Build Phase!", UVM_HIGH)
    scoreboard_port =new("scoreboard_port",this);
    sref_port =new("sref_port",this);
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SCBD_CLASS", "Connect Phase!", UVM_HIGH)
  endfunction: connect_phase
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCBD_CLASS", "Run Phase!", UVM_HIGH)
	forever begin
		//$display($time," Inside Runphase of SCB");
		sref_port.get(tf);
		scoreboard_port.get(tr);
		//$display("time=%0d,CLk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,tr.Clk,tr.Reset,tr.Pushin,tr.FirstData,tr.DinR,tr.DinI,tr.PushOut,tr.DataOut); 
		//$display("time=%0d,CLk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,tf.Clk,tf.Reset,tf.Pushin,tf.FirstData,tf.DinR,tf.DinI,tf.PushOut,tf.DataOut);
  		if(tr.PushOut==1&&(tr.DataOut!=tf.DataOut))
  			`uvm_error("SCB",$sformatf("Failed - Data Mismatch! - Actual = %0h Expected = %0h",tr.DataOut,tf.DataOut))
  		else if(tr.PushOut==1&&(tr.DataOut==tf.DataOut)) 
  			`uvm_info("SCB",$sformatf("SUCCESS - Data Matched! - Actual = %0h Expected = %0h",tr.DataOut,tf.DataOut),UVM_MEDIUM)
	end
  endtask: run_phase


endclass: ifft_scoreboard