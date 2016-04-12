`timescale 100ps / 10ps
module dual_PWM(VIL_PWM, VIH_PWM, VIL, VIH, clk, rst_n);

input clk, rst_n;
input [7:0] VIL, VIH;
output VIL_PWM, VIH_PWM;

pwm8 low_PWM(.PWM_sig(VIL_PWM), .duty(VIL), .clk(clk), .rst_n(rst_n));
pwm8 high_PWM(.PWM_sig(VIH_PWM), .duty(VIH), .clk(clk), .rst_n(rst_n));

endmodule
