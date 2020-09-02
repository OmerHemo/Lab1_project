// (c) Technion IIT, Department of Electrical Engineering 2018 
// Implements a down counter 9 to 0 with enable and loadN data
// and count and tc outputs
// Alex Grinshpun

module decimal_down_counter
	(
	input logic clk,
	input logic resetN,
	input logic ena,
	input logic ena_cnt,
	input logic loadN, 
	input logic [3:0] datain,
	output logic [3:0] count,
	output logic tc
   );

// Down counter
always_ff @(posedge clk or negedge resetN)
  begin
	
	if ( !resetN )	begin // Asynchronic reset
				// fill your code here
				count=4'b0000;
			end
      else 	begin		// Synchronic logic	
				
					// fill your code here
					if(loadN==0) begin
						count=datain;
					end
					else if(ena==1 && ena_cnt==1) begin
						if (count == 0) begin
							  count<=4'h9;
						end
						else begin
								count<=count-1;
						end
					end
				
		end //Synch
	end //always	

	
	// Asynchronic tc
	assign tc = (count==0) ? 1'b1 :1'b0;			
			
					
endmodule
