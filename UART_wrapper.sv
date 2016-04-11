module UART_wrapper(clk, rst_n, clr_cmd_rdy, send_resp, resp, RX, cmd_rdy, cmd, resp_sent, TX);

input logic clk, rst_n, clr_cmd_rdy, send_resp, RX;
input logic [7:0] resp;
output logic [15:0] cmd;
output logic cmd_rdy, resp_sent, TX;

logic clr_rdy, rdy, sel, set_cmd_rdy;
logic [7:0] rx_data;
logic [7:0] cmd_upper, nxt_cmd_upper;

// Instantiate UART
uart UART_INST (.clk(clk), .rst_n(rst_n), .trmt(resp_sent), .tx_data(resp), 
	.TX(TX), .RX(RX), .tx_done(resp_sent), .clr_rdy(clr_rdy), .cmd(rx_data), .rdy(rdy) );

// UART wrapper SM

typedef enum reg [1:0] {IDLE, UBYTE, LBYTE, CMD_READY} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;


// SM guts
always_comb begin
	clr_rdy = 1'b0;
	set_cmd_rdy = 1'b0;
	sel = 1'b0;
	nxt_state = IDLE;

	case(state)
		IDLE: 
		if(clr_cmd_rdy) begin
			nxt_state = UBYTE;
			clr_rdy = 1'b1;
		end else
			nxt_state = IDLE;
		UBYTE:
		if(rdy) begin
			sel = 1'b1;
			clr_rdy = 1'b1;
			nxt_state = LBYTE;
		end else
			nxt_state = UBYTE;
		LBYTE: 
		if(rdy) begin
			set_cmd_rdy = 1'b1;
			nxt_state = CMD_READY;
		end else
			nxt_state = LBYTE;
		// CMD_READY STATE
		default: 
		if(clr_cmd_rdy) begin
			nxt_state = UBYTE;
			clr_rdy = 1;
		end else begin
			nxt_state = CMD_READY;
		end
	endcase
end

always_ff @(posedge clk)
	cmd_upper <= nxt_cmd_upper;

// cmd_rdy flop
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		cmd_rdy <= 0;
	else if(clr_cmd_rdy)
		cmd_rdy <= 0;
	else if(set_cmd_rdy)
		cmd_rdy <= 1;

assign nxt_cmd_upper = sel ? rx_data : cmd_upper;
assign cmd = {cmd_upper, rx_data};

endmodule
