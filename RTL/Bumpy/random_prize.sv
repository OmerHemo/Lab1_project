module random_prize 	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	
	output logic [9:0] random_prize	
  );

  //generating a random number by latching a fast counter with the rising edge of an input ( e.g. key pressed )
  
logic SIZE_BITS = 10;
logic MIN_VAL = 0;  //set the min and max values 
logic MAX_VAL = 1023;

logic [SIZE_BITS-1:0] counter = MIN_VAL;
logic rise_d;
logic rise;
assign rise = !resetN;
	
	
always_ff @(posedge clk or posedge rise) begin
	counter <= counter+1;
	if(counter >= MAX_VAL) 
		counter <=  MIN_VAL; 
	rise_d <= rise;
	if (rise && !rise_d) // rizing edge 
		dout <= counter;
	end
endmodule

