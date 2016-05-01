module UART_trig_rx(clk, rst_n, RX, baud_cnt, match, mask, UARTtrig);

	input logic clk, rst_n, RX;
	input logic [7:0] match, mask;
	input logic [15:0] baud_cnt;
	
	output logic UARTtrig;
	
	logic [7:0] cmd;
	logic [8:0] rx_sr;
	logic [3:0] bit_cnt;
	logic [15:0] baud_counter;
	
	logic rx_ff1, rx_ff2, rdy;
	logic start, rxing, clr_reg, set_done, shift, clr_rdy;
	
	typedef enum reg { IDLE, RX_NOW } state_t;
	state_t state, next_state;
	
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= next_state;
			
	//Double flop RX for meta-stability purposes
	always_ff @(posedge clk, negedge rst_n)
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
	
	//Baud counter
	always_ff @(posedge clk, negedge rst_n)
		if(!rst_n)
			baud_counter <= (baud_cnt / 2);
		else if(start)
			baud_counter <= (baud_cnt / 2);
		else if(shift)
			baud_counter <= 16'b0;
		else if(rxing)
			baud_counter <= baud_counter + 1;
		else
			baud_counter <= baud_counter;
	
	// D-FF for tx_done signal	
	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n)
			rdy <= 0;
		else if(start || clr_rdy)
			rdy <= 1'b0;
		else if(set_done)
			rdy <= 1'b1;	
	
	// Bit counting MUX logic
	always_ff @(posedge clk or negedge rst_n)
		if(!rst_n)
			bit_cnt <= 4'h0;
		else if(start)
			bit_cnt <= 4'h0;
		else if(shift)
			bit_cnt <= bit_cnt + 1;
			
	assign shift = (baud_counter == baud_cnt);
	assign cmd = rx_sr[7:0];
	assign UARTtrig = rdy & &((cmd ~^ match) | mask);//45 ~^ 05 | 40
	//assign UARTtrig = rdy & ((mask | cmd) == (mask | match));//not sure if this works...
	assign clr_rdy = rdy;
	
	always_comb begin
		rxing = 0;
		set_done = 0;
		start = 0;
		
		case(state)
			IDLE: if(!rx_ff2) begin
				next_state = RX_NOW;
				start = 1;
			end
			else
				next_state = IDLE;
			
			default: begin
				rxing = 1;
				if(bit_cnt == 4'b1010) begin
					next_state = IDLE;
					set_done = 1;
				end
				else
					next_state = RX_NOW;
			end
		endcase
	end
	
	
endmodule