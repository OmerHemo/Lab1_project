module	rect_screen	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input		logic screen_on,
					
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
					
);

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 6;  // 2^6 = 64
localparam  int OBJECT_NUMBER_OF_X_BITS = 6;  // 2^6 = 64 
localparam  int BITMAP_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int BITMAP_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 


logic [0:BITMAP_WIDTH_X-1] [0:BITMAP_HEIGHT_Y-1] [8-1:0] object_colors = {
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h25, 8'h25, 8'h25, 8'h25, 8'h25, 8'h25, 8'h25, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h25, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF },
{8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hDB, 8'hCC, 8'h80, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hDB, 8'hDB, 8'hC4, 8'h00 },
{8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hCC, 8'hCC, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hCC, 8'hCC, 8'hC4, 8'hC4, 8'h00 },
{8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'hC4, 8'h80, 8'h00 },
{8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h80, 8'h80, 8'hC4, 8'hC4, 8'h80, 8'h00, 8'hFF },
{8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF }
};


// Frame size
const int x_FRAME_SIZE = 639 ;
const int y_FRAME_SIZE = 479 ;

parameter  int TEXT_WIDTH_X = 64;
parameter  int TEXT_HEIGHT_Y = 64;

int rightX ; //coordinates of the sides  
int bottomY ;
logic insideBracket ;
const logic [10:0] topLeftX = 288;
const logic [10:0] topLeftY = 208;

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign rightX	= (topLeftX + TEXT_WIDTH_X);
assign bottomY	= (topLeftY + TEXT_HEIGHT_Y);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
	end
	else if(screen_on) begin 
		insideBracket  = 	 ( (pixelX  >= topLeftX) &&  (pixelX < rightX) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
						   && (pixelY  >= topLeftY) &&  (pixelY < bottomY) )  ;
		
		if (insideBracket) // test if it is inside the rectangle 
		begin 
			RGBout <= object_colors[(pixelY - topLeftY)][(pixelX - topLeftX)];	// colors table 
		end
		else
			RGBout  <= TRANSPARENT_ENCODING;	// colors table 
	end 
	else begin  
		RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
	end 	
end

assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap

endmodule 

