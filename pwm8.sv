`timescale 100ps / 10ps
module pwm8(PWM_sig, duty, clk, rst_n);

input [7:0] duty;
input clk, rst_n;
output reg PWM_sig;

reg [7:0] cntr;
reg set, reset, d;

//controls the counter and the ff holding PWM_sig value
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		cntr <= 0;
		PWM_sig <= 0;	
	end
	else begin
		cntr <= cntr + 1;
		PWM_sig <= d;
	end
end

//comparator logic
always @(cntr, duty) begin
	//if counter is all 1's
	if (cntr == 8'hFF)
		set = 1;
	else if (duty == cntr) 
		reset = 1;
	else begin
		set = 0;
		reset = 0;
	end
end

//set, reset, or recirculate logic
always @(set, reset, PWM_sig) begin
	if (set == 1)
		d = 1;
	else if (reset == 1)
		d = 0;
	else 
		d = PWM_sig; 
end



endmodule