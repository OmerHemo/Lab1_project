module	win_screen	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic	[10:0] tileTopLeftX, //position of specific tile in the grid
					input 	logic	[10:0] tileTopLeftY,  //position of specific tile in the grid
					input		logic gate_collision,
					
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
					
);
// Frame size
const int x_FRAME_SIZE = 639 ;
const int y_FRAME_SIZE = 479 ;
// grid size
const int x_GRID_SIZE = x_FRAME_SIZE;
const int y_GRID_SIZE = y_FRAME_SIZE;
//_______________________________
//__________________________________
parameter  int STEP_WIDTH_X = 639;
parameter  int STEP_HEIGHT_Y = 479;
parameter  int STEP_TILE_OFFSET_x = 0;
parameter  int STEP_TILE_OFFSET_y = 0;

//__________________________________
parameter  logic [7:0] OBJECT_COLOR = 8'h01; 


localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 

int Left_step_x;
int Top_step_y;
int Right_step_x;
int Bottom_step_y;
logic insideBracket; 

// Calculate object right  & bottom  boundaries
assign Left_step_x = ( tileTopLeftX + STEP_TILE_OFFSET_x );
assign Top_step_y = ( tileTopLeftY + STEP_TILE_OFFSET_y );
assign Right_step_x	= (Left_step_x + STEP_WIDTH_X);
assign Bottom_step_y	= (Top_step_y + STEP_HEIGHT_Y);


logic gate_collision_flag;
 
//======--------------------------------------------------------------------------------------------------------------=

always_ff@(posedge gate_collision or negedge resetN)
begin
	if(!resetN) begin
		gate_collision_flag <= 1'b0;
	end
	else if(gate_collision) begin
		gate_collision_flag <= 1'b1;
	end
end


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else if(gate_collision_flag) begin 
				RGBout  <= OBJECT_COLOR;	// colors table 
				drawingRequest <= 1'b1;
				offsetX	<= (pixelX - Left_step_x); //calculate relative offsets from top left corner
				offsetY	<= (pixelY - Top_step_y);
	end 
	else begin  
		RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
		drawingRequest <= 1'b0 ;// transparent color 
		offsetX	<= 0; //no offset
		offsetY	<= 0; //no offset
	end 	
end

endmodule 

