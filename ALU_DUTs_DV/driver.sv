class driver extends uvm_driver#(transaction);
	`uvm_component_utils(driver)
	
	transaction t;

	function new(string path = "driver", uvm_component parent = null);
		super.new(path,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		t=transaction::type_id::create("t");
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(t);
			//put the test cases here
			`uvm_info("DRV",$sformatf("A=%b : B=%b : cin=%b : op=%b", t.A, t.B, t.ci, t.op),UVM_NONE);
			#10;
			seq_item_port.item_done();
		end
	endtask

endclass
