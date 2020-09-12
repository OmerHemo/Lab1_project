module life_counter(
	input logic clk,
	input logic resetN,
	input logic prize_collision,
	input logic enable,
	input logic	[10:0] pixelX,
	input logic	[10:0] pixelY,
	input logic die,
	
	
	output logic [3:0] life_counter,
	output logic lost_all_lifes,
	output logic [10:0] offsetX,// offset inside bracket from top left position 
	output logic [10:0] offsetY,
	output logic drawingRequest, // indicates pixel inside the bracket
	output logic [7:0] RGBout //optional color output for mux 
   );


logic flag;
always_ff @(posedge clk or negedge resetN) begin
	if(!resetN) begin
		life_counter <= 4'b0011;
		lost_all_lifes <= 1'b0;
		flag <= 0;
	end
   else begin
		if(enable && die && (flag == 0)) begin
			flag <= 1;
			if(life_counter > 0) begin
				life_counter <= life_counter-1;
			end
			else begin
				lost_all_lifes <= 1'b1;
			end
		end
		else if(~die) begin
			flag <= 0;
		end
		
	end
end	

parameter  int OBJECT_WIDTH_X = 16;
parameter  int OBJECT_HEIGHT_Y = 16;
parameter  logic [7:0] OBJECT_COLOR = 8'h6b; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF;// bitmap  representation for a transparent pixel 
 
logic insideBracketLeftLife, insideBracketMidLife, insideBracketRightLife;
int leftLifeRightX, leftLifeBottomY, midLifeRightX, midLifeBottomY, rightLifeRightX, rightLifeBottomY;

//////////--------------------------------------------------------------------------------------------------------------=
// LeftLife position on the screen
logic signed [10:0] leftLifeTopLeftX = 559;
logic	signed [10:0] leftLifeTopLeftY = 5;

// MidLife position on the screen
logic signed [10:0] midLifeTopLeftX = 577;
logic	signed [10:0] midLifeTopLeftY = 5;

// RightLife position on the screen
logic signed [10:0] rightLifeTopLeftX = 595;
logic	signed [10:0] rightLifeTopLeftY = 5;


//////////--------------------------------------------------------------------------------------------------------------=
// LeftLife - Calculate object right  & bottom  boundaries
assign leftLifeRightX = (leftLifeTopLeftX + OBJECT_WIDTH_X);
assign leftLifeBottomY = (leftLifeTopLeftY + OBJECT_HEIGHT_Y);

// MidLife - Calculate object right  & bottom  boundaries
assign midLifeRightX	= (midLifeTopLeftX + OBJECT_WIDTH_X);
assign midLifeBottomY = (midLifeTopLeftY + OBJECT_HEIGHT_Y);

// RightLife - Calculate object right  & bottom  boundaries
assign rightLifeRightX	= (rightLifeTopLeftX + OBJECT_WIDTH_X);
assign rightLifeBottomY = (rightLifeTopLeftY + OBJECT_HEIGHT_Y);


//////////--------------------------------------------------------------------------------------------------------------=
// Inside Bracket + Calc Digits
always_ff@(posedge clk or negedge resetN)
begin
	insideBracketLeftLife = ((pixelX >= leftLifeTopLeftX) &&  (pixelX < leftLifeRightX) && (pixelY >= leftLifeTopLeftY) &&  (pixelY < leftLifeBottomY) && (life_counter > 4'h2));
	insideBracketMidLife = ((pixelX >= midLifeTopLeftX) &&  (pixelX < midLifeRightX) && (pixelY >= midLifeTopLeftY) &&  (pixelY < midLifeBottomY) && (life_counter > 4'h1)); 
	insideBracketRightLife = ((pixelX >= rightLifeTopLeftX) &&  (pixelX < rightLifeRightX) && (pixelY >= rightLifeTopLeftY) &&  (pixelY < rightLifeBottomY) && (life_counter > 4'h0));
end


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
	
		if(insideBracketLeftLife) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - leftLifeTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - leftLifeTopLeftY);
		end 
		else if(insideBracketMidLife) begin
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - midLifeTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - midLifeTopLeftY);
		end
		else if(insideBracketRightLife) begin
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - rightLifeTopLeftX); //calculate relative offsets from top left corner
			offsetY	<= (pixelY - rightLifeTopLeftY);
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
