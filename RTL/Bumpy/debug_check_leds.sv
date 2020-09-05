
module debug_check_leds (
	input logic clk, 
	input logic resetN,
	input	logic	[7:0]	 teleport_cordinates,
	input logic check2,
	input logic check3,
	
	output logic led0,
	output logic led1,
	output logic led2
	);                            


logic [3:0] X_teleport_cordinates;
logic [3:0] Y_teleport_cordinates;

assign X_teleport_cordinates = teleport_cordinates[3:0];
assign Y_teleport_cordinates = teleport_cordinates[7:4];

// die output

always_ff@(posedge clk or negedge resetN)
   begin 
   if (!resetN) begin  // Asynchronic reset
		led0 <= 1'b0;
		led1 <= 1'b0;
		led2 <= 1'b0;
	end
	else begin	// Synchronic logic FSM
		if((X_teleport_cordinates == 4'b1111) && (Y_teleport_cordinates == 4'b1111) && check2)
			led0 <= 1;
		if(check2)
			led1 <= 1;
		if(check3)
			led2 <= 1;
	end
end

endmodule
