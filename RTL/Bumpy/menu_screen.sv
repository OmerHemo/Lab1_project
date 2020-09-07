/*
module	menu_screen	(	
					input		logic	clk,
					input		logic onSec,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input		logic down_keyN,
					input		logic up_keyN,
					input		logic slct_keyN,
					
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout, //optional color output for mux 
					output	logic [2:0] button_type,
					output 	logic	[10:0] tileTopLeftX,
					output 	logic	[10:0] tileTopLeftY,
					output	logic menu_comp,
					output	logic [2:0] selcted_lvl
					
);




//__________________________________
parameter  logic [7:0] OBJECT_COLOR_BACK = 8'b00000010;
parameter  logic [7:0] OBJECT_COLOR_REGU = 8'b10000000;
parameter  logic [7:0] OBJECT_COLOR_SLCT = 8'b00010000; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 



// select
logic [2:0] selected;
logic up_key,down_key;
assign up_key = ~up_keyN;
assign down_key = ~down_keyN;
logic press_flag;

always_ff@(posedge clk or negedge resetN )
begin
	if(!resetN ) begin
		selected	<=	0;
		press_flag <= 0;
	end
	else begin
		if(down_key && (press_flag == 0)) begin
			press_flag <= 0;
			selected	<=	selected + 1;
		end
		else if(up_key && (press_flag == 0)) begin
			press_flag <= 0;
			selected	<=	selected - 1;
		end
		else if((down_key == 0) && (up_key == 0)) begin
			press_flag <= 1;
		end
	end
end

// menu_comp
assign select_key = ~slct_keyN;
always_ff@(posedge clk or negedge resetN )
begin
	if(!resetN ) begin
		menu_comp	<=	0;
		selcted_lvl <= 0;
	end
	else begin
		if(select_key) begin
			menu_comp	<=1;
			selcted_lvl <= selected;
		end
	end
end


assign X_index_in_grid = ((pixelX) >> 6);
assign y_index_in_grid = ((pixelY) >> 6);

//__________________________________
parameter int NUM_OF_ROWS = 7;
parameter int NUM_OF_COLS = 10;

const logic [2:0] FREE=3'b000, REGU=3'b001, SLCT=3'b010; //orientation consts

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] map = {
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE}
};

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] current_map ;

always_ff@(posedge clk or negedge resetN )
begin
		if(!resetN ) begin
			button_type <= 0;
			tileTopLeftX	<= 0; //calculate relative offsets from top left corner of the brick
			tileTopLeftY	<= 0; //calculate relative offsets from top left corner of the brick
			drawingRequest<= 0;
			RGBout<= 0;
		end
		else begin
			button_type <= (current_map[y_index_in_grid][X_index_in_grid]);
			tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
			tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
			drawingRequest<= 1;
			RGBout<= OBJECT_COLOR_BACK;
		end
		
end


// button selection
always_ff@(posedge clk or negedge resetN )
begin
		if(!resetN ) begin
			current_map <= map;
		end
		else begin
			case(selected)
					0:begin
						current_map[1][5] <= SLCT;
						current_map[2][5] <= REGU;
						current_map[3][5] <= REGU;
						current_map[4][5] <= REGU;
					end
					1:begin
						current_map[1][5] <= REGU;
						current_map[2][5] <= SLCT;
						current_map[3][5] <= REGU;
						current_map[4][5] <= REGU;
					end
					2:begin
						current_map[1][5] <= REGU;
						current_map[2][5] <= REGU;
						current_map[3][5] <= SLCT;
						current_map[4][5] <= REGU;
					end
					3:begin
						current_map[1][5] <= REGU;
						current_map[2][5] <= REGU;
						current_map[3][5] <= REGU;
						current_map[4][5] <= SLCT;
					end
					default: begin
						current_map[1][5] <= REGU;
						current_map[2][5] <= REGU;
						current_map[3][5] <= REGU;
						current_map[4][5] <= REGU;
					end
				endcase
			
		end
end


endmodule 

*/


module	menu_screen	(	
					input		logic	clk,
					input 	logic resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic gate,
					input		logic [2:0] lvl,
					
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

const logic [2:0] FREE=3'b000, REGU=3'b001, GATE=3'b010, COIN=3'b011, TPORT=3'b100, SPIKE=3'b101, BRAKE=3'b110; //orientation consts


// Maps
logic [0:1] [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] maps = {
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAKE,FREE,FREE,FREE,REGU,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,COIN,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,BRAKE,FREE,REGU,FREE,REGU,FREE,COIN,FREE,REGU},
		{FREE,FREE,FREE,FREE,FREE,FREE,REGU,FREE,FREE,FREE},
		{REGU,FREE,BRAKE,BRAKE,FREE,FREE,FREE,FREE,REGU,FREE},
		{FREE,TPORT,REGU,REGU,FREE,SPIKE,FREE,TPORT,FREE,REGU}
	},
	{
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{BRAKE,FREE,FREE,FREE,FREE,COIN,BRAKE,FREE,FREE,FREE},
		{FREE,FREE,FREE,FREE,BRAKE,FREE,FREE,FREE,BRAKE,FREE},
		{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
		{SPIKE,REGU,BRAKE,REGU,REGU,REGU,REGU,REGU,REGU,REGU}
	}
};


// Maps (4bits X index | 4bits Y index)
const logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [7:0] teleportCordinatesMap = {
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001},
		{8'b00001001,8'b01110110,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00001001,8'b00010110,8'b00001001,8'b00001001}
};
 

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [1:0] currentTeleportCordinatesMap;

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
			currentMap <= maps[lvl];
			currentTeleportCordinatesMap <= teleportCordinatesMap;
			prev_step <= maps[lvl][6][4];
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
		teleport_cordinates <= currentMap[y_bumpy_index_in_grid][X_bumpy_index_in_grid];
		end
end

endmodule 





