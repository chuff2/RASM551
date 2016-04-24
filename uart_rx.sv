module  uart_rx(clk, rst_n, RX, clr_rdy, cmd, rdy);

input logic clk, rst_n, RX, clr_rdy;
output logic [7:0] cmd;
output logic rdy;

logic rxing, start, clr_reg, set_done;
logic rx_ff1, rx_ff2;
logic shift;

logic [8:0] rx_sr;
logic [6:0] baud_cnt;
logic [3:0] bit_cnt;



typedef enum reg {IDLE, RX_NOW} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
		
always_comb begin
	rxing = 0;
	set_done = 0;
	start = 0;
	
	case(state)
	  IDLE: if(!rx_ff2) begin
		nxt_state = RX_NOW; 
		start = 1;
	  end else
		nxt_state = IDLE;
		
	  // RX_NOW state
	  default: begin
		rxing = 1;
		if(bit_cnt == 4'b1010) begin
			nxt_state = IDLE;
			set_done = 1;
		end else
			nxt_state = RX_NOW;
	  end	
	endcase
end

// Double flop RX for meta-stability purposes
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n) begin
		rx_ff1 <= 1'b1;
		rx_ff2 <= 1'b1;
	end
	else begin
		rx_ff1 <= RX;
		rx_ff2 <= rx_ff1;
	end
				
always_ff @(posedge clk)
	if(shift)
		rx_sr <= {rx_ff2, rx_sr[8:1]};
		
assign cmd = rx_sr[7:0];
		
		
// The MUX that counts to 108
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		baud_cnt <= 7'h4A;
	else if(start)
		baud_cnt <= 7'h4A;
	else if(shift)
		baud_cnt <= 7'h13;
	else if(rxing)
		baud_cnt <= baud_cnt + 1;


// Check for counter = 108
assign shift = &baud_cnt;	

// Bit counting MUX logic
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		bit_cnt <= 4'h0;
	else if(start)
		bit_cnt <= 4'h0;
	else if(shift)
		bit_cnt <= bit_cnt + 1;


// D-FF for tx_done signal	
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		rdy <= 0;
	else if(start || clr_rdy)
		rdy <= 1'b0;
	else if(set_done)
		rdy <= 1'b1;
	
endmodule
