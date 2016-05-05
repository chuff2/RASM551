//This is the CommMaster used for the cmd_cfg_tb


module CommMaster(clk, rst_n, snd_cmd, cmd, TX, RX, cmd_cmplt, resp, resp_cmplt, clr_rdy);

input logic clk, rst_n, snd_cmd, RX, clr_rdy;
input logic [15:0] cmd;
output logic TX, cmd_cmplt, resp_cmplt;
output [7:0] resp;
logic sel, trmt, tx_done;
logic [7:0] tx_data, cmd_lower;

typedef enum reg [2:0] {IDLE, SEND_HIGH, SEND_LOW, CMD_SENT} state_t;
state_t state, nxt_state;

typedef enum reg {RX_IDLE, RESPONSE_CMPLT} rx_state_t;
rx_state_t rx_state, rx_nxt_state;

always_ff @(posedge clk or negedge rst_n)
    if(!rst_n)
		state <= IDLE;
    else
		state <= nxt_state;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		rx_state <= RX_IDLE;
	else
		rx_state <= rx_nxt_state;
		
// SM control		
always_comb begin
	sel = 1'b0;
	trmt = 1'b0;
	cmd_cmplt = 1'b0;
	nxt_state = IDLE;
	
	case(state)
	IDLE: 
		if(snd_cmd) begin
			trmt = 1'b1;
			sel = 1'b1;
			nxt_state = SEND_HIGH;
		end else
			nxt_state = IDLE;
	SEND_HIGH:
		if(tx_done) begin
			trmt = 1'b1;
			nxt_state = SEND_LOW;
		end else
			nxt_state = SEND_HIGH;
	SEND_LOW:
		if(tx_done) begin
			cmd_cmplt = 1'b1;
			nxt_state = CMD_SENT;
		end else
			nxt_state = SEND_LOW;
	// CMD_SENT state
	default: 
		if(snd_cmd) begin
			trmt = 1'b1;
			sel = 1'b1;
			nxt_state = SEND_HIGH;
		end else
			nxt_state = CMD_SENT;
	endcase
end

always_comb begin
	rx_nxt_state = RX_IDLE;
	//clr_rdy = 1'b0;
	
	case(rx_state)
		
		RX_IDLE: begin
			if(resp_cmplt) begin
			 rx_nxt_state = RESPONSE_CMPLT;
			end
		end
		
		RESPONSE_CMPLT: begin
			//clr_rdy = 1'b1;
		end
	endcase
end

assign tx_data = sel ? cmd[15:8] : cmd_lower;

always @(posedge clk)
	if(snd_cmd)
		cmd_lower <= cmd[7:0];
		
UART UART_INST(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(TX), .RX(RX), .tx_done(tx_done), .clr_rdy(clr_rdy), .cmd(resp), .rdy(resp_cmplt));

endmodule
	
			

