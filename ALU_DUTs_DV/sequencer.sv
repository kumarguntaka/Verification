class sequencer extends uvm_sequencer#(transaction);
	`uvm_component_utils(sequencer)

	function new(string path = "sequencer", uvm_component parent = null);
		super.new(path,parent);
	endfunction

endclass
