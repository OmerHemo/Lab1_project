
module	debug_led	(	
					input			logic	clk,
					input			logic	one_sec_clk,
					input			logic	resetN,
					input			logic	led0_in,
					input			logic	led1_in,
					input			logic	led2_in,
					
					output		logic	led0_out,
					output		logic	led1_out,
					output		logic	led2_out
);

logic led0_in_flag,led1_in_flag,led2_in_flag;

assign led0_out = led0_in_flag;
assign led1_out = led1_in_flag;
assign led2_out = led2_in_flag;

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
		led0_in_flag	<=	1'b0;
		led1_in_flag	<=	1'b0;
		led2_in_flag	<=	1'b0;
	end
	else begin
		if(led0_in)
			led0_in_flag <= 1'b1;
		if(led1_in)
			led1_in_flag <= 1'b1;
		if(led2_in)
			led2_in_flag <= 1'b1;
	end
end

always_ff@(posedge one_sec_clk) begin
	if(led0_in_flag)
		led0_in_flag <= 1'b0;
	if(led1_in_flag)
		led1_in_flag <= 1'b0;
	if(led2_in_flag)
		led2_in_flag <= 1'b0;
end


		

endmodule 