/**************************************************************************
***                                                                     *** 
***         Kumar Sai Reddy, Fall, 2023									*** 
***                                                                     *** 
*************************************************************************** 
***  Filename: design.sv    Created by Kumar Sai Reddy, 3/29/2023       ***  
***  Version                Version V0p1                                ***  
***  Status                 Tested                                      ***  
***************************************************************************/

`include "tw_factor_ifft.sv"
import tw_factor_ifft_pkg::*;
`include "dut.sv"

module tb;

// Sequence Item Variables //
reg Clk, Reset;
reg Pushin, FirstData;
reg signed [16:0] DinR, DinI; 
wire PushOut;
wire [47:0] DataOut;

// Dut Instantiation //
ofdmdec DUT(Clk, Reset, Pushin, FirstData, DinR, DinI, PushOut, DataOut);

// Test process //
always #5 Clk=~Clk;

initial begin
	Clk=1; Reset=1; Pushin=0; FirstData=0; DinR=0; DinI=0;
	#100000000 begin $display("Ran out of clocks!"); $finish; end
end

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
real EnR[128]; real EnI[128];
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

task main_block(input reg[47:0] DataE);
	forever begin
		case(state)
			// Data Encoding Logic //
			0: begin
				Reset=1; Pushin=0; FirstData=0; DinR=0; DinI=0;
				DataC=DataE;
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
				repeat(5)@(negedge Clk);
				Reset=0; 
				repeat(5)@(negedge Clk);
				for(int i=0; i<128; i=i+1) begin
					@(posedge Clk) #1;
					Pushin=1;
					if(i==0)FirstData=1; else FirstData=0;
					DinR=OuR[i];
					DinI=OuI[i];
					//$display("State-%0d time=%0d,i=%0d,I0R=%h,I0I=%h",state,$time,i,OuR[i],OuI[i]);
					//$display("time=%0d,Clk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,Clk,Reset,Pushin,FirstData,DinR,DinI,PushOut,DataOut);
				end
				@(posedge Clk) #1;
				Pushin=0; DinR=0; DinI=0;
				repeat(130) begin 
					//$display("time=%0d,CLk=%0b,Reset=%0b,Pushin=%0b,FirstData=%0b,DinR=%0h,DinI=%0h,PushOut=%0d,DataOut=%0h",$time,Clk,Reset,Pushin,FirstData,DinR,DinI,PushOut,DataOut); 
					if(PushOut==1&&(DataOut!=DataC)) begin
						$display("Failed - Data Mismatch! - Actual = %0h Expected = %0h",DataOut,DataC); $finish; end
					else if(PushOut==1&&(DataOut==DataC)) 
						$display("SUCCESS - Data Matched! - Actual = %0h Expected = %0h",DataOut,DataC);
					@(posedge Clk) #1; 
				end
				// Till here to read from DUT//
				state=0;
				break;
			end
			default: state=7;
		endcase
	end
endtask

initial begin
	main_block(48'hE23456789F1B);
/* 	main_block(48'hE23456789F1B);
	main_block(48'hA5A5A5A5A5A5);
	main_block(48'hAAAAAAAAAAAA);
	main_block(48'h555555555555);
	main_block(48'h111111111111);
	main_block(48'h000000000000);
	main_block(48'h100000000001);
	repeat(5000) main_block($urandom); */
	$finish;
end

endmodule