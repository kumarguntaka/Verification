class ref_model extends uvm_monitor;
	`uvm_component_utils(ref_model)
	
	virtual ifft_interface vif;
	ifft_sequence_item value;
	uvm_analysis_port #(ifft_sequence_item) ref_port;
	
	//--------------------------------------------------------
	//Constructor
	//--------------------------------------------------------
	function new(string name = "ref_model", uvm_component parent);
		super.new(name, parent);
		`uvm_info("REF_CLASS", "Inside Constructor!", UVM_HIGH)
	endfunction: new
	
	//--------------------------------------------------------
	//Build Phase
	//--------------------------------------------------------
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("REF_CLASS", "Build Phase!", UVM_HIGH)
		ref_port = new("ref_port",this);
		value = ifft_sequence_item::type_id::create("value");
	endfunction: build_phase
	
	//--------------------------------------------------------
	//Connect Phase
	//--------------------------------------------------------
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("REF_CLASS", "Connect Phase!", UVM_HIGH)
		if(!(uvm_config_db #(virtual ifft_interface)::get(this, "*", "vif", vif))) begin
		`uvm_error("REF_CLASS", "Failed to get VIF from config DB!")
		end
	endfunction: connect_phase

	// Driver Code Variables //
	reg [6:0] ADDR;//6:0
	reg [6:0] ADDR_n;//6:0
	reg [3:0] state;
	reg [3:0] ready;
	
	int l;
	int slice;
	
	// Encoded Data in Hex //
	reg[47:0] DataT;
	reg[ 1:0] Encd;
	real EnG;
	// Parameter to store the amplitudes for decoding block // 
	parameter real dep[3] = {0.027,0.249,0.694};
	
	// Storage realisters for decoding Input Data to first Recieving Data  //
	real xR[128]; real xI[128];
	// Storage realisters for Recieving Input Data to Bit Reversal //
	real InR[128]; real InI[128];
	// Storage realisters for Recieving Bit Reversal Data to Intermediate Data //
	real I0R[128]; real I0I[128];
	// Storage realisters for Recieving complex multiplication Data //
	real Te0R[128]; real Te0I[128];
	// Storage realisters for Recieving Input Data to Bit Reversal //
	reg signed [16:0]OuR[128]; reg signed [16:0]OuI[128];
	
	// Complex Multiplication Task //
	task comp_mul(input real IR,II,WR,WI, output real TeR,TeI);
		TeR=IR*WR-II*WI;
		TeI=II*WR+IR*WI;
		//$display("Inside Comp_Mul time=%0d,IR=%f,II=%f,WR=%f,WI=%f,TeR=%f,TeI=%f",$time,IR,II,WR,WI,TeR,TeI);
	endtask

	task main_block(/* output reg[47:0] DataE */);
		state=0;
		slice=1;
		forever begin
			case(state)
				// Data Encoding Logic //
				0: begin
					forever@(posedge vif.Clk) begin
						if(vif.FirstData) begin  //** Doubt?? - What after 128 data, again vif.FirstData high?? **//
							ADDR=0;
							if(vif.DinR[16]==0) xR[ADDR]= vif.DinR/32768.00;
							if(vif.DinR[16]==1) begin xR[ADDR]=-vif.DinR/32768.00; xR[ADDR]=-xR[ADDR]; end
							if(vif.DinI[16]==0) xI[ADDR]= vif.DinI/32768.00;
							if(vif.DinI[16]==1) begin xI[ADDR]=-vif.DinI/32768.00; xI[ADDR]=-xI[ADDR]; end
							//$display("FFT - time=%0d,ADDR=%0d,xR=%f,xI=%f,vif.DinR=%0h,vif.DinI=%0h",$time,ADDR,xR[ADDR],xI[ADDR],vif.DinR,vif.DinI);
							ADDR=ADDR+1;
						end
						else if(!vif.FirstData&(ADDR!=0)) begin
							// Bit Reversal and Storing Data //
							if(vif.DinR[16]==0) xR[ADDR]= vif.DinR/32768.00;
							if(vif.DinR[16]==1) begin xR[ADDR]=-vif.DinR/32768.00; xR[ADDR]=-xR[ADDR]; end
							if(vif.DinI[16]==0) xI[ADDR]= vif.DinI/32768.00;
							if(vif.DinI[16]==1) begin xI[ADDR]=-vif.DinI/32768.00; xI[ADDR]=-xI[ADDR]; end
							//$display("FFT - time=%0d,ADDR=%0d,xR=%f,xI=%f,vif.DinR=%0h,vif.DinI=%0h",$time,ADDR,xR[ADDR],xI[ADDR],vif.DinR,vif.DinI);
							if(ADDR==127) begin state=1; break; end
							ADDR=ADDR+1;
						end
					end
				end
				// Bit Reversal Logic //
				1: begin
					ADDR=0;
					slice=1;
					for(int i=0; i<128; i=i+1) begin
						// Bit Reversal and Storing Data //
						ADDR_n[0]=ADDR[6];
						ADDR_n[1]=ADDR[5];
						ADDR_n[2]=ADDR[4];
						ADDR_n[3]=ADDR[3];
						ADDR_n[4]=ADDR[2];
						ADDR_n[5]=ADDR[1];
						ADDR_n[6]=ADDR[0];
						InR[i]=xR[ADDR_n];
						InI[i]=xI[ADDR_n];
						//$display("State-1 time=%0d,ADDR=%0d,ADDR_n=%0d,EnR=%f,EnI=%f,InR=%f,InI=%f",$time,ADDR,ADDR_n,EnR[ADDR_n],EnR[ADDR_n],InR[i],InI[i]);
						ADDR=ADDR+1;
					end
					state=2;
				end
				// FFT Logic //
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
						//if(slice==64) $display("FFT - State-%0d time=%0d,m=%0d,I0R[m]=%f,I0I[m]=%f,InR=%f,InI=%f",state,$time,m,I0R[m],I0I[m],InR[m],InI[m]);
					end
					slice=slice+slice;
					//$display("slice=%0d,state=%0d",slice,state);
					if(slice==128)state=3;
				end
				// Data Q2.15 Conversion //
				3: begin
					// Starts of Slicing/Decoding logic // 
					value.DataOut=48'b0;
					for(int i=4; i<52; i=i+2) begin
						EnG=InR[i]*InR[i]+InI[i]*InI[i];
						DataT=3;
						for(int j=0; j<3; j=j+1) begin
							//$display("InR=%f,InI=%f,EnG=%f,dep[j]=%f,j=%0d",InR[i],InI[i],EnG,dep[j],j);
							if(EnG<dep[j]) begin
								DataT=j;
								break;
							end
						end
						DataT=DataT<<(i-4);
						value.DataOut=value.DataOut|DataT;
						//$display("DataT=%b,value.DataOut=%b",DataT,value.DataOut);
					end
					//$display("value.DataOut=%0h",value.DataOut);
					// Till here to read from DUT//
					state=0;
					value.PushOut=1;
					ref_port.write(value);
					//@(posedge vif.Clk) value.PushOut=0;
					break;
				end
				default: state=4;
			endcase
		end
	endtask

  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    forever begin
		main_block();
	end
  endtask: run_phase

endclass