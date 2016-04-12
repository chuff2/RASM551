module cmd_cfg_tb();

  	logic clk, rst_n, clr_cmd_rdy, send_resp, RX, cmd_rdy, resp_sent, TX, RX;
	logic [7:0] resp;
	logic [15:0] cmd;
		
	UART_wrapper UART_wrapper(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .send_resp(send_resp), .resp(resp), 
		.RX(RX), .cmd_rdy(cmd_rdy), .cmd(cmd), .resp_sent(resp_sent), .TX(TX));


endmodule
