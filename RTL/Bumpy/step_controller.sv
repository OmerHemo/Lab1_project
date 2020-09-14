
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
					output 	logic	[10:0] offsetX,
					output 	logic	[10:0] offsetY,
					output	logic	[7:0]	 teleport_cordinates
);


parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;

//======--------------------------------------------------------------------------------------------------------------=

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, COIN=3'b011, PORT=3'b100, SPIK=3'b101, BRAK=3'b110; //orientation consts


// Maps
logic [0:3] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] maps = {
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
		{FREE,FREE,FREE,FREE,SPIK,FREE,FREE,FREE,FREE,FREE},
		{BRAK,FREE,FREE,FREE,SPIK,FREE,FREE,FREE,COIN,FREE},
		{FREE,FREE,FREE,FREE,SPIK,COIN,COIN,FREE,COIN,FREE},
		{FREE,BRAK,BRAK,BRAK,SPIK,FREE,BRAK,FREE,BRAK,REGU},
		{FREE,FREE,FREE,FREE,SPIK,BRAK,REGU,FREE,FREE,FREE},
		{REGU,BRAK,BRAK,BRAK,SPIK,FREE,FREE,FREE,REGU,FREE},
		{FREE,PORT,FREE,FREE,SPIK,FREE,FREE,PORT,FREE,FREE}
	},
	{
		{SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK,SPIK},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,REGU,FREE,FREE,PORT,FREE,FREE,FREE,FREE,FREE},
		{COIN,SPIK,COIN,REGU,REGU,REGU,COIN,SPIK,COIN,SPIK},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,PORT,FREE,FREE,FREE,FREE,FREE},
		{BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK}
	},
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{PORT,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,PORT,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{PORT,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,BRAK,PORT}
	}
};

const logic [0:3] [3:0] gate_pos_x = {4'h9,4'h8,4'h5,4'h9};
const logic [0:3] [3:0] gate_pos_y = {4'h1,4'h5,4'h0,4'h4};

// Maps (4bits X index | 4bits Y index)
const logic [0:3] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [7:0] teleportCordinatesMap = {
		{
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00010110,8'b00100110,8'b00110110,8'b01000110,8'b01010110,8'b01100110,8'b01110110,8'b10000110,8'b10010110,8'b00000110}
		},
		{
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000},
		{8'b00000000,8'b01110110,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00000000,8'b00010110,8'b00000000,8'b00000000}
		},
		{
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h45,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h42,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}
		},
		{
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h96,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h06,8'h06},
		{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
		{8'h84,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h01}
		}
};
 

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [7:0] currentTeleportCordinatesMap;

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] currentMap;

int X_index_in_grid, y_index_in_grid;
int X_bumpy_index_in_grid, y_bumpy_index_in_grid;

assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);

assign X_bumpy_index_in_grid = ((bumpy_x) >> 6);
assign y_bumpy_index_in_grid = ((bumpy_y) >> 6);


localparam  int STEP_TILE_OFFSET_x = 7;
localparam  int STEP_TILE_OFFSET_y = 50;

// tile clock
always_ff@(posedge clk)
begin
		step_type <= (currentMap[y_index_in_grid][X_index_in_grid]);
		teleport_cordinates <= (currentTeleportCordinatesMap[y_index_in_grid][X_index_in_grid]);
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		offsetX <= (pixelX - (((X_index_in_grid)<<6) + STEP_TILE_OFFSET_x));
		offsetY <= (pixelY - (((y_index_in_grid)<<6) + STEP_TILE_OFFSET_y));
end 


logic [2:0] prev_step;
logic flag_change_gate;
// map change clock
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			currentMap <= maps[lvl];
			currentTeleportCordinatesMap <= teleportCordinatesMap[lvl];
			prev_step <= maps[(gate_pos_y[lvl])][(gate_pos_x[lvl])];
			flag_change_gate <= 0;
		end
		else begin 
			if(gate && (flag_change_gate ==0)) begin
				prev_step <= currentMap[(gate_pos_y[lvl])][(gate_pos_x[lvl])];
				currentMap[(gate_pos_y[lvl])][(gate_pos_x[lvl])] <= GATE;
				flag_change_gate <= 1;
			end
			else if(gate == 0) begin
				currentMap[(gate_pos_y[lvl])][(gate_pos_x[lvl])] <= prev_step;
				flag_change_gate <= 0;
			end
		end
end

endmodule 





