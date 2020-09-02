
module	tile_selector	(	
					input		logic	clk,
					input 	logic	[10:0] bumpyX,// current VGA pixel 
					input 	logic	[10:0] bumpyY,
					
					output 	logic	[10:0] tileTopLeftX, 
					output 	logic	[10:0] tileTopLeftY
);


int X_index_in_grid ;  
int y_index_in_grid ;

assign X_index_in_grid = ((bumpyX) >> 6);
assign y_index_in_grid = ((bumpyY) >> 6);


//======--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk)
begin
		tileTopLeftX	<= ((X_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
		tileTopLeftY	<= ((y_index_in_grid)<<6); //calculate relative offsets from top left corner of the brick
end 
endmodule 
