class test extends uvm_test;
	`uvm_component_utils(test)

	sequence1 seq1;
	env ev;

	function new(string path = "test", uvm_component parent = null);
		super.new(path, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		seq1=sequence1::type_id::create("seq1");
		ev=env::type_id::create("ev",this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
			seq1.start(ev.ag.seqr);
			#10;
		phase.drop_objection(this);
	endtask

endclass
