

module chan_trig(clk, armed, CHxTrigCfg, CHxTrig, CHxHff5, CHxLff5);

	input clk, armed, CHxHff5, CHxLff5;
	input logic [4:0] CHxTrigCfg;
	
	output CHxTrig;

	logic CHxH_armed_ff, CHxL_armed_ff, CHxH_armed_ff2, CHxL_armed_ff2;
	logic CHxH_flop, CHxL_flop;
	
	logic posedge_trig, negedge_trig, HL_trig, LL_trig;
	
	
	assign posedge_trig = CHxH_armed_ff2 & CHxTrigCfg[4];
	assign negedge_trig = CHxL_armed_ff2 & CHxTrigCfg[3];
	assign HL_trig = CHxH_flop & CHxTrigCfg[2];
	assign LL_trig = CHxL_flop & CHxTrigCfg[1];
	
	assign CHxTrig = posedge_trig | negedge_trig | HL_trig | LL_trig | CHxTrigCfg[0];
	
	//Channel Trigger Logic flops
	always_ff @(posedge CHxHff5, negedge armed) begin
		if(!armed)
			CHxH_armed_ff <= 1'b0;
		else
			CHxH_armed_ff <= 1'b1;
	end
	
	always_ff @(posedge CHxLff5, negedge armed) begin
		if(!armed)
			CHxL_armed_ff <= 1'b0;
		else
			CHxL_armed_ff <= 1'b1;
	end
	
	always_ff @(posedge clk) begin
		CHxH_flop <= CHxHff5;
		CHxL_flop <= CHxLff5;
		CHxH_armed_ff2 <= CHxH_armed_ff;
		CHxL_armed_ff2 <= CHxL_armed_ff;
	end
endmodule
