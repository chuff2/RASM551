module SPI_RX(SPItrig, clk, rst_n, SS_n, SCLK, MOSI, edg, len8_16, mask, match);

//NOTE: MSB comes first
output logic SPItrig;
input clk, rst_n, SS_n, SCLK, MOSI, edg, len8_16;
input [15:0] mask, match;

//signals not in the signature
logic SS_n1, SS_n2;
logic MOSI_ff1, MOSI_ff2, MOSI_ff3;
logic SCLK_ff1, SCLK_ff2, SCLK_ff3;
logic [15:0] shft_reg, shft_reg_in;
logic shift;

typedef enum reg {IDLE, BUSY} state_t;
state_t state, nxt_state;

//flop SS_n twice for state machine
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		SS_n2 <= 1'b0;
		SS_n1 <= 1'b0;
	end
	else begin
		SS_n2 <= SS_n1;
		SS_n1 <= SS_n;
	end
end

//triple flop MOSI
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		MOSI_ff1 <= 1'b0;
		MOSI_ff2 <= 1'b0;
		MOSI_ff3 <= 1'b0;
	end
	else begin
		MOSI_ff3 <= MOSI_ff2;
		MOSI_ff2 <= MOSI_ff1;
		MOSI_ff1 <= MOSI;
	end
end

//triple flop SCLK 
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		SCLK_ff1 <= 1'b0;
		SCLK_ff2 <= 1'b0;
		SCLK_ff3 <= 1'b0;
	end
	else begin
		SCLK_ff3 <= SCLK_ff2;
		SCLK_ff2 <= SCLK_ff1;
		SCLK_ff1 <= SCLK;
	end
end

//logic for SCLK_rise and SCLK_fall based on the ff values of SCLK
assign SCLK_rise = (SCLK_ff2 == 1 && SCLK_ff3 == 0) ? 1'b1: 1'b0;
assign SCLK_fall = (SCLK_ff2 == 0 && SCLK_ff3 == 1) ? 1'b1: 1'b0;

//below logic is for the shift register (ff and mux in)
assign shft_reg_in = (shift) ? {shft_reg[14:0], MOSI_ff3}: shft_reg;
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		shft_reg <= 0;
	end
	else begin
		shft_reg <= shft_reg_in;
	end
end

//state machine logic
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= nxt_state;
	end
end

always_comb begin
	
	SPItrig = 1'b0;
	nxt_state = IDLE;
	
	case (state)
		BUSY : begin
			nxt_state = BUSY;
			if (SS_n2) begin
				//comparing to 8 bit match
				if (len8_16 == 1) begin
					//&((shft_reg ~^ match) | ~mask)
					//if (shft_reg[15:8] ==? masked_match[7:0]) begin
					if (&((shft_reg[7:0] ~^ match[7:0]) | mask[7:0])) begin
						SPItrig = 1'b1;
					end
				end
				else if (len8_16 == 0) begin
					//&((shft_reg[15:0] ~^ match[15:0]) | ~mask[15:0])
					//if (shft_reg[15:0] ==? masked_match[15:0]) begin
					if (&((shft_reg[15:0] ~^ match[15:0]) | mask[15:0])) begin
						SPItrig = 1'b1;
					end
				end
				
				nxt_state = IDLE;
			end
		end
		//IDLE
		default: begin
			if (!SS_n2) begin
				nxt_state = BUSY;
			end
		end
	endcase
end



//logic that determines the shift signal
assign shift = (edg) ? SCLK_rise: SCLK_fall;


endmodule
