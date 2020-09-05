module	menu_screen	(	
					input		logic	clk,
					input		logic onSec,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input		logic down_keyN,
					input		logic up_keyN,
					input		logic slct_keyN,
					input		logic screen_on,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout, //optional color output for mux
					output	logic menu_comp,
					output	logic [2:0] selcted_lvl
					
);


//__________________________________
parameter  int NUM_OF_ROWS = 7;
parameter  int NUM_OF_COLS = 5;

const logic [2:0] FREE=3'b000, REGU=3'b001; //orientation consts

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] map = {
	{FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE}
};

assign X_index_in_grid = ((pixelX) >> 7);
assign y_index_in_grid = ((pixelY) >> 6);

//__________________________________
parameter  logic [7:0] OBJECT_COLOR_BACK = 8'b00000010;
parameter  logic [7:0] OBJECT_COLOR_REGU = 8'b10000000;
parameter  logic [7:0] OBJECT_COLOR_SLCT = 8'b00010000; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 





//__________________________________
parameter int BUTTON_WIDTH_X = 120;
parameter int BUTTON_HEIGHT_Y = 50;
parameter int BUTTON_PADDING_X = 4;
parameter int BUTTON_PADDING_Y = 7; 

int Left_button_x;
int Top_button_y;
int Right_button_x;
int Bottom_button_y;
logic insideBracket; 

// Calculate object right  & bottom  boundaries
assign Left_button_x = ( X_index_in_grid + BUTTON_PADDING_X );
assign Top_button_y = ( y_index_in_grid + BUTTON_PADDING_Y );
assign Right_button_x	= (Left_button_x + BUTTON_WIDTH_X);
assign Bottom_button_y	= (Top_button_y + BUTTON_HEIGHT_Y);

// select
logic [2:0] selected;
logic up_key,down_key;
assign up_key = ~up_keyN;
assign down_key = ~down_keyN;
logic press_flag;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
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
	end
end

// menu_comp
assign select_key = ~slct_keyN;
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
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
 
 
// menu draw
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin
		if(screen_on == 0) begin
			RGBout			<=	8'b0;
			drawingRequest	<=	1'b0;
		end
		else if(map[y_index_in_grid][X_index_in_grid]==REGU) begin 
			insideBracket  = ( (pixelX  >= Left_button_x) &&  (pixelX < Right_button_x) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
								&& (pixelY  >= Top_button_y) &&  (pixelY < Bottom_button_y) )  ; 
			
			if (insideBracket) begin // test if it is inside the rectangle 
				if((selected + 1) == y_index_in_grid)
					RGBout  <= OBJECT_COLOR_SLCT;
				else
					RGBout  <= OBJECT_COLOR_REGU;	// colors table 
				drawingRequest <= 1'b1;
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
		else begin
			RGBout			<=	OBJECT_COLOR_BACK;
			drawingRequest	<=	1'b1;
		end
	end
end


endmodule 