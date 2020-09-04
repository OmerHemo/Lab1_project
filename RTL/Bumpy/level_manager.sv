
module	level_manager	(	
					input		logic	clk,
					input 	logic resetN,
					input		logic one_sec,
					input 	logic bumpy_died,
					input		logic zero_lives,
					input		logic level_comp,
					
					output	logic died_screen,
					output	logic win_screen,
					output	logic [2:0] lvl,
					output	logic next_lvl
);

const int SCREEN_DURATION_SEC = 3;  


logic died_flag,win_flag;
logic [3:0] timer_died, timer_win;
		
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			died_screen <= 0;
			win_screen <= 0;
			lvl <= 0;
			next_lvl <= 0;
			died_flag <= 0;
			win_flag <= 0;
			timer_died <= 0;
			timer_win <= 0;
		end
		else begin
			if(bumpy_died)
				died_flag <= 1;
			if(level_comp) begin
				win_flag <= 1;
				lvl <= lvl + 1;
			end
		end
end

// died screen
always_ff@(posedge one_sec)
begin
	if( timer_died >= SCREEN_DURATION_SEC - 1) begin
		died_flag <= 0;
		timer_died <= 0;
		died_screen <= 0;
	end
	else if(died_flag) begin
		timer_died <= timer_died + 1;
		died_screen <= 1;
	end
end

// win screen
always_ff@(posedge one_sec)
begin
	if( timer_win >= SCREEN_DURATION_SEC - 1) begin
		win_flag <= 0;
		timer_win <= 0;
		win_screen <= 0;
		next_lvl <= 0;
	end
	else if(win_flag) begin
		timer_win <= timer_win + 1;
		win_screen <= 1;
		next_lvl <= 1;
	end
end



endmodule 





