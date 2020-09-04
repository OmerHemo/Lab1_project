
module decimal_3_digits_counter
	(
	input  logic clk, 
	input  logic resetN,
	input  logic ena, 
	input  logic ena_cnt, 
	input  logic loadN, 
	output logic [11:0] Count_out,
	output logic tc
   );
	
	logic tc_ones;
	logic tc_tens;
	logic tc_hundreds;
	assign enable = ena & ena_cnt;
	logic [11:0] Data_init = 12'b000100100000;
	logic hundreds_en;
	assign hundreds_en = tc_ones & tc_tens;
	
	logic resetCounterN;
	assign resetCounterN = ((!loadN) || (hundreds_en && tc_hundreds))? 1'b0 : 1'b1;
	
// units (Ones) 
	decimal_down_counter ones_counter(
		.clk(clk), 
		.resetN(resetN), 
		.ena(enable), 
		.ena_cnt(enable),  
		.loadN(resetCounterN), 
		.datain(Data_init[3:0]),
		.count(Count_out[3:0]),
		.tc(tc_ones)
	);

	
// Tens
	decimal_down_counter tens_counter( 
		.clk(clk), 
		.resetN(resetN), 
		.ena(enable), 
		.ena_cnt(tc_ones),
		.loadN(resetCounterN), 
		.datain(Data_init[7:4]),
		.count(Count_out[7:4]),
		.tc(tc_tens)	
	);

// Hundreds
	decimal_down_counter hundreds_counter( 
		.clk(clk), 
		.resetN(resetN), 
		.ena(enable), 
		.ena_cnt(hundreds_en),
		.loadN(resetCounterN), 
		.datain(Data_init[11:8]),
		.count(Count_out[11:8]),
		.tc(tc_hundreds)	
	);

	 
		assign tc = (Count_out == 0) ? 1'b1 :1'b0;

 
endmodule
