
module bumpy_fsm (
	input logic clk, 
	input logic resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input	logic	up_direction,left_direction,right_direction,down_direction,
	input logic bumpy_collision,
	input	logic	[3:0] HitEdgeCode //one bit per edge {Left, Top, Right, Bottom}	
	input logic bumpy_died,
	
	                              
	output logic [3:0] state,
   );                            

enum logic [3:0] {Sreset ,Sidle, Sleft, Sright, Sdown, Sup, Sdie, Sbounce_from_left, Sbounce_from_right, Sbounce_from_top} prState, nxtState;
 	
const logic [3:0] BOTTOM=4'b0001, RIGHT=4'b0010, TOP=4'b0100, LEFT=4'b1000; //orientation consts	

always @(posedge clk or negedge resetN)
   begin
	   
   if (!resetN)  // Asynchronic reset
		prState <= Sreset;
   else 		// Synchronic logic FSM
		prState <= nxtState;
		
	end // always
	
always_comb // Update next state and outputs
	begin
		nxtState = prState; // default values 
		
		case (prState)
		
			Sreset: begin
				if (up_direction || left_direction || right_direction || down_direction) 
					nxtState = Sidle;
				else
					nxtState = Sreset;
				end 
		
			Sidle: begin
				if (up_direction) 
					nxtState = Sup;
				else if(left_direction)
					nxtState = Sleft;
				else if(right_direction) 
					nxtState = Sright;
				else
					nxtState = Sidle;
				end 
						
			Sleft: begin
						if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else if((bumpy_collision) && (HitEdgeCode==LEFT)) begin
							nxtState = Sbounce_from_left;
						end
						else
							nxtState = Sleft;
				end
						
			Sright: begin
						if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else if((bumpy_collision) && (HitEdgeCode==RIGHT)) begin
							nxtState = Sbounce_from_right;
						end
						else
							nxtState = Sright;
				end 
				
			Sdown: begin 
						if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sdown;
				end 
					
			Sup: begin
					if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else if((bumpy_collision) && (HitEdgeCode==TOP)) begin
							nxtState = Sbounce_from_top;
						end
						else
							nxtState = Sup;
				end 
						
			Sdie: begin
					// sub in life counter 
				end 
				
			Sbounce_from_left: begin
					 if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sbounce_from_left;
				end 
				
			Sbounce_from_right: begin
					 if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sbounce_from_right;
				end 
				
			Sbounce_from_top: begin
					 if(bumpy_died)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_direction) 
								nxtState = Sup;
							else if(left_direction)
								nxtState = Sleft;
							else if(right_direction) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sbounce_from_top;
				end 
						
			endcase
	end 
	
endmodule
