module prize_counter(
	input logic clk,
	input logic resetN,
	input logic prize_collision,
	input logic enable,
	
	output logic [3:0] prize_counter,
	output logic open_gate
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
	
endmodule
