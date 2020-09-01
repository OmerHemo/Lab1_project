
module	debug	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	BrickWall_drawingRequest, // indicates pixel inside the bracket
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
parameter  int BRICK_WIDTH_X = 64;
parameter  int BRICK_HEIGHT_Y = 64;
//__________________________________
parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;


//__________________________________
parameter  logic [7:0] OBJECT_COLOR = 8'h5b; 


localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
//======--------------------------------------------------------------------------------------------------------------=

const logic [1:0] FREE=2'b00, REGU=2'b01; //orientation consts


// Maps
const logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [1:0] map0 = {
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU},
	{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE},
	{FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU}
};



logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [1:0] grid;
//
int X_index_in_grid ;  
int y_index_in_grid ;
logic	[10:0] topLeftY;
logic inside_grid;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);
//assign inside_grid = (pixelX <= x_GRID_SIZE);


//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		RGBout <=	8'b0;
		BrickWall_drawingRequest <=	0;
		grid <= map0;
	end
	else
	begin
	//drawing offset logic
		RGBout  <= OBJECT_COLOR ;	// colors table 
		//draw logic
		BrickWall_drawingRequest <= (grid[y_index_in_grid][X_index_in_grid] == REGU) ;
		offsetX	<= (pixelX % BRICK_WIDTH_X); //calculate relative offsets from top left corner of the brick
		offsetY	<= (pixelY % BRICK_HEIGHT_Y); //calculate relative offsets from top left corner of the brick
	end
end 
endmodule 