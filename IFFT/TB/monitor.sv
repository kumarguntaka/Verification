 class ifft_monitor extends uvm_monitor;
  `uvm_component_utils(ifft_monitor)

   virtual ifft_interface vif;
   ifft_sequence_item value;
   uvm_analysis_port #(ifft_sequence_item) monitor_port;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
    monitor_port = new("monitor_port",this);
    value = ifft_sequence_item::type_id::create("value");
  endfunction: build_phase

  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
    if(!(uvm_config_db #(virtual ifft_interface)::get(this, "*", "vif", vif))) begin
      `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB!")
    end
  endfunction: connect_phase

  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    forever begin
	  @(posedge vif.Clk); #1;
	    if(vif.PushOut) begin
		  value.Reset=vif.Reset;
		  value.Pushin=vif.Pushin; 
		  value.FirstData=vif.FirstData;
		  value.DinR=vif.DinR;
		  value.DinI=vif.DinI;
		  value.PushOut=vif.PushOut;
		  value.DataOut=vif.DataOut;
		  monitor_port.write(value);
	      //$display("time=%0d,CLk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,vif.Clk,vif.Reset,vif.Pushin,vif.FirstData,vif.DinR,vif.DinI,vif.PushOut,vif.DataOut);
	    end
	end
  endtask: run_phase


endclass: ifft_monitor