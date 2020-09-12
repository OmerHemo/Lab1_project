module	menu_screen	(	
					input		logic	clk,
					input		logic onSec,
					input		logic	resetN,
					input		logic menu_on,
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
					output	logic [1:0] selcted_lvl
					
);




//__________________________________
parameter  logic [7:0] OBJECT_COLOR_BACK = 8'b00000010;
parameter  logic [7:0] OBJECT_COLOR_REGU = 8'b10000000;
parameter  logic [7:0] OBJECT_COLOR_SLCT = 8'b00010000; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
localparam logic [2:0] NUM_OF_LVLS = 3'd4;


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
	else if(menu_on) begin
		if(!down_keyN && (press_flag == 0) && (selected < (NUM_OF_LVLS-1))) begin
			press_flag <= 1;
			selected	<=	selected + 1;
		end
		else if(!up_keyN && (press_flag == 0) && (selected > 0)) begin
			press_flag <= 1;
			selected	<=	selected - 1;
		end
		else if(down_keyN && up_keyN) begin
			press_flag <= 0;
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
	else if(menu_on) begin
		menu_comp	<=0;
		if(select_key) begin
			menu_comp	<=1;
			selcted_lvl <= selected;
		end
	end
end

int X_index_in_grid,y_index_in_grid;

assign X_index_in_grid = ((pixelX) >> 7);
assign y_index_in_grid = ((pixelY) >> 6);

//__________________________________
parameter int NUM_OF_ROWS = 7;
parameter int NUM_OF_COLS = 5;

const logic [2:0] FREE=3'b000, REGU=3'b001, SLCT=3'b010; //orientation consts

logic [0:NUM_OF_ROWS-1] [0:NUM_OF_COLS-1] [2:0] map = {
	{FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,REGU,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE},
	{FREE,FREE,FREE,FREE,FREE}
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
		else if(menu_on) begin
			button_type <= (current_map[y_index_in_grid][X_index_in_grid]);
			tileTopLeftX	<= ((X_index_in_grid)<<7); //calculate relative offsets from top left corner of the brick
			tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
			drawingRequest<= 1;
			RGBout<= OBJECT_COLOR_BACK;
		end
		else begin
			drawingRequest<= 0;
			RGBout<= 0;
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
						current_map[1][2] <= SLCT;
						current_map[2][2] <= REGU;
						current_map[3][2] <= REGU;
						current_map[4][2] <= REGU;
					end
					1:begin
						current_map[1][2] <= REGU;
						current_map[2][2] <= SLCT;
						current_map[3][2] <= REGU;
						current_map[4][2] <= REGU;
					end
					2:begin
						current_map[1][2] <= REGU;
						current_map[2][2] <= REGU;
						current_map[3][2] <= SLCT;
						current_map[4][2] <= REGU;
					end
					3:begin
						current_map[1][2] <= REGU;
						current_map[2][2] <= REGU;
						current_map[3][2] <= REGU;
						current_map[4][2] <= SLCT;
					end
					default: begin
						current_map[1][2] <= REGU;
						current_map[2][2] <= REGU;
						current_map[3][2] <= REGU;
						current_map[4][2] <= REGU;
					end
				endcase
			
		end
end


endmodule 

