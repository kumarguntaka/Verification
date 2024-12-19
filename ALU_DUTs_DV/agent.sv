class agent extends uvm_agent;
	`uvm_component_utils(agent)

	transaction t;
	driver dv;
	sequencer seqr;

	function new(string path = "agent", uvm_component parent = null);
		super.new(path,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		t=transaction::type_id::create("t");
		seqr=sequencer::type_id::create("seqr",this);
		dv=driver::type_id::create("dv",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		dv.seq_item_port.connect(seqr.seq_item_export);
	endfunction

endclass
