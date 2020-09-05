
module	step_controller	(	
					input		logic	clk,
					input 	logic resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic gate,
					input		logic [2:0] lvl,
					input		logic next_lvl, 
					
					input		logic [10:0] bumpy_x,
					input		logic [10:0] bumpy_y,
					output	logic [2:0] step_type,
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY,
					output 	logic [3:0] [2:0] area, // area[0]=LEFT_TILE_TYPE | area[1]=UP_TILE_TYPE | area[2]=RIGHT_TILE_TYPE | area[3]=DOWN_TILE_TYPE
					output 	logic debug
);


parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, DEATH=3'b011, WALL=3'b100, SPIKE=3'b101, BRAKE=3'b110; //orientation consts


// Maps
logic [0:1] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] maps = {
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAKE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,BRAKE,FREE,REGU,FREE,REGU,FREE,REGU,FREE,REGU},
		{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
		{REGU,FREE,BRAKE,BRAKE,FREE,FREE,FREE,FREE,REGU,FREE},
		{FREE,REGU,REGU,REGU,FREE,SPIKE,FREE,REGU,FREE,REGU}
	},
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAKE,FREE,FREE,FREE,FREE,FREE,BRAKE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,BRAKE,FREE,FREE,FREE,BRAKE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{SPIKE,REGU,BRAKE,REGU,REGU,REGU,REGU,REGU,REGU,REGU}
	}
};


logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] currentMap;

int X_index_in_grid, y_index_in_grid;
int X_bumpy_index_in_grid, y_bumpy_index_in_grid;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);

assign X_bumpy_index_in_grid = ((bumpy_x) >> 6);
assign y_bumpy_index_in_grid = ((bumpy_y) >> 6);


// tile clock
always_ff@(posedge clk)
begin
		step_type <= (currentMap[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
end 


logic [2:0] prev_step;
logic flag_change_gate;
// map change clock
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			currentMap <= maps[0];
			prev_step <= maps[0][6][4];
			flag_change_gate <= 0;
			debug <= 0;
		end
		else begin 
			if(gate && (flag_change_gate ==0)) begin
				prev_step <= currentMap[6][4];
				currentMap[6][4] <= GATE;
				flag_change_gate <= 1;
				debug <= 1;
			end
			else if(gate == 0) begin
				currentMap[6][4] <= prev_step;
				flag_change_gate <= 0;
				debug <= 0;
			end
			if(next_lvl) begin
				currentMap <= maps[lvl];
				prev_step <= maps[lvl][6][4];
				flag_change_gate <= 0;
			end
		end
end

endmodule 





