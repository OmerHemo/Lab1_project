module	regular_prize	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic	[10:0] tileTopLeftX, //position of specific tile in the grid
					input 	logic	[10:0] tileTopLeftY,  //position of specific tile in the grid
					input		logic [2:0] prize_type,
					
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
					
);
// Frame size
const int x_FRAME_SIZE = 639 ;
const int y_FRAME_SIZE = 479 ;
// grid size
const int x_GRID_SIZE = x_FRAME_SIZE;
const int y_GRID_SIZE = y_FRAME_SIZE;
//_______________________________
//__________________________________
parameter  int prize_WIDTH_X = 24;
parameter  int prize_HEIGHT_Y = 24;
parameter  int prize_TILE_OFFSET_x = 20;
parameter  int prize_TILE_OFFSET_y = 20;

//__________________________________
parameter  logic [7:0] OBJECT_COLOR = 8'h5b; 


localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 


const logic [2:0] FREE=3'b000, REGU=3'b001; //orientation consts


int Left_prize_x;
int Top_prize_y;
int Right_prize_x;
int Bottom_prize_y;
logic insideBracket; 

// Calculate object right  & bottom  boundaries
assign Left_prize_x = ( tileTopLeftX + prize_TILE_OFFSET_x );
assign Top_prize_y = ( tileTopLeftY + prize_TILE_OFFSET_y );
assign Right_prize_x	= (Left_prize_x + prize_WIDTH_X);
assign Bottom_prize_y	= (Top_prize_y + prize_HEIGHT_Y);

 
//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else if(prize_type==REGU) begin 
			insideBracket  = ( (pixelX  >= Left_prize_x) &&  (pixelX < Right_prize_x) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
								&& (pixelY  >= Top_prize_y) &&  (pixelY < Bottom_prize_y) )  ; 
			
			if (insideBracket) // test if it is inside the rectangle 
			begin 
				RGBout  <= OBJECT_COLOR ;	// colors table 
				drawingRequest <= 1'b1 ;
				offsetX	<= (pixelX - Left_prize_x); //calculate relative offsets from top left corner
				offsetY	<= (pixelY - Top_prize_y);
			end 
			else begin  
				RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
				drawingRequest <= 1'b0 ;// transparent color 
				offsetX	<= 0; //no offset
				offsetY	<= 0; //no offset
			end 	
	end
	else begin
			RGBout			<=	8'b0;
			drawingRequest	<=	1'b0;
	end
end 
endmodule 