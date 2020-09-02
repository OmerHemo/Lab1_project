
module	bumpy_move(	
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input enum logic [3:0] {Sreset ,Sidle, Sleft, Sright, Sdown, Sup, Sdie, Sbounce_from_left, Sbounce_from_right, Sbounce_from_top} state,
	input logic bumpy_collision,
	input logic [7:0] bumpy_size_in,

	output	 logic signed 	[10:0]	offset_topleft_X,// output the top left corner 
	output	 logic signed	[10:0]	offset_topleft_Y,
	output	 logic	debug_led
);



const int FIXED_POINT_MULTIPLIER	=	64;
const int Tile_size = 64;
const int bumpy_size = 16*FIXED_POINT_MULTIPLIER;

// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	Tile_size * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	Tile_size * FIXED_POINT_MULTIPLIER;

const int center_topleft_x = x_FRAME_SIZE/2 - bumpy_size/2;
const int center_topleft_y = y_FRAME_SIZE/2 - bumpy_size/2;

const int SPEED = 40;

// local parameters 
int pos_x, pos_y,curr_tile_x,curr_tile_y; 
int speed_x,speed_y;

assign curr_tile_x = ((pos_x / x_FRAME_SIZE) * x_FRAME_SIZE);
assign curr_tile_y = ((pos_y / y_FRAME_SIZE) * y_FRAME_SIZE);

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
			Sidle,Sleft,Sright,Sbounce_from_left,Sbounce_from_right: begin
				if(speed_y == 0)
					speed_y <= SPEED;
				if((bumpy_collision) && (speed_y >=0))
					speed_y <= -SPEED;
				if( (pos_y < (curr_tile_y + 10)) && (speed_y <=0))
					speed_y <= SPEED;
			end
			Sdown: begin
				speed_y <= SPEED;
				debug_led <= 1'b0;
			end
			Sup: begin
				speed_y <= -SPEED;
			end
			Sbounce_from_top: begin
				if((pos_y < curr_tile_y) && (speed_y <= 0))
					speed_y <= SPEED;
				else
					speed_y <= -SPEED;
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
			Sreset,Sidle,Sdown,Sup,Sbounce_from_top,Sdie:
				speed_x	<= 0;
			Sleft:
				speed_x <= -SPEED;
			Sright:
				speed_x <= SPEED;
			Sbounce_from_left: begin
				if((pos_x < (curr_tile_x + 10)) && (speed_x <= 0))
					speed_x <= SPEED;
				else
					speed_x <= -SPEED;
			end
			Sbounce_from_right:begin
				if((pos_x > (curr_tile_x + y_FRAME_SIZE - bumpy_size - 10)) && (speed_x >= 0))
					speed_x <= -SPEED;
				else
					speed_x <= SPEED;
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
