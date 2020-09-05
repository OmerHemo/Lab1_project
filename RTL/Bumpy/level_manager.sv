
module	level_manager	(	
					input		logic	clk,
					input 	logic resetN,
					input		logic one_sec,
					input 	logic bumpy_died,
					input		logic zero_lives,
					input		logic level_comp,
					
					output	logic menu_screen,
					output	logic died_screen,
					output	logic win_screen,
					output	logic reset_fsm_N,
					output	logic [2:0] lvl
);

const int SCREEN_DURATION_SEC = 3;  


logic [3:0] timer_died, timer_win;

logic flag_win,flag_died;

assign reset_fsm_N = ~(win_screen || died_screen);

// win screen		
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			win_screen <= 0;
			lvl <= 0;
			flag_win <= 0;
		end
		else begin
			if(level_comp && (flag_win == 0)) begin
				win_screen <= 1;
				lvl <= lvl + 1;
				flag_win <= 1;
			end
			else if(timer_win >= SCREEN_DURATION_SEC - 1) begin
				win_screen <= 0;
				flag_win <= 0;
			end
		end
end

// died screen		
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN) begin
			died_screen <= 0;
			flag_died <= 0;
		end
		else begin
			if(bumpy_died && (flag_died == 0)) begin
				died_screen <= 1;
				flag_died <= 1;
			end
			else if(timer_died >= SCREEN_DURATION_SEC - 1) begin
				died_screen <= 0;
				flag_died <= 0;
			end
		end
end

// win timer
always_ff@(posedge one_sec or negedge resetN)
begin
	if(!resetN) begin
		timer_win <= 0;
	end
	else begin
		if( timer_win >= SCREEN_DURATION_SEC - 1) begin
			timer_win <= 0;
		end
		else if(win_screen) begin
			timer_win <= timer_win + 1;
		end
	end
end


// died timer
always_ff@(posedge one_sec or negedge resetN)
begin
	if(!resetN) begin
		timer_died <= 0;
	end
	else begin
		if( timer_died >= SCREEN_DURATION_SEC - 1) begin
			timer_died <= 0;
		end
		else if(died_screen) begin
			timer_died <= timer_died + 1;
		end
	end
end
endmodule 


