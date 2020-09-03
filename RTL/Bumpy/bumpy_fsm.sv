
module bumpy_fsm (
	input logic clk, 
	input logic resetN,
	input	logic	up_direction,left_direction,right_direction,down_direction,
	input logic step_collision,
	input logic free_collision,
	input logic border_collision,
	input	logic	[3:0] HitEdgeCode, //one bit per edge {Left, Top, Right, Bottom}	
	input logic [3:0] [2:0] area, // area[0]=LEFT_TILE_TYPE | area[1]=UP_TILE_TYPE | area[2]=RIGHT_TILE_TYPE | area[3]=DOWN_TILE_TYPE
	
	
	output logic [3:0] state,
   output logic led_debug
	);                            

enum logic [3:0] {Sreset ,Sidle, Sleft, Sright, Sdown, Sup, Sdie, Sbounce_from_left, Sbounce_from_right, Sbounce_from_top, Sdown_from_right, Sdown_from_left} prState, nxtState;
 	
const logic [3:0] BOTTOM=4'b0001, RIGHT=4'b0010, TOP=4'b0100, LEFT=4'b1000; //orientation consts	

const logic [3:0] LEFT_AREA = 4'd0, UP_AREA = 4'd1, RIGHT_AREA = 4'd2, DOWN_AREA = 4'd3;

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, DEATH=3'b011, WALL=3'b100 ; //orientation consts


logic up_key, left_key, right_key, down_key;

assign up_key = !up_direction;
assign left_key = !left_direction;
assign right_key = !right_direction;
assign down_key = !down_direction;
assign state = prState;

always @(posedge clk or negedge resetN)
   begin
	   
   if (!resetN) begin  // Asynchronic reset
		prState <= Sreset;
		led_debug <= 0;
	end
   else begin	// Synchronic logic FSM
		prState <= nxtState;
		if(step_collision)
			led_debug <= 1;
	end	
end // always
	
	
always_comb // Update next state and outputs
	begin
		nxtState = prState; // default values 
		
		case (prState)
		
			Sreset: begin
				if (up_key || left_key || right_key || down_key) begin
					nxtState = Sdown; // replace to Sdown
				end
				else begin
					nxtState = Sreset;
				end
			end 
		
			Sidle: begin
				if((step_collision) && (HitEdgeCode==BOTTOM)) begin
					if (up_key) 
						nxtState = Sup;
					else if(left_key)
						nxtState = Sleft;
					else if(right_key) 
						nxtState = Sright;
					else
						nxtState = Sidle;
				end
				else
					nxtState = Sidle;
			end 
			

			Sleft,Sright,Sdown: begin
						if((prState == Sdown) && (HitEdgeCode==BOTTOM) && (border_collision)) begin
							nxtState = Sdie;
						end
						else if((prState == Sright) && (border_collision)) begin
							nxtState = Sleft;
						end
						else if((prState == Sleft) && (border_collision)) begin
							nxtState = Sright;
						end
						else if((step_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_key) begin 
									nxtState = Sup;
							end
							else if(left_key) begin
									nxtState = Sleft;
							end
							else if(right_key) begin 
									nxtState = Sright;
							end
							else
								nxtState = Sidle;
						end
						else begin
							if(prState == Sleft)
								nxtState = Sleft;
							else if(prState == Sright)
								nxtState = Sright;
							else if(prState == Sdown)
								nxtState = Sdown;
						end
				end
						
			
			Sup: begin
				if(down_key) begin
					nxtState = Sdown;
				end
				else if((free_collision) && (HitEdgeCode==BOTTOM)) begin
							if(left_key) begin
									nxtState = Sleft;
							end
							else if(right_key) begin 
									nxtState = Sright;
							end
							else
								nxtState = Sup;
							end
				else if(border_collision || ((step_collision) && (HitEdgeCode==TOP))) begin
							nxtState = Sdown;
				end
				else
					nxtState = Sup;
			end
				
			Sdie: begin
					// sub in life counter 
				end 
				
						
			endcase
	end 
	
endmodule
