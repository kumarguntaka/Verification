 class ifft_agent extends uvm_agent;
  `uvm_component_utils(ifft_agent)

  ifft_driver drv;
  ifft_monitor mon;
  ref_model rmd;
  ifft_sequencer seqr;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)
    drv = ifft_driver::type_id::create("drv",this);
    mon = ifft_monitor::type_id::create("mon",this);
    rmd = ref_model::type_id::create("rmd",this);
    seqr = ifft_sequencer::type_id::create("seqr",this);
  endfunction: build_phase

  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction: connect_phase

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("AGENT_CLASS", "Run Phase!", UVM_HIGH)
  endtask: run_phase

endclass: ifft_agent