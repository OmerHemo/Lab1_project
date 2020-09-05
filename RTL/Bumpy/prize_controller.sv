
module	prize_controller	(
					input		logic	clk,
					input 	logic resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel
					input 	logic	[10:0] pixelY,
					input 	logic prize_collision,
					input		logic [10:0] bumpy_x,
					input		logic [10:0] bumpy_y,
					input 	logic [9:0] random_prize,
					input		logic [2:0] lvl,
					input		logic next_lvl,
					input		logic coin_step_collision,
					input		logic	[3:0] HitEdgeCode,
					input		logic bumpy_diedN,


					output 	logic [1:0] random_prize_color,
					output	logic [2:0] prize_type,
					output 	logic	[10:0] tileTopLeftX,
					output 	logic	[10:0] tileTopLeftY
);


parameter int NUM_OF_ROWS = 7;
parameter int NUM_OF_COLS = 10;

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001; //orientation consts

const logic [3:0] BOTTOM=4'b0001, RIGHT=4'b0010, TOP=4'b0100, LEFT=4'b1000; //orientation consts	


// Maps
logic [0:1] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] maps = {
	{
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE}
	},
	{
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{REGU,REGU,REGU,REGU,REGU,REGU,REGU,REGU,REGU,REGU},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE}
	}
};


// coin steps counters
logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [1:0] coinCountersMap = {
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01},
		{2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01}
};


logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] currentMap;
logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [1:0] currentCoinCountersMap;
 


int X_index_in_grid, y_index_in_grid;
int X_bumpy_index_in_grid, y_bumpy_index_in_grid;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);

assign X_bumpy_index_in_grid = ((bumpy_x) >> 6);
assign y_bumpy_index_in_grid = ((bumpy_y) >> 6);


//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
		prize_type <= (currentMap[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		random_prize_color[0] <= random_prize[X_index_in_grid];
		random_prize_color[1] <= random_prize[y_index_in_grid];
end


always_ff@(posedge clk or  negedge resetN)
begin
		if(!resetN) begin
			currentMap <= maps[0];
			currentCoinCountersMap <= coinCountersMap;
		end
		else begin
			if(prize_collision) begin
				currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid] <= FREE;
			end
			if((coin_step_collision) && (HitEdgeCode == TOP) && (currentCoinCountersMap[y_index_in_grid][X_index_in_grid] >= 2'b01)) begin
				currentMap[y_index_in_grid][X_index_in_grid] <= REGU;
				currentCoinCountersMap[y_index_in_grid][X_index_in_grid] <= currentCoinCountersMap[y_index_in_grid][X_index_in_grid] -1;
			end
			if(next_lvl || !bumpy_diedN) begin
					currentMap <= maps[lvl];
			end
		end
end

endmodule
