
module	step_controller	(	
					input		logic	clk,
					input 	logic resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic gate,
					
					input		logic [10:0] bumpy_x,
					input		logic [10:0] bumpy_y,
					output	logic [2:0] step_type,
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY,
					output 	logic [3:0] [2:0] area // area[0]=LEFT_TILE_TYPE | area[1]=UP_TILE_TYPE | area[2]=RIGHT_TILE_TYPE | area[3]=DOWN_TILE_TYPE
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

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, DEATH=3'b011, WALL=3'b100 ; //orientation consts


// Maps
logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] map0 = {
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU},
	{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
	{REGU,FREE,REGU,REGU,FREE,FREE,FREE,FREE,REGU,FREE},
	{FREE,REGU,REGU,REGU,FREE,REGU,FREE,REGU,FREE,REGU}
};

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] currentMap;

int X_index_in_grid, y_index_in_grid;
int X_bumpy_index_in_grid, y_bumpy_index_in_grid;

logic	[10:0] topLeftY;
logic inside_grid;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);

assign X_bumpy_index_in_grid = ((bumpy_x) >> 6);
assign y_bumpy_index_in_grid = ((bumpy_y) >> 6);


//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk)
begin
		
		case(X_bumpy_index_in_grid)
			(NUM_OF_COLS-1): begin
				area[2] <= WALL; // right
				area[0] <= currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid-1]; // left
			end 
			0: begin
				area[2] <= currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid+1]; // right
				area[0] <= WALL; // left
			end
			default: begin
				area[2] <= currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid+1]; // right
				area[0] <= currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid-1]; // left
			end
		endcase
		
		case(y_bumpy_index_in_grid)
			(NUM_OF_ROWS-1): begin
				area[1] <= currentMap[y_bumpy_index_in_grid-1][X_bumpy_index_in_grid]; // up
				area[3] <= DEATH; // down
			end 
			0: begin
				area[1] <= WALL; // up
				area[3] <= currentMap[y_bumpy_index_in_grid+1][X_bumpy_index_in_grid]; // down
			end
			default: begin
				area[1] <= currentMap[y_bumpy_index_in_grid-1][X_bumpy_index_in_grid]; // up
				area[3] <= currentMap[y_bumpy_index_in_grid+1][X_bumpy_index_in_grid]; // down
			end
		endcase
		step_type <= (currentMap[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
end 

always_ff@(posedge gate or negedge resetN)
begin
		if(!resetN) begin
			currentMap <= map0;
		end
		else if(gate) begin
			currentMap[6][4] <= GATE; 
		end
end 



endmodule 





