class sequence1 extends uvm_sequence#(transaction);
	`uvm_object_utils(sequence1)

	transaction t;
	enum {op_add,op_xor} opcode;

	function new(string path="sequence1");
		super.new(path);
	endfunction
	
	task carry_test(int mx);
		repeat(mx) begin
			t=transaction::type_id::create("t");
			start_item(t);
			t.randomize() with {A[14:0]+B[14:0]+ci >= 16'h8000;};
			t.op=op_add;
			finish_item(t);
			#5;
		end
	endtask

	task xor_test(int mx);
		repeat(mx) begin
			t=transaction::type_id::create("t");
			start_item(t);
			t.randomize() with {^A && (A==~B);};
			t.op=op_xor;
			finish_item(t);
			#5;
		end
	endtask

	virtual task body();
		carry_test(50);
		xor_test(100);
		#10;
	endtask

endclass
