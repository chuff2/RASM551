module dual_PWM_tb();

reg clk, rst_n;
reg [7:0] VIH, VIL;
wire VIL_PWM, VIH_PWM;

dual_PWM DUT(.VIL_PWM(VIL_PWM), .VIH_PWM(VIH_PWM), .VIL(VIL), .VIH(VIH), .clk(clk), .rst_n(rst_n));

initial begin
	clk = 0;
	rst_n = 0;
	VIH = 8'h12;
	VIL = 8'h03;
	@(posedge clk);
	rst_n = 1;
	#400; //do another reset
	rst_n = 0;
	@(posedge clk);
	rst_n = 1;
	VIH = 8'h05;
	VIL = 8'h01;
	#100000;
	$stop;
end

always #5 clk = ~clk;

endmodule
