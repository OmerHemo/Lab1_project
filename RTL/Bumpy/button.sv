module	button	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic	[10:0] tileTopLeftX, //position of specific tile in the grid
					input 	logic	[10:0] tileTopLeftY,  //position of specific tile in the grid
					input		logic [2:0] button_type,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout, //optional color output for mux
					output 	debug,
					output 	debug2
					
);
// Frame size
const int x_FRAME_SIZE = 639 ;
const int y_FRAME_SIZE = 479 ;
// grid size
const int x_GRID_SIZE = x_FRAME_SIZE;
const int y_GRID_SIZE = y_FRAME_SIZE;
//__________________________________
parameter int BUTTON_WIDTH_X = 120;
parameter int BUTTON_HEIGHT_Y = 50;
parameter int BUTTON_PADDING_X = 4;
parameter int BUTTON_PADDING_Y = 7; 
//__________________________________
parameter  logic [7:0] OBJECT_COLOR_BACK = 8'b00000010;
parameter  logic [7:0] OBJECT_COLOR_REGU = 8'b10000000;
parameter  logic [7:0] OBJECT_COLOR_SLCT = 8'b10010001; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 

const logic [2:0] FREE=3'b000, REGU=3'b001, SLCT=3'b010; //orientation consts


int Left_button_x;
int Top_button_y;
int Right_button_x;
int Bottom_button_y;
logic insideBracket; 

// Calculate object right  & bottom  boundaries
assign Left_button_x = ( tileTopLeftX + BUTTON_PADDING_X );
assign Top_button_y = ( tileTopLeftY + BUTTON_PADDING_Y );
assign Right_button_x	= (Left_button_x + BUTTON_WIDTH_X);
assign Bottom_button_y	= (Top_button_y + BUTTON_HEIGHT_Y);

 
//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN )
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
		debug <= 0;
		debug2 <= 0;
	end
	else begin 
			debug <= 1;
			insideBracket  = ( (pixelX  >= Left_button_x) &&  (pixelX < Right_button_x) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
								&& (pixelY  >= Top_button_y) &&  (pixelY < Bottom_button_y) )  ; 
			
			if ((button_type != FREE) && insideBracket) // test if it is inside the rectangle 
			begin
				debug2 <= 1;
				if (button_type == SLCT) begin
					RGBout  <= OBJECT_COLOR_SLCT;
				end
				else begin
					RGBout  <= OBJECT_COLOR_REGU;
				end
				drawingRequest <= 1'b1 ;
				offsetX	<= (pixelX - Left_button_x); //calculate relative offsets from top left corner
				offsetY	<= (pixelY - Top_button_y);
			end 
			else begin  
				RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
				drawingRequest <= 1'b0 ;// transparent color 
				offsetX	<= 0; //no offset
				offsetY	<= 0; //no offset
			end 	
	end
	/*else begin
			RGBout			<=	8'b0;
			drawingRequest	<=	1'b0;
	end*/
end 
endmodule 