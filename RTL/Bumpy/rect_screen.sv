module	rect_screen	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input		logic screen_on,
					
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
					
);
// Frame size
const int x_FRAME_SIZE = 639 ;
const int y_FRAME_SIZE = 479 ;

//__________________________________
parameter  logic [7:0] OBJECT_COLOR = 8'h01; 


localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else if(screen_on) begin 
				RGBout  <= OBJECT_COLOR;	// colors table 
				drawingRequest <= 1'b1;
				offsetX	<= (pixelX); //calculate relative offsets from top left corner
				offsetY	<= (pixelY);
	end 
	else begin  
		RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
		drawingRequest <= 1'b0 ;// transparent color 
		offsetX	<= 0; //no offset
		offsetY	<= 0; //no offset
	end 	
end

endmodule 

