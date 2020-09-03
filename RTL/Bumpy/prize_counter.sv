module prize_counter(
	input logic clk,
	input logic resetN,
	input logic prize_collision,
	input logic enable,
	input logic	[10:0] pixelX,
	input logic	[10:0] pixelY,
	
	output logic [3:0] prize_counter,
	output logic open_gate,
	output logic [10:0] offsetX,// offset inside bracket from top left position 
	output logic [10:0] offsetY,
	output logic drawingRequest, // indicates pixel inside the bracket
	output logic [7:0] RGBout //optional color output for mux 
   );


always_ff @(posedge prize_collision or negedge resetN) begin
	if(!resetN) begin
		prize_counter <= 4'b0000;
		open_gate <= 1'b0;
	end
   else if(enable) begin
		if(prize_counter == 4'h9)
			open_gate <= 1'b1;
		else
			prize_counter<=prize_counter+1;
	end
end	

parameter  int OBJECT_WIDTH_X = 16;
parameter  int OBJECT_HEIGHT_Y = 32;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
logic insideBracket;
int rightX, bottomY;

//////////--------------------------------------------------------------------------------------------------------------=
// Ones digit position on the screen
logic signed [10:0] topLeftX = 597;
logic	signed [10:0] topLeftY = 2;


//////////--------------------------------------------------------------------------------------------------------------=
// Ones - Calculate object right  & bottom  boundaries
assign rightX	= (topLeftX + OBJECT_WIDTH_X);
assign bottomY = (topLeftY + OBJECT_HEIGHT_Y);


logic	[3:0] digit;


//////////--------------------------------------------------------------------------------------------------------------=
// Inside Bracket + Calc Digits
always_ff@(posedge clk or negedge resetN)
begin
	insideBracket = ((pixelX >= topLeftX) &&  (pixelX < rightX) && (pixelY >= topLeftY) &&  (pixelY < bottomY));
end


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
	
		if(insideBracket) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - topLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - topLeftY);
		end 
		else begin  
			RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
			drawingRequest <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
		end 
	end
end 
	
endmodule
