
module debug_check_leds (
	input logic clk, 
	input logic resetN,
	input	logic	check1,
	input logic check2,
	input logic check3,
	
	output logic led0,
	output logic led1,
	output logic led2
	);                            



// die output

always_ff@(posedge clk or negedge resetN)
   begin 
   if (!resetN) begin  // Asynchronic reset
		led0 <= 1'b0;
		led1 <= 1'b0;
		led2 <= 1'b0;
	end
	else begin	// Synchronic logic FSM
		if(check1)
			led0 <= 1;
		if(check2)
			led1 <= 1;
		if(check3)
			led2 <= 1;
	end
end

endmodule
