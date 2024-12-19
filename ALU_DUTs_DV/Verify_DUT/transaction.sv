interface alu_if;
	logic clk;
	logic rst;
	logic pushin; //in
	logic stopin; // in
	logic [1:0] ct1; // in
	logic [7:0] a; // in
	logic [7:0] b; // in
	logic ci; // in
	logic stopout; // out
	logic pushout; // out
	logic cout; // out
	logic [7:0] z; // out

endinterface
//////////////////////////////

`include "uvm_machros.sv"
import umv_pkg::*;

/////////////////
class alu_config extends uvm_object;
`uvm_object_utils(alu_config)

	function new(string path = "alu_config");
		super.new(path);
	endfunction
	
	uvm_active_passive_enum is_active = UVM_ACTIVE;
endclass
////////////////////////////

typedef enum bit[3:0] {a_test, add_test, 
					   sub_test, mul_test,
					   reset_dut} op_mode;

//////////////////////

class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction)

	function new(string path = "transaction");
		super.new(path);
	endfunction
	
	logic rst;
	logic pushin; //in
	logic stopin; // in
	rand op_mode op; // test case
	rand logic [1:0] ct1; // in
	rand logic [7:0] a; // in
	rand logic [7:0] b; // in
	logic ci; // in
	logic stopout; // out
	logic pushout; // out
	logic cout; // out
	logic [7:0] z; // out
	
endclass

////////////////////
class reset_dut extends uvm_sequence #(transaction);
`uvm_object_utils(reset_dut)

	function new(string path = "reset_dut");
		super.new(path);
	endfunction
	
	transaction tr;
	
	virtual task body();
		tr = transaction::type_id::create("tr");
		repeat(10) begin
		start.item(tr);
		tr.op = reset_dut;
		`uvm_info("reset_dut","System seq_Reset",UVM_MEDIUM);
		finish_item(tr);
		end
	endtask
endclass 

////////////////////
class a_test extends uvm_sequence #(transaction);
`uvm_object_utils(a_test)

	function new(string path = "a_test");
		super.new(path);
	endfunction
	
	transaction tr;
	
	virtual task body();
		repeat(10) begin
		start.item(tr);
		assert(!(tr.randomize()));
		tr.op = a_test;
		finish_item(tr);
		end
	endtask
endclass 

//////////////////////////
class add_test extends uvm_sequence #(transaction);
`uvm_object_utils(add_test)

	function new(string path = "add_test");
		super.new(path);
	endfunction
	
	transaction tr;
	
	virtual task body();
		repeat(10) begin
		start.item(tr);
		assert(!(tr.randomize()));
		tr.op = add_test;
		finish_item(tr);
		end
	endtask
endclass 

////////////////////////////
class sub_test extends uvm_sequence #(transaction);
`uvm_object_utils(sub_test)

	function new(string path = "sub_test");
		super.new(path);
	endfunction
	
	transaction tr;
	
	virtual task body();
		repeat(10) begin
		start.item(tr);
		assert(!(tr.randomize()));
		tr.op = sub_test;
		finish_item(tr);
		end
	endtask
endclass 

////////////////////////////
class mul_test extends uvm_sequence #(transaction);
`uvm_object_utils(mul_test)

	function new(string path = "mul_test");
		super.new(path);
	endfunction
	
	transaction tr;
	
	virtual task body();
		repeat(10) begin
		start.item(tr);
		assert(!(tr.randomize()));
		tr.op = mul_test;
		finish_item(tr);
		end
	endtask
endclass 

////////////////////
class driver extends uvm_driver #(transaction);
`umv_component_utils(driver)

	function new(string path ="driver", uvm_component parent);
		super.new(path);
	endfunction
	
	transaction tr;
	virtual alu_if vif;
	
	virtual function void build_phase(uvm_phase phase)
		super.build_phase(phase);
		tr = transaction::type_id::create("tr");
		if(!uvm_config_db#(virtual alu_if vif)::get(this,"","vif",vif));
		`uvm_error("drv","unable to access the interface");
	endfunction
	
	task reset_dut();
		repeat(5) begin
		vif.rst <= 'b0;
		vif.pushin <= 'b0;
		vif.stopin <= 'b0;
		vif.ci <= 'b0;
		vif.ct1 <= 'b0;
		vif.a <= 'b0;
		vif.b <= 'b0;
		`uvm_info("DRV","System Reset",UVM_MEDIUM);
		@(posedge vif.clk);
		end
	endtask
	
	virtual task run_phase(uvm_phase phase);
		drive();
	endtask

	task drive();
		reset_dut();
		forever begin
		seq_item_port.get_next_item(tr);
			if(tr.op == reset_dut) begin
				vif.rst <= 'b0;
				vif.pushin <= 'b0;
				vif.stopin <= 'b0;
				vif.ci <= 'b0;
				vif.ct1 <= 'b0;
				vif.a <= 'b0;
				vif.b <= 'b0;
			end	
		seq_item_port.item_done();
		end
	endtask
endclass

//////////////////////////////