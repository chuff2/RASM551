module UART_trig_rx_tb();

	logic clk, rst_n, RX, trmt, tx_done, UARTtrig;
	logic [7:0] match, mask, tx_data;
	logic [15:0] baud_cnt;


	UART_trig_rx uart(.clk(clk), .rst_n(rst_n), .RX(RX), .baud_cnt(baud_cnt), .match(match), .mask(mask), .UARTtrig(UARTtrig));
	uart_tx uarttx(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(RX), .tx_done(tx_done));
	
	initial begin
		rst_n = 1'b0;
		clk = 1'b0;	
		trmt = 1'b0;
		match = 8'h55;
		mask = 8'b0;
		tx_data = 8'h55;
		baud_cnt = 16'd108;		
		
		@(negedge clk);
		@(negedge clk) begin
			rst_n = 1'b1;	
			trmt = 1'b1;
		end

		/*@(posedge tx_done) begin
			if(UARTtrig == 1'b1 ) $display("Success 1\n");
			else begin
				@(posedge clk) begin
					if(UARTtrig == 1'b1) $display("Success 1\n");
					else begin
					
						@(posedge clk) begin
							if(UARTtrig == 1'b1) $display("Success 1\n");
							else begin
								$display("Test 1 failed\n");
								$stop;
							end	
						end
					end
				end
			end
		
		end
		*/
		@(posedge uart.rdy) begin
			$stop;
		end
	end

	always #2 clk = ~clk;

endmodule
