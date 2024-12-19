 class ifft_sequencer extends uvm_sequencer#(ifft_sequence_item);
  `uvm_component_utils(ifft_sequencer)

  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_sequencer", uvm_component parent=null);
    super.new(name, parent);
    `uvm_info("SEQUENCER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
endclass: ifft_sequencer
