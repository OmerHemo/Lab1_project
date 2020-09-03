
module	stopwatch_digits_object	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input 	logic [11:0] count,
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	RGBout, //optional color output for mux 
					output 	logic	[3:0] digit // digit to display
);

parameter  int OBJECT_WIDTH_X = 16;
parameter  int OBJECT_HEIGHT_Y = 32;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
logic insideBracketHundreds, insideBracketTens, insideBracketOnes;
int hundredsRightX, hundredsBottomY, tensRightX, tensBottomY, onesRightX, onesBottomY;

//////////--------------------------------------------------------------------------------------------------------------=
// Hundreds digit position on the screen
logic signed [10:0] hundredsTopLeftX = 2;
logic	signed [10:0] hundredsTopLeftY = 2;

// Tens digit position on the screen
logic signed [10:0] tensTopLeftX = 22;
logic	signed [10:0] tensTopLeftY = 2;

// Ones digit position on the screen
logic signed [10:0] onesTopLeftX = 42;
logic	signed [10:0] onesTopLeftY = 2;


//////////--------------------------------------------------------------------------------------------------------------=
// Hundreds - Calculate object right  & bottom  boundaries
assign hundredsRightX = (hundredsTopLeftX + OBJECT_WIDTH_X);
assign hundredsBottomY = (hundredsTopLeftY + OBJECT_HEIGHT_Y);

// Tens - Calculate object right  & bottom  boundaries
assign tensRightX	= (tensTopLeftX + OBJECT_WIDTH_X);
assign tensBottomY = (tensTopLeftY + OBJECT_HEIGHT_Y);

// Ones - Calculate object right  & bottom  boundaries
assign onesRightX	= (onesTopLeftX + OBJECT_WIDTH_X);
assign onesBottomY = (onesTopLeftY + OBJECT_HEIGHT_Y);


logic	[3:0] hundreds_digit, tens_digit, ones_digit;


//////////--------------------------------------------------------------------------------------------------------------=
// Inside Bracket + Calc Digits
always_ff@(posedge clk or negedge resetN)
begin
	insideBracketHundreds = ((pixelX >= hundredsTopLeftX) &&  (pixelX < hundredsRightX) && (pixelY >= hundredsTopLeftY) &&  (pixelY < hundredsBottomY));
	insideBracketTens = ((pixelX >= tensTopLeftX) &&  (pixelX < tensRightX) && (pixelY >= tensTopLeftY) &&  (pixelY < tensBottomY)); 
	insideBracketOnes = ((pixelX >= onesTopLeftX) &&  (pixelX < onesRightX) && (pixelY >= onesTopLeftY) &&  (pixelY < onesBottomY));
	hundreds_digit <= ((count) >> 8);
	tens_digit <= (((count) << 4) >> 8);
	ones_digit <= (((count) << 8) >> 8);
end


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
	
		if(insideBracketHundreds) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - hundredsTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - hundredsTopLeftY);
			digit <= hundreds_digit;
		end 
		else if(insideBracketTens) begin
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - tensTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - tensTopLeftY);
			digit <= tens_digit;
		end
		else if(insideBracketOnes) begin
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - onesTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - onesTopLeftY);
			digit <= ones_digit;
		end
		else begin  
			RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
			drawingRequest <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
			digit <= 0;
		end 
	end
end 
endmodule 