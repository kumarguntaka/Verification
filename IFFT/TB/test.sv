class ifft_test extends uvm_test;
`uvm_component_utils(ifft_test)

ifft_env env;
ifft_sequence seq;

//--------------------------------------------------------
//Constructor
//--------------------------------------------------------
function new(string name = "ifft_test", uvm_component parent);
  super.new(name, parent);
  `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
endfunction: new


//--------------------------------------------------------
//Build Phase
//--------------------------------------------------------
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)
  env =ifft_env::type_id::create("env", this);
  seq =ifft_sequence::type_id::create("seq");
endfunction: build_phase


//--------------------------------------------------------
//Connect Phase
//--------------------------------------------------------
function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)
endfunction: connect_phase


//--------------------------------------------------------
//Run Phase
//--------------------------------------------------------
task run_phase (uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  seq.start(env.agent.seqr);
  `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)
  phase.drop_objection(this);
endtask: run_phase


endclass: ifft_test 