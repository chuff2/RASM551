module UART_wrapper(clk, rst_n, clr_cmd_rdy, cmd_rdy, cmd, send_resp, resp, resp_sent, RX, TX);
	
	output logic cmd_rdy, TX, resp_sent;
	output [15:0] cmd;
	
	input clk, send_resp, RX, rst_n, clr_cmd_rdy;
	input [7:0] resp;
	
	logic clr_rdy, selectSig, rdy;
	logic [7:0] rx_data, rx_data_ff, rx_data_ff_next;
	
	UART uart(.clk(clk), .rst_n(rst_n), .cmd(rx_data), .clr_rdy(clr_rdy), .trmt(send_resp), .tx_data(resp), .tx_done(resp_sent), .rdy(rdy), .TX(TX), .RX(RX));
	
	typedef enum reg [1:0] {IDLE, BYTE_1, BYTE_2} state_t;
	
	state_t state, nextState;
	
	always @(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= IDLE;
		else
			state <= nextState;
	end
	
	assign cmd = {rx_data_ff, rx_data};
	assign rx_data_ff_next = (selectSig) ? rx_data : rx_data_ff; 
	
	always@(posedge clk, negedge rst_n) begin
		if(!rst_n)
			rx_data_ff <= 8'b0;
		else
			rx_data_ff <= rx_data_ff_next;
	end
	
	always_comb begin
		selectSig = 1'b1;
		nextState = IDLE;
		cmd_rdy = 1'b0;
		clr_rdy = 1'b0;
		case(state)
			BYTE_2 : begin
				nextState = BYTE_2;
				selectSig = 1'b0;
				cmd_rdy = 1'b1;
				if(clr_cmd_rdy) begin
					cmd_rdy = 1'b0;
					selectSig = 1'b1;
					nextState = IDLE;
				end
			end
			
			BYTE_1 : begin
				selectSig = 1'b0;
				nextState = BYTE_1;
				if(rdy) begin
					clr_rdy = 1'b1;
					nextState = BYTE_2;
					cmd_rdy = 1'b1;
				end
			end
			
			default : begin
				if(rdy) begin
					clr_rdy = 1'b1;
					nextState = BYTE_1;
					selectSig = 1'b0;
				end
			end
			
		endcase
	end
	
	
endmodule