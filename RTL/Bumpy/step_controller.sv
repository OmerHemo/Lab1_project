//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	step_controller	(
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					
					output	logic [2:0] step_type,
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY
);

//__________________________________
parameter  int Tile_WIDTH_X = 64;
parameter  int Tile_HEIGHT_Y = 64;
//__________________________________
const logic [2:0] FREE=3'b000, REGULAR_STEP=3'b001;
parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 10;


logic [0:2] [0:2] [2:0] tile_map = {
{3'd0,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0},
{3'd0,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0},
{3'd0,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0},
{3'd0,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0},
{3'd0,3'd1,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0},
{3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1,3'd1},
{3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0}, // not used
{3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0,3'd0} // not used
};


assign step_type = tile_map[pixelX >> 6][pixelY >> 6];
assign offsetX = (pixelX >> 6) << 6;
assign offsetY = (pixelY >> 6) << 6;

endmodule
