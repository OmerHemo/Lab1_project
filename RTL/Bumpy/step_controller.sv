//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	step_controller	(
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					
					output	logic [2:0] step_type,
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY
);

//__________________________________
parameter  int Tile_WIDTH_X = 6; // 2^6=64
parameter  int Tile_HEIGHT_Y = 6;// 2^6=64
//__________________________________
const logic [2:0] FREE=3'b000, REGULAR_STEP=3'b001;
parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;


logic [0:2] [0:2] [2:0] tile_map = {
{REGULAR_STEP,FREE,FREE,FREE,FREE,FREE,FREE,REGULAR_STEP},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE},
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE}, //Not Used
{FREE,FREE,FREE,FREE,FREE,FREE,FREE,FREE}  //Not Used
};


assign step_type = tile_map[pixelX >> Tile_WIDTH_X][pixelY >> Tile_HEIGHT_Y];
assign tileTopLeftX = (pixelX >> Tile_WIDTH_X) << Tile_WIDTH_X;
assign tileTopLeftY = (pixelY >> Tile_HEIGHT_Y) << Tile_HEIGHT_Y;

endmodule
