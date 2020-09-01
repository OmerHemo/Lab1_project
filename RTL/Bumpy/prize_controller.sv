
module	prize_controller	(	
					input		logic	clk,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					
					output	logic [2:0] prize_type,
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY
);


parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001; //orientation consts


// Maps
const logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] map0 = {
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU},
	{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE},
	{FREE,REGU,REGU,REGU,FREE,REGU,FREE,REGU,FREE,REGU}
};

int X_index_in_grid ;  
int y_index_in_grid ;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);


//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk)
begin
		prize_type <= (map0[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
end 
endmodule 
