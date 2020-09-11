
module	step_controller	(	
					input		logic	clk,
					input 	logic resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic gate,
					input		logic [1:0] lvl,
					
					input		logic [10:0] bumpy_x,
					input		logic [10:0] bumpy_y,
					output	logic [2:0] step_type,
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY,
					output 	logic [3:0] [2:0] area, // area[0]=LEFT_TILE_TYPE | area[1]=UP_TILE_TYPE | area[2]=RIGHT_TILE_TYPE | area[3]=DOWN_TILE_TYPE
					output 	logic debug,
					output	logic	[7:0]	 teleport_cordinates
);


parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, COIN=3'b011, PORT=3'b100, SPIK=3'b101, BRAK=3'b110; //orientation consts


// Maps
logic [0:1] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] maps = {
	{
		{SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,FREE,FREE,FREE},
		{SPIK,COIN,SPIK,COIN,SPIK,COIN,SPIK,BRAK,FREE,SPIK},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,SPIK,BRAK,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,SPIK,FREE},
		{PORT,PORT,PORT,PORT,PORT,PORT,PORT,PORT,PORT,PORT}
	},
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAK,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,COIN,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,BRAK,FREE,REGU,FREE,REGU,FREE,COIN,FREE,REGU},
		{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
		{REGU,FREE,BRAK,BRAK,FREE,FREE,FREE,FREE,REGU,FREE},
		{FREE,PORT,REGU,REGU,FREE,SPIK,FREE,PORT,FREE,REGU}
	}
};


// Maps (4bits X index | 4bits Y index)
const logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [7:0] teleportCordinatesMap = {
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00010110,8'b00100110,8'b00110110,8'b01000110,8'b01010110,8'b01100110,8'b01110110,8'b10000110,8'b10010110,8'b00000110}
};
 

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [7:0] currentTeleportCordinatesMap;

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
		teleport_cordinates <= (currentTeleportCordinatesMap[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
end 


logic [2:0] prev_step;
logic flag_change_gate;
// map change clock
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			currentMap <= maps[lvl];
			currentTeleportCordinatesMap <= teleportCordinatesMap;
			prev_step <= maps[lvl][1][9];
			flag_change_gate <= 0;
			debug <= 0;
		end
		else begin 
			if(gate && (flag_change_gate ==0)) begin
				prev_step <= currentMap[1][9];
				currentMap[1][9] <= GATE;
				flag_change_gate <= 1;
			end
			else if(gate == 0) begin
				currentMap[1][9] <= prev_step;
				flag_change_gate <= 0;
				debug <= 0;
			end
		end
end

endmodule 





