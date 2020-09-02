
module bumpy_fsm (
	input logic clk, 
	input logic resetN,
	input	logic	up_direction,left_direction,right_direction,down_direction,
	input logic bumpy_collision,
	input	logic	[3:0] HitEdgeCode, //one bit per edge {Left, Top, Right, Bottom}	
	input logic [3:0] [2:0] area, // area[0]=LEFT_TILE_TYPE | area[1]=UP_TILE_TYPE | area[2]=RIGHT_TILE_TYPE | area[3]=DOWN_TILE_TYPE
	
	
	output logic [3:0] state,
   output logic led_debug
	);                            

enum logic [3:0] {Sreset ,Sidle, Sleft, Sright, Sdown, Sup, Sdie, Sbounce_from_left, Sbounce_from_right, Sbounce_from_top} prState, nxtState;
 	
const logic [3:0] BOTTOM=4'b0001, RIGHT=4'b0010, TOP=4'b0100, LEFT=4'b1000; //orientation consts	

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
	end
   else		// Synchronic logic FSM
		prState <= nxtState;
	end // always
	
	
always_comb // Update next state and outputs
	begin
		nxtState = prState; // default values 
		
		case (prState)
		
			Sreset: begin
				if (up_key || left_key || right_key || down_key) begin
					nxtState = Sidle;
				end
				else begin
					nxtState = Sreset;
				end
			end 
		
			Sidle: begin
				if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
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
						
			Sleft: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_key) 
								nxtState = Sup;
							else if(left_key) begin
								if(area[0]==WALL)
									nxtState = Sbounce_from_left;
								else 
									nxtState = Sleft;
							end
							else if(right_key) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sleft;
				end
						
			Sright: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_key) 
								nxtState = Sup;
							else if(left_key)
								nxtState = Sleft;
							else if(right_key) begin
								if(area[2]==WALL)
									nxtState = Sbounce_from_right;
								else 
									nxtState = Sright;
							end
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sright;
				end 
				
			Sdown: begin 
						if(area[3]==DEATH)
							nxtState = Sdie;
						else if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
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
							nxtState = Sdown;
				end 
					
			Sup: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
							if (up_key) begin
								if(area[1]==WALL)
									nxtState = Sbounce_from_top;
								else
									nxtState = Sup;
							end
							else if(left_key)
								nxtState = Sleft;
							else if(right_key) 
								nxtState = Sright;
							else
								nxtState = Sidle;
						end
						else
							nxtState = Sup;
				end 
						
			Sdie: begin
					// sub in life counter 
				end 
				
			Sbounce_from_left: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
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
							nxtState = Sbounce_from_left;
				end 
				
			Sbounce_from_right: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
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
							nxtState = Sbounce_from_right;
				end 
				
			Sbounce_from_top: begin
						if((bumpy_collision) && (HitEdgeCode==BOTTOM)) begin
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
							nxtState = Sbounce_from_top;
				end 
						
			endcase
	end 
	
endmodule
