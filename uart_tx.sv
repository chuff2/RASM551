module uart_tx(clk, rst_n, trmt, tx_data, TX, tx_done);

input logic clk, rst_n, trmt;  // tmrt comes from master SM
input logic [7:0] tx_data; // Data to transmit
output logic TX, tx_done; // TX is serial data line. tx_done asserted back to master SM

logic txing, load, set_done, clr_done;
logic shift, nxt_tx_done;

logic [9:0] ten_bit_load, tx_sr;
logic [6:0] baud_cnt, nxt_baud_cnt;
logic [3:0] bit_cnt, nxt_bit_cnt;



typedef enum reg {IDLE, TX_NOW} state_t;
state_t state, nxt_state;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= nxt_state;
		
always_comb begin
	txing = 0;
	load = 0;
	set_done = 0;
	clr_done = 0;
	
	case(state)
	  IDLE: if(trmt) begin
		nxt_state = TX_NOW; 
		load = 1;
		clr_done = 1;
	  end else
		nxt_state = IDLE;
	
	  TX_NOW: begin
	  txing = 1;
	  if(bit_cnt == 4'b1010) begin
		nxt_state = IDLE;
		set_done = 1;
	  end else if(bit_cnt < 4'b1010)
		nxt_state = TX_NOW;
	  else
		nxt_state = IDLE;	
	end
	
	  default: nxt_state = IDLE;
	
	endcase
end

assign ten_bit_load = {1'b1, tx_data, 1'b0};

// The MUX that performs shifting of tx_sr
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		tx_sr <= 10'h3FF;
	else if(load)
		tx_sr <= ten_bit_load;
	else if(shift)
		tx_sr <= {1'b1, tx_sr[9:1]};

assign TX = tx_sr[0];

// The MUX that counts to 2604
always_comb
	if(shift | load)
		nxt_baud_cnt = 7'h00;
	else if(txing)
		nxt_baud_cnt = baud_cnt + 1;
	else
		nxt_baud_cnt = baud_cnt;

// D-FF		
always_ff @(posedge clk)
	baud_cnt <= nxt_baud_cnt;

// Check for counter = 108	
always_comb
	if(baud_cnt == 7'd108)
		shift =1;
	else
		shift = 0;

// Bit counting MUX logic
always_comb
	if(load)
		nxt_bit_cnt = 4'h0;
	else if(shift)
		nxt_bit_cnt = bit_cnt + 1;
	else
		nxt_bit_cnt = bit_cnt;
		
always_ff @(posedge clk)
	bit_cnt <= nxt_bit_cnt;

// D-FF for tx_done signal	
always_ff @(posedge clk or negedge rst_n)
	if(!rst_n)
		tx_done <= 0;
	else if(set_done)
		tx_done <= 1;
	else if(clr_done)
		tx_done <= 0;

	
endmodule
		
		
		
		
		
	
