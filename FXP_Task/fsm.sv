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
			begin
				current_state <= next_state;
			end
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

endmodule
	
	
