/////includefiles///////////
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "dut.sv"
`include "tw_factor_ifft.sv"
import tw_factor_ifft_pkg::*;
`include "interface.sv"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "ref_model.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"


module top();

ifft_interface vif();

//////instantation////////
ofdmdec dut(vif.Clk, vif.Reset, vif.Pushin, vif.FirstData, vif.DinR, vif.DinI, vif.PushOut, vif.DataOut);

initial begin
	vif.Clk=1;
end

always #5 vif.Clk=~vif.Clk;

initial begin
	uvm_config_db #(virtual ifft_interface)::set(null, "*", "vif", vif );
	run_test("ifft_test");
end

initial begin
	#100000000 begin $display("Ran out of clocks!"); $finish; end
end

/* initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
end  */

endmodule: top