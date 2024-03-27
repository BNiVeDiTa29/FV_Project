module fsm(
input logic clk,
input logic rst_n,
input logic [11:0] data,
output logic detected
);

typedef enum logic [4:0] {
 
 S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, //main states
 SC0, SC1, SC2, SC3, SC4, SC5, SC6, SC7, SC8, SC9, SC10, SC11, //checker states
 D_0, D_1, D_2, D_3, IO //deadlock and isolation states
} state;

state current_state, next_state;

logic isolation, deadlock ;

//sequential logic
always_ff @(negedge clk, negedge rst_n)
	begin
		if(!rst_n && (current_state != D_3))
			begin
				current_state <= S0;
			end
		else
			current_state <= next_state;
			
	end

//Next State Combinational logic
always_comb
	begin
		next_state = current_state;
		
		casex (current_state)
		//main and checker states
		
		S0	:	next_state = (data[11] == 1'b0) ? SC0 : D_0;
		SC0	:	next_state = S1;
		
		S1	:	next_state = (data[10] == 1'b0) ? SC1 : S0;
		SC1	:	next_state = S2;
		
		S2	:	next_state = (data[9] == 1'b0) ? SC2 : S0; 
		SC2	:	next_state = S3;
		
		S3	:	next_state = (data[8] == 1'b1) ? SC3 : S1;
		SC3	:	next_state = S4;
		
		S4	:	next_state = (data[7] == 1'b0) ? SC4 : S0;
		SC4	:	next_state = S5;
		
		S5	:	next_state = (data[6] == 1'b1) ? SC5 : S1;
		SC5	:	next_state = S6;
		
		S6	:	next_state = (data[5] == 1'b1) ? SC6 : S1;
		SC6	:	next_state = S7;
		
		S7	:	next_state = (data[4] == 1'b1) ? SC7 : S1;
		SC7	:	next_state = S8;
		
		S8	:	next_state = (data[3] == 1'b1) ? SC8 : S1;
		SC8	:	next_state = S9;
		
		S9	:	next_state = (data[2] == 1'b0) ? SC9 : S0;
		SC9	:	next_state = S10;
		
		S10	:	next_state = (data[1] == 1'b0) ? SC10: S0;
		SC10:	next_state = S11;
		
		S11	:	next_state = (data[0] == 1'b1) ? SC11: S1;
		SC11:	next_state = S12;
		
		S12	:	next_state = S0;
		
		//deadlock states
		D_0	:	if (data[10] == 1'b1) 
					next_state = D_1;
					
		D_1	:	if (data[9] == 1'b1) 
					next_state = D_2;
					
		D_2	:   if (data[8] == 1'b0)
					next_state = D_3;
				else
					next_state = IO;
					
		D_3	:   next_state = D_3;
		
		//isolation state
		IO	: if(rst_n)
				next_state = S0;
			  else
				next_state = IO;
		
		//default state
		default: begin
					next_state = 5'bxxxxx;
				 end
	
		endcase
	end

//Output Combinational logic
always_comb
	begin
	{detected, isolation, deadlock} = '0;
	
	unique case(current_state)
	
		SC0, SC1, SC2, SC3, SC4, SC5, SC6, SC7, SC8, SC9, SC10, SC11, D_0, D_1, D_2: begin
																						detected = '0;
																						deadlock = '0;
																						isolation= '0;
																					 end
																					   
	    S0	:	detected = '0;
		S1	:	detected = '0;
		S2	:	detected = '0; 
		S3	:	detected = '0;
		S4	:	detected = '0;	
		S5	:	detected = '0;	
		S6	:	detected = '0;	
		S7	:	detected = '0;
		S8	:	detected = '0;		
		S9	:	detected = '0;	
		S10	:	detected = '0;
		S11	:	detected = '0;		
		S12	:	detected = '1;
		D_3	:   deadlock = '1;
		IO	:	isolation= '1;
	endcase
	end
`ifdef INLINE_SVA
//Assertions for the design module

//S2 to S3 transition when the data is correct using SC2-----Assertion1
property sequenceS2S3_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S2) && !data[9]) |=> (current_state == SC2) |=> (current_state == S3);
endproperty


//Noise mitigation-----Assertion2
property noisemitigation_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	(current_state == SC4) |=> (current_state == S5);
endproperty


//S8 to S9 transition when the data is correct using SC8-----Assertion3
property sequenceS8S9_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S8) && data[3]) |=> (current_state == SC8) |=> (current_state == S9);
endproperty



//Last state to initial state transition-----Assertion4
property lasttransition_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	(current_state == S12) |=> (current_state == S0);
endproperty




//enter into Deadlock loop-----Assertion5
property deadlockloop_p;
	@(negedge clk) disable iff (!rst || current_state == D_3)
	((current_state == S0) && data[11]) |=> (current_state == D_0);
endproperty




//deadlock occured and unable to come out -----Assertion6
property lockedD3_p;
	@(negedge clk) disable iff (!rst)i
	((current_state == D_3) && !rst) |=> (current_state == D_3);
endproperty





//Exit from Maintenance State(Isolation)-----Assertion7
property Exitisolation_p;
	@(negedge clk) disable iff (current_state == D_3)
	((current_state == IO) && !rst) |=> (current_state == S0);
endproperty




//When incorrect sequence is given at S9-----Assertion8
property  S910incseq_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S9) && data[2]) |=> (current_state == S0);
endproperty




//Checking reset-----Assertion9
property rstfunc_p;
	@(negedge clk) disable iff (current_state == D_3)
	(current_state == S0 || current_state == SC0 || current_state == S1 || current_state == SC1 || current_state == S2 || current_state == SC2 ||
     current_state == S3 || current_state == SC3 || current_state == S4 || current_state == SC4 || current_state == S5 || current_state == SC5 ||
     current_state == S6 || current_state == SC6 || current_state == S7 || current_state == SC7 || current_state == S8 || current_state == SC8 ||
     current_state == S9 || current_state == SC9 || current_state == S10 || current_state == SC10 || current_state == S11 || current_state == SC11 ||
     current_state == S12 || current_state == D_0 || current_state == D_1 || current_state == D_2|| State == IO) && !rst |=> current_state == S0;
endproperty




//When incorrect sequence ig given at S2-----Assertion10
property S2S3incseq_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S2) && data[9]) |=> (current_state == S0);
endproperty




//Transition from S11 to SC11 for correct value-----Assertion11
property S11SC11tr_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S11) && data[0]) |=> (current_state == SC11);
endproperty



//Enter isolation -----Assertion12
property enterIO_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == D_2) && data[8]) |=> (current_state == IO);
endproperty




//S6 to S7 transition when the data is correct using SC6-----Assertion13
property sequenceS6S7_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S6) && data[5]) |=> (current_state == SC7) |=> (current_state == S7);
endproperty




//Transition from S11 to SC11 for correct value-----Assertion14
property S7SC7tr_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S7) && data[0]) |=> (current_state == SC7);
endproperty




//S9 to S10 transition when the data is correct using SC9-----Assertion15
property sequenceS9S10_p;
	@(negedge clk) disable iff(!rst || current_state == D_3)
	((current_state == S9) && !data[2]) |=> (current_state == SC9) |=> (current_state == S10);
endproperty


			a_sequenceS2S3 : assert property (sequenceS2S3_p);
			a_noisemitigation : assert property (noisemitigation_p);
			a_sequenceS8S9 : assert property (sequenceS8S9_p);
			a_lasttransition : assert property (lasttransition_p);
			a_deadlockloop : assert property (lasttransition_p);
			a_lockedD3 : assert property (lockedD3_p);
			a_Exitisolation : assert property (Exitisolation_p);
			a_S910incseq : assert property (S910incseq_p);
			a_rstfunc : assert property (rstfunc_p);
			a_S2S3incseq : assert property (S2S3incseq_p);
			a_S11SC11tr : assert property (S11SC11tr_p);
			a_enterIO : assert property (enterIO_p);
			a_sequenceS6S7 : assert property (sequenceS6S7_p);
			a_S7SC7tr : assert property (S7SC7tr_p);
			a_sequenceS9S10 : assert property (sequenceS9S10_p);



`endif

endmodule
	
	
