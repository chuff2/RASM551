module pwm8_tb();
reg rst_n, clk;
reg [7:0] duty;
wire PWM_sig;

integer cycleCounter;

pwm8 DUT(.PWM_sig(PWM_sig), .duty(duty), .clk(clk), .rst_n(rst_n));

initial begin
	clk = 0;
	rst_n = 0;
	duty = 8'h05;
	cycleCounter = 0;
	repeat (5) @(posedge clk);
	rst_n = 1;
	//now we should stay high for 5 cycles
	@(DUT.cntr == 8'hFF);
	repeat (8) @(posedge clk);
	if (PWM_sig == 1'b0) begin
		$display("Success!!!");
	end
	else begin
		$display("Failure...");
	end
	#100;
	$stop;
end

always #5 clk = ~clk;
endmodule
