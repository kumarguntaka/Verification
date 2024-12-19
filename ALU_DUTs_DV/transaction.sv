class transaction extends uvm_sequence_item;
	`uvm_object_utils(transaction)
	
	rand bit signed [38:0] A;
	rand bit signed [21:0] B;
	rand bit op;
	rand bit ci;
	bit signed [35:0] Z;
	bit co;
	
	typedef enum bit {op_add,op_xor} opcode;

	function new(string path = "transaction");
		super.new(path);
	endfunction

endclass
