module trigger_logic(clk, rst_n, CH1Trig, CH2Trig, CH3Trig, CH4Trig,
	CH5Trig, protTrig, armed, set_capture_done, triggered);
	
	input logic clk, rst_n, CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig, protTrig, armed, set_capture_done;
	output logic triggered;
	
	logic triggered_in, trig_set;
	
	assign triggered_in = ~(~(((CH1Trig & CH2Trig & CH3Trig & CH4Trig & CH5Trig & protTrig) 
		& armed) | triggered) | set_capture_done);
		
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			triggered <= 1'b0;
		else
			triggered <= triggered_in;
	
endmodule