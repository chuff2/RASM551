module CommMaster_UART_wrapper_tb();


	logic clk, rst_n, snd_cmd, cmd_cmplt, resp_cmplt, clr_cmd_rdy, send_resp, TX_RX, RX_TX, cmd_rdy, resp_sent;
	logic [15:0] cmd_sent, cmd_rcvd;
	logic [7:0] resp_to_send, resp_rcvd;

	CommMaster commMaster(.clk(clk), .rst_n(rst_n), .snd_cmd(snd_cmd), .cmd(cmd_sent), .TX(TX_RX), .RX(RX_TX), .cmd_cmplt(cmd_cmplt), 
		.resp(resp_rcvd), .resp_cmplt(resp_cmplt));
	UART_wrapper uart_wrapper(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .send_resp(send_resp), .resp(resp_to_send), .RX(TX_RX), 
		.cmd_rdy(cmd_rdy), .cmd(cmd_rcvd), .resp_sent(resp_sent), .TX(RX_TX));


	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		resp_to_send = 8'h00;
		send_resp = 1'b0;
		snd_cmd = 1'b0;
		clr_cmd_rdy = 1'b0;
		@(negedge clk) begin
			rst_n = 1'b1;
		end

		repeat(2^8) begin
				
			@(negedge clk) begin
				send_resp = 1'b1;
			end
			@(negedge clk) begin

				send_resp = 1'b0;
			end
			@(posedge resp_cmplt) begin
				if(resp_rcvd != resp_to_send) begin
					$display("Something's not right...\n");
				end	

				else begin

					resp_to_send = resp_to_send + 1;
				end
			end
		end

		$display("SUCCESS!!\n");
	end
	always #2 clk = ~clk;
endmodule
