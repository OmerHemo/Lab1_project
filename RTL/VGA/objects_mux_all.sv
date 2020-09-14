//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 

module	objects_mux_all	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		// bumpy 
					input		logic	bumpyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] bumpyRGB, 
					
		// stopwatch 
					input		logic	stopwatchDrawingRequest,
					input		logic	[7:0] stopwatchRGB,
					
		// step 
					input		logic	stepDrawingRequest,
					input		logic	[7:0] stepRGB,
					
		// prize 
					input		logic	prizeDrawingRequest,
					input		logic	[7:0] prizeRGB,	
					
		//win
					input		logic	winDrawingRequest,
					input		logic	[7:0] winRGB,
		//die
					input		logic	dieDrawingRequest,
					input		logic	[7:0] dieRGB,
		
		//prize counter
					input		logic	prizeCounterDrawingRequest,
					input		logic	[7:0] prizeCounterRGB,
					
		//life counter
					input		logic	lifeCounterDrawingRequest,
					input		logic	[7:0] lifeCounterRGB,
							
		//button
					input		logic	diedTextDrawingRequest,
					input		logic	[7:0] diedTextRGB,
		// died text
					input		logic	buttonDrawingRequest,
					input		logic	[7:0] buttonRGB,
		// background 
					input		logic	[7:0] backGroundRGB,
					
					output	logic	[7:0] redOut, // full 24 bits color output
					output	logic	[7:0] greenOut, 
					output	logic	[7:0] blueOut 
					
);

logic [7:0] tmpRGB;



assign redOut	  = {tmpRGB[7:5], {5{tmpRGB[5]}}}; //--  extend LSB to create 10 bits per color  
assign greenOut  = {tmpRGB[4:2], {5{tmpRGB[2]}}};
assign blueOut	  = {tmpRGB[1:0], {6{tmpRGB[0]}}};

//
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			tmpRGB	<= 8'b0;
	end
	else begin
		if(buttonDrawingRequest == 1'b1)
			tmpRGB <= buttonRGB;
		else if(diedTextDrawingRequest == 1'b1)
			tmpRGB <= diedTextRGB;
		else if(winDrawingRequest == 1'b1 )
			tmpRGB <= backGroundRGB;
		else if(dieDrawingRequest == 1'b1 )
			tmpRGB <= backGroundRGB;
		else if(bumpyDrawingRequest == 1'b1 )
			tmpRGB <= bumpyRGB;
		else if(prizeCounterDrawingRequest == 1'b1 )
			tmpRGB <= prizeCounterRGB;
		else if(lifeCounterDrawingRequest == 1'b1 )
			tmpRGB <= lifeCounterRGB;
		else if(stopwatchDrawingRequest == 1'b1 )
			tmpRGB <= stopwatchRGB;
		else if (stepDrawingRequest == 1'b1 )   
			tmpRGB <= stepRGB;  
		else if(prizeDrawingRequest  == 1'b1 ) 
			tmpRGB <= prizeRGB;
		else
			tmpRGB <= backGroundRGB ; 
	end
end
	
endmodule


