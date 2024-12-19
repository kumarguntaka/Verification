class ifft_sequence extends uvm_sequence;
  `uvm_object_utils(ifft_sequence)

  ifft_sequence_item seq_item;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_sequence");
    super.new(name);
    `uvm_info("SEQ_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  task tcase(int mx=1,bit sel=0,bit[47:0] DataH=0);
    repeat(mx) begin
      seq_item = ifft_sequence_item::type_id::create("seq_item");
      start_item(seq_item);
      if(sel) seq_item.randomize() with {seq_item.Pushin==1;seq_item.FirstData==1; seq_item.DataE==DataH;};
      else seq_item.randomize() with {seq_item.Pushin==1;seq_item.FirstData==1;};
      finish_item(seq_item);
	end
  endtask

  task body();
  	tcase(1,1,48'hE23456789F1B);
    tcase(1,1,48'hE23456789F1B);
  	tcase(1,1,48'hA5A5A5A5A5A5);
  	tcase(1,1,48'hAAAAAAAAAAAA);
  	tcase(1,1,48'h555555555555);
  	tcase(1,1,48'h111111111111);
  	tcase(1,1,48'h000000000000);
  	tcase(1,1,48'h100000000001); 
/*  tcase(1,1,48'h19ff3ffe3320);
  	tcase(1,1,48'h323fefed5950);
  	tcase(1,1,48'h26fbbbe7ec41);
  	tcase(1,1,48'h99aff6fb2c10); */
  	tcase(20000,0,);
  endtask

endclass : ifft_sequence