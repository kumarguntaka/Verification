class ifft_env extends uvm_env;
 `uvm_component_utils(ifft_env)

 ifft_agent agent;
 ifft_scoreboard scbd;
 
 //--------------------------------------------------------
 //Constructor
 //--------------------------------------------------------
 function new(string name = "ifft_env", uvm_component parent);
   super.new(name, parent);
   `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
 endfunction: new

 
 //--------------------------------------------------------
 //Build Phase
 //--------------------------------------------------------
 function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
   agent = ifft_agent::type_id::create("agent",this);
   scbd = ifft_scoreboard::type_id::create("scbd", this);
 endfunction: build_phase

 
 //--------------------------------------------------------
 //Connect Phase
 //--------------------------------------------------------
 function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
   agent.mon.monitor_port.connect(scbd.scoreboard_port.analysis_export);
   agent.rmd.ref_port.connect(scbd.sref_port.analysis_export);
 endfunction: connect_phase

 
 //--------------------------------------------------------
 //Run Phase
 //--------------------------------------------------------
 task run_phase (uvm_phase phase);
   super.run_phase(phase);
   `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)
 endtask: run_phase


endclass: ifft_env 
