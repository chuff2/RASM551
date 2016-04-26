module UART_trig_rx_tb();

	logic clk, rst_n, RX, UARTtrig;
	logic [7:0] match, mask;
	logic [15:0] baud_cnt;


	UART_trig_rx uart(clk, rst_n, RX, baud_cnt, match, mask, UARTtrig);

	initial begin
		rst_n = 1'b1;
		clk = 1'b0;	
		RX = 1'b0;

	end

	always #2 clk = ~clk;

endmodule
