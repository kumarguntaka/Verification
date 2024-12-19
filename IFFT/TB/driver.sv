 class ifft_driver extends uvm_driver#(ifft_sequence_item);
  `uvm_component_utils(ifft_driver)

   virtual ifft_interface vif;
   ifft_sequence_item value;
   
  // Driver Code Variables //
  reg [6:0] ADDR;//6:0
  reg [6:0] ADDR_n;//6:0
  reg [3:0] state;
  reg [3:0] ready;
  
  int l;
  int slice;
  
  // Encoded Data in Hex //
  reg[ 1:0] Encd;
  // Parameter to store the amplitudes for decoding block // 
  parameter real amp[4] = {0.0,0.333,0.666,1.0};
  
  // Storage realisters for decoding Input Data to first Recieving Data  //
  real EnR[128]; real EnI[128];
  // Storage realisters for Recieving Input Data to Bit Reversal //
  real InR[128]; real InI[128];
  // Storage realisters for Recieving Bit Reversal Data to Intermediate Data //
  real I0R[128]; real I0I[128];
  // Storage realisters for Recieving complex multiplication Data //
  real Te0R[128]; real Te0I[128];
  // Storage realisters for Recieving Input Data to Bit Reversal //
  reg signed [16:0]OuR[128]; reg signed [16:0]OuI[128];
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "ifft_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    value = ifft_sequence_item::type_id::create("value");
  endfunction: build_phase

  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DRIVER_CLASS", "Connect Phase!", UVM_HIGH)
    if(!(uvm_config_db #(virtual ifft_interface)::get(this, "*", "vif", vif))) begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!")
    end
  endfunction: connect_phase
  
  //--------------------------------------------------------
  //IFFT Block
  //--------------------------------------------------------

  // Complex Multiplication Task //
  task comp_mul(input real IR,II,WR,WI, output real TeR,TeI);
  	TeR=IR*WR-II*WI;
  	TeI=II*WR+IR*WI;
      //$display("Inside Comp_Mul time=%0d,IR=%f,II=%f,WR=%f,WI=%f,TeR=%f,TeI=%f",$time,IR,II,WR,WI,TeR,TeI);
  endtask
  
  // Main IFFT Task //
  task main_block(input reg[47:0] DataE);
    state=0;
    slice=1;
  	forever begin
  		case(state)
  			// Data Encoding Logic //
  			0: begin
  				vif.Reset=1; vif.Pushin=0; vif.FirstData=0; vif.DinR=0; vif.DinI=0;
  				slice=1;
  				for(int fbin=4; fbin<52; fbin=fbin+2) begin
  					Encd=DataE[1:0]&2'b11;
  					EnR[fbin]=amp[Encd];
  					EnR[128-fbin]=amp[Encd];
  					EnI[fbin]=0.00;
  					EnI[128-fbin]=0.00;
  					//$display("State-0 time=%0d,fbin=%0d,EnR[fbin]=%f,EnI[fbin]=%f,Encd=%0d,DataE=%0b",$time,fbin,EnR[fbin],EnI[fbin],Encd,DataE);
  					DataE=DataE>>2;
  				end
  				EnR[55]=1.00;
  				EnR[73]=1.00;//128-55=73//
  				state=1;
  			end
  			// Bit Reversal Logic //
  			1: begin
  				ADDR=0;
  				for(int i=0; i<128; i=i+1) begin
  					// Bit Reversal and Storing Data //
  					ADDR_n[0]=ADDR[6];
  					ADDR_n[1]=ADDR[5];
  					ADDR_n[2]=ADDR[4];
  					ADDR_n[3]=ADDR[3];
  					ADDR_n[4]=ADDR[2];
  					ADDR_n[5]=ADDR[1];
  					ADDR_n[6]=ADDR[0];
  					InR[i]=EnR[ADDR_n];
  					InI[i]=EnI[ADDR_n];
  					//$display("State-1 time=%0d,ADDR=%0d,ADDR_n=%0d,EnR=%f,EnI=%f,InR=%f,InI=%f",$time,ADDR,ADDR_n,EnR[ADDR_n],EnR[ADDR_n],InR[i],InI[i]);
  					ADDR=ADDR+1;
  				end
  				state=2;
  			end
  			// IFFT Logic //
  			2: begin
  				for(int i=0; i<128; i=i+2*slice) begin
  					for(int j=i+slice; j<i+2*slice; j=j+1) begin
  						comp_mul(InR[j],InI[j],W128R[(128/(2*slice))*(j-(i+slice))],W128I[(128/(2*slice))*(j-(i+slice))],Te0R[j-slice],Te0I[j-slice]);
  					end
  					l=i;
  					for(int k=i; k<i+2*slice; k=k+1) begin
  						I0R[k]=InR[l]+Te0R[l]*((k<i+slice)?1:-1);
  						I0I[k]=InI[l]+Te0I[l]*((k<i+slice)?1:-1);
  						if(l==i+(slice-1)) l=i; else l=l+1;
  						//$display("State-%0d time=%0d,k=%0d,InR[l]=%f,InI[l]=%f,Te0R[l]=%f,Te0I[l]=%f,I0R=%f,I0I=%f",state,$time,k,InR[l],InI[l],Te0R[l],Te0I[l],I0R[k],I0I[k]);
  					end
  				end
  				for(int m=0; m<128; m=m+1) begin
  					InR[m]=I0R[m];
  					InI[m]=I0I[m];
  					//$display("State-%0d time=%0d,m=%0d,InR[m]=%f,InI[m]=%f,I0R=%f,I0I=%f",state,$time,m,I0R[m],I0I[m],InR[m],InI[m]);
  				end
  				slice=slice+slice;
  				//$display("slice=%0d,state=%0d",slice,state);
  				if(slice==128)state=3;
  			end
  			// 128-point divider //
  			3: begin
  				for(int i=0; i<128; i=i+1) begin
  					I0R[i]=InR[i]/128.00;
  					I0I[i]=InI[i]/128.00;
  					//$display("State-%0d time=%0d,i=%0d,InR[i]=%f,InI[i]=%f,I0R=%f,I0I=%f",state,$time,i,InR[i],InI[i],I0R[i],I0I[i]);
  				end
  				state=4;
  			end
  			// Data Q1.15 Conversion //
  			4: begin
  				for(int i=0; i<128; i=i+1) begin
  					OuR[i]=I0R[i]*32768.00;
  					OuI[i]=0.00;
  					//$display("State-%0d time=%0d,i=%0d,I0R=%h,I0I=%h",state,$time,i,OuR[i],OuI[i]);
  				end
  				// Logic to send and read data from the DUT //
  				repeat(5)@(negedge vif.Clk);
  				vif.Reset=0; 
  				repeat(5)@(negedge vif.Clk);
  				for(int i=0; i<128; i=i+1) begin
  					@(posedge vif.Clk) #1;
  					vif.Pushin=1;
  					if(i==0)vif.FirstData=1; else vif.FirstData=0;
  					vif.DinR=OuR[i];
  					vif.DinI=OuI[i];
  					//$display("State-%0d time=%0d,i=%0d,I0R=%h,I0I=%h",state,$time,i,OuR[i],OuI[i]);
  					//$display("time=%0d,vif.Clk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,vif.Clk,vif.Reset,vif.Pushin,vif.FirstData,vif.DinR,vif.DinI,vif.PushOut,vif.DataOut);
  				end
  				@(posedge vif.Clk) #1;
  				vif.Pushin=0; vif.DinR=0; vif.DinI=0;
  				state=0;
				repeat(130) @(posedge vif.Clk);
  				break;
  			end
  			default: state=7;
  		endcase
  	end
  endtask
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    forever begin
	  seq_item_port.get_next_item(value);
	    main_block(value.DataE);
	  seq_item_port.item_done();
	end
  endtask: run_phase


endclass: ifft_driver