module CommMasterSM(clk, rst_n, snd_cmd, cmd, TX, cmd_cmplt);

input logic clk, rst_n, snd_cmd;
input logic [15:0] cmd;
output logic TX, cmd_cmplt;
logic sel, trmt, tx_done;
logic [7:0] tx_data, cmd_lower;

typedef enum reg [2:0] {IDLE, SEND_HIGH, SEND_LOW, CMD_SENT} state_t;
state_t state, nxt_state;

always_ff @(posedge clk or negedge rst_n)
    if(!rst_n)
		state <= IDLE;
    else
		state <= nxt_state;

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

assign tx_data = sel ? cmd[15:8] : cmd_lower;

always @(posedge clk)
	if(snd_cmd)
		cmd_lower <= cmd[7:0];
		
// Instantiate UART TX
uart_tx UART_TX_INST(.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), .TX(TX), 
	.tx_done(tx_done) );

endmodule
	
			

