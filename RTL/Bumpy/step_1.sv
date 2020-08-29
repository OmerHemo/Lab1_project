//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	step_1	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic signed	[10:0] topLeftX, //position on the screen 
					input 	logic	signed [10:0] topLeftY,
					input		logic [2:0] step_type,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
);

parameter  int OBJECT_WIDTH_X = 60;
parameter  int OBJECT_HEIGHT_Y = 7;
parameter  int STEP_OFFSET_x = 2;
parameter  int STEP_OFFSET_y = 50;
parameter  int DEBUG_X = 200;
parameter  int DEBUG_Y = 200;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
// int rightX ; //coordinates of the sides  
// int bottomY ;
logic insideBracket; 

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign topLeft_step_x = ( DEBUG_X + STEP_OFFSET_x );
assign topLeft_step_y = ( DEBUG_y + STEP_OFFSET_y );
assign bottomRight_step_x	= (topLeft_step_x + OBJECT_WIDTH_X);
assign bottomRight_step_y	= (topLeft_step_y + OBJECT_HEIGHT_Y);


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else if(step_type == 3'b1) begin 
	
//		if ( (pixelX  >= topLeftX) &&  (pixelX < rightX) 
//			&& (pixelY  >= topLeftY) &&  (pixelY < bottomY) ) // test if it is inside the rectangle 

		//this is an example of using blocking sentence inside an always_ff block, 
		//and not waiting a clock to use the result  
		
		insideBracket  = 	 ( (pixelX  >= topLeft_step_x) &&  (pixelX < bottomRight_step_x) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
						   && (pixelY  >= topLeft_step_y) &&  (pixelY < bottomRight_step_y) )  ; 
		
		if (insideBracket) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - topLeft_step_x); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - topLeft_step_y);
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