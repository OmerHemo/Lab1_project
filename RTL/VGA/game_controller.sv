
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2020 


module	game_controller	(	
			input		logic	clk,
			input		logic	resetN,
			input		logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input		logic	drawing_request_bumpy,
			input		logic	drawing_request_step_regular,
			input		logic	drawing_request_prize,
			input		logic	drawing_request_gate,
			input		logic drawing_request_step_free,
			input		logic drawing_request_border,
			input		logic drawing_request_step_spike,
			input		logic drawing_request_step_brake,
			
		
			output logic step_regular_collision, // active in case of collision between two objects
			output logic prize_collision, // active in case of collision between two objects
			output logic gate_collision, // active in case of collision between two objects
			output logic step_free_collision,
			output logic border_collision,
			output logic step_spike_collision,
			output logic step_brake_collision,
			output logic SingleHitPulse_regular_step // critical code, generating A single pulse in a frame
);


assign step_regular_collision = ((drawing_request_bumpy &&  (drawing_request_step_regular  == 1'b1)) || (step_brake_collision)); 
assign prize_collision = (drawing_request_bumpy &&  (drawing_request_prize  == 1'b1)); 
assign gate_collision = (drawing_request_bumpy &&  (drawing_request_gate  == 1'b1));
assign step_free_collision = ((drawing_request_bumpy) &&  (drawing_request_step_free  == 1'b1));
assign border_collision = (drawing_request_bumpy &&  (drawing_request_border  == 1'b1));
assign step_spike_collision = (drawing_request_bumpy &&  (drawing_request_step_spike == 1'b1));
assign step_brake_collision = (drawing_request_bumpy &&  (drawing_request_step_brake == 1'b1));

logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse_regular_step <= 1'b0;
	end 
	else begin 

			SingleHitPulse_regular_step <= 1'b0 ; // default 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
			if ((step_regular_collision)  && (flag == 1'b0)) begin
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse_regular_step <= 1'b1 ; 
			end ; 
	end 
end

endmodule
