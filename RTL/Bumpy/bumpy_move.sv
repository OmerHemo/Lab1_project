
module	bumpy_move(	
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input enum logic [3:0] {Sreset ,Sidle, Sleft, Sright, Sdown, Sup, Sdie, Sbounce_from_left, Sbounce_from_right, Sbounce_from_top, Sdown_from_right, Sdown_from_left} state,
	input logic step_collision,
	input logic free_collision,
	input	logic	[3:0] HitEdgeCode,
	input logic [7:0] bumpy_size_in,

	output	 logic signed 	[10:0]	offset_topleft_X,// output the top left corner 
	output	 logic signed	[10:0]	offset_topleft_Y,
	output	 logic	debug_led
);


const logic [3:0] BOTTOM=4'b0001, RIGHT=4'b0010, TOP=4'b0100, LEFT=4'b1000; //orientation consts
const int FIXED_POINT_MULTIPLIER	=	64;
const int tile_size = 64*FIXED_POINT_MULTIPLIER;
const int bumpy_size = 16*FIXED_POINT_MULTIPLIER;
const int step_size = 7*FIXED_POINT_MULTIPLIER;

// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;

const int center_topleft_x = tile_size/2 - bumpy_size/2; // Daniel added
const int center_topleft_y = tile_size/2 - bumpy_size/2; // Daniel added

const int SPEED_X = 80;
const int SPEED_Y = 100;
const int JUMP_LIMIT_Y = tile_size - 3*step_size;
const int JUMP_LIMIT_X = tile_size;
const int Border_OFFSET = 100;

// local parameters 
int pos_x, pos_y; 
int speed_x,speed_y;
int jump_start_y,jump_start_x;

// jump clock
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		jump_start_y <= 0;
		jump_start_x <= 0;
	end
	else begin
		if(((step_collision) && (HitEdgeCode == BOTTOM)) || ( (state==Sup) && (free_collision) && (HitEdgeCode == BOTTOM) ) ) begin
			jump_start_y <= pos_y;
			jump_start_x <= pos_x;
		end
	end
end


// y axis speed
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		speed_y	<= 0;
		debug_led <= 1'b0;
	end
	else begin
		case(state)
			Sreset: begin
				speed_y	<= 0;
			end
			Sdie: begin
				debug_led <= 1'b1;
			end
			Sidle,Sleft,Sright/*,Sbounce_from_left,Sbounce_from_right*/: begin
				if((step_collision) && (HitEdgeCode == BOTTOM) && (speed_y >=0)) begin
					speed_y <= -SPEED_Y;
				end
				else if((pos_y < (jump_start_y - JUMP_LIMIT_Y)) && (speed_y <=0)) begin
					speed_y <= SPEED_Y;
				end
			end
			Sdown: begin
				speed_y <= SPEED_Y;
				debug_led <= 1'b0;
			end
			Sup: begin
				speed_y <= -SPEED_Y;
			end
		endcase
	end
end


//////////--------------------------------------------------------------------------------------------------------------=
//  x axis speed

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
		speed_x	<= 0;
	else begin
	
		case(state)
			Sreset,Sidle,Sdown,Sup,Sdie:
				speed_x	<= 0;
			Sleft: begin
				if((pos_x < jump_start_x - JUMP_LIMIT_X) && (speed_x <= 0))
					speed_x <= 0;
				else
					speed_x <= -SPEED_X;
			end
			Sright: begin
				if((pos_x > jump_start_x + JUMP_LIMIT_X) && (speed_x >= 0))
					speed_x <= 0;
				else
					speed_x <= SPEED_X;
			end
		endcase
		
	end
end

//////////--------------------------------------------------------------------------------------------------------------=
// position calculate 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		pos_x	<= center_topleft_x;
		pos_y	<= center_topleft_x;
	end
	else begin
		if (startOfFrame == 1'b1) begin // perform  position integral only 30 times per second 
			pos_x  <= pos_x + speed_x; 
			pos_y  <= pos_y + speed_y;
		end
	end
end

//get a better (64 times) resolution using integer   
assign 	offset_topleft_X = pos_x / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	offset_topleft_Y = pos_y / FIXED_POINT_MULTIPLIER ;

endmodule
