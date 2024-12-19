/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

module ofdmdec(
input Clk, Reset, 
input PushIn, FirstData, 
input [16:0] DinR, DinI, 
output PushOut, 
output [47:0] DataOut);

// Driver Code Variables //
reg [6:0] ADDR;//6:0
reg [6:0] ADDR_n;//6:0
reg [3:0] state;
reg [3:0] ready;

int l;
int slice;

// Encoded Data in Hex //
reg[47:0] DataC;
reg[ 1:0] Encd;
// Parameter to store the amplitudes for decoding block // 
parameter real amp[4] = {0.0,0.333,0.666,1.0};

initial begin
	state=0;
	slice=1;
end

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
	forever begin
		case(state)
			// Data Encoding Logic //
			0: begin
				forever@(posedge Clk) begin
					if(FirstData) begin  //** Doubt?? - What after 128 data, again FirstData high?? **//
						ADDR=0;
						if(DinR[16]==0) xR[ADDR]= DinR/32768.00;
						if(DinR[16]==1) begin xR[ADDR]=-DinR/32768.00; xR[ADDR]=-xR[ADDR]; end
						if(DinI[16]==0) xI[ADDR]= DinI/32768.00;
						if(DinI[16]==1) begin xI[ADDR]=-DinI/32768.00; xI[ADDR]=-xI[ADDR]; end
						$display("FFT - time=%0d,ADDR=%0d,xR=%f,xI=%f,DinR=%0h,DinI=%0h",$time,ADDR,xR[ADDR],xI[ADDR],DinR,DinI);
						ADDR=ADDR+1;
					end
					else if(!FirstData&(ADDR!=0)) begin
						// Bit Reversal and Storing Data //
						if(DinR[16]==0) xR[ADDR]= DinR/32768.00;
						if(DinR[16]==1) begin xR[ADDR]=-DinR/32768.00; xR[ADDR]=-xR[ADDR]; end
						if(DinI[16]==0) xI[ADDR]= DinI/32768.00;
						if(DinI[16]==1) begin xI[ADDR]=-DinI/32768.00; xI[ADDR]=-xI[ADDR]; end
						$display("FFT - time=%0d,ADDR=%0d,xR=%f,xI=%f,DinR=%0h,DinI=%0h",$time,ADDR,xR[ADDR],xI[ADDR],DinR,DinI);
						if(ADDR==127) begin state=1; break; end
						ADDR=ADDR+1;
					end
				end
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
					$display("FFT - State-%0d time=%0d,m=%0d,InR[m]=%f,InI[m]=%f,I0R=%f,I0I=%f",state,$time,m,I0R[m],I0I[m],InR[m],InI[m]);
				end
				slice=slice+slice;
				//$display("slice=%0d,state=%0d",slice,state);
				if(slice==128)state=3;
			end
			// Data Q2.15 Conversion //
			3: begin
				// Starts of Slicing/Decoding logic // 
				// Till here to read from DUT//
				state=0;
				break;
			end
			default: state=7;
		endcase
	end
endtask

initial begin
	main_block();
	$finish;
end

endmodule