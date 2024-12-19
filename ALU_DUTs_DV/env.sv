class env extends uvm_env;
	`uvm_component_utils(env)

	agent ag;

	function new(string path = "env",uvm_component parent = null);
		super.new(path,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		ag=agent::type_id::create("ag",this);
	endfunction

endclass
