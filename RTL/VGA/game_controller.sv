
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2020 


module	game_controller	(	
			input		logic	clk,
			input		logic	resetN,
			input		logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input		logic	drawing_request_bumpy,
			input		logic	drawing_request_tile,
			input		logic	drawing_request_prize,
			input		logic	drawing_request_gate,
			input		logic drawing_request_step_free,
			
		
			output logic tile_collision, // active in case of collision between two objects
			output logic prize_collision, // active in case of collision between two objects
			output logic gate_collision, // active in case of collision between two objects
			output logic step_free_collision,
			output logic SingleHitPulse // critical code, generating A single pulse in a frame
			
);


assign tile_collision = (drawing_request_bumpy &&  (drawing_request_tile  == 1'b1)); 
assign prize_collision = (drawing_request_bumpy &&  (drawing_request_prize  == 1'b1)); 
assign gate_collision = (drawing_request_bumpy &&  (drawing_request_gate  == 1'b1));
assign step_free_collision = (drawing_request_bumpy &&  (drawing_request_step_free  == 1'b1));

logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 

			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
			if ((tile_collision || prize_collision || gate_collision || step_free_collision)  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end ; 
	end 
end

endmodule
