module cmd_cfg(clk, rst_n, cmd_rdy, resp_sent, rd_done, set_capture_done,
	rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5, 
	resp, send_resp, clr_cmd_rdy, strt_rd, trig_pos, decimator, maskL, maskH,
	matchL, matchH, baud_cntL, baud_cntH, TrigCfg, 
	CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg, VIH, VIL);

parameter ENTRIES = 384,		// defaults to 384 for simulation 12288 for DE0
	LOG2 = 9;					// Log base 2 of number of entries
	
input clk, rst_n;
input [15:0] cmd; 		// 16 bit command from UART (host) to be executed
input cmd_rdy;			// indicates command is valid
input resp_sent; 		// indicates transmisison of resp to host is complete
input rd_done; 			// indicates the last byte of sample data has been read
input set_capture_done;	// from the capture module (sets capture done bit)
input [7:0] rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5;

output [7:0] resp; 		// data to send to host as a response
output send_resp; 		// used to inititate transmission to host (via UART)
output clr_cmd_rdy;		// when finished processing command use this to knock down command
output strt_rdy;		// asserted to fire off a read of channel RAMs
output [LOG2-1:0] trig_pos;		// how many samples after trigger to capture
output reg [3:0] decimator;		// goes to clk_rst_smpl block
output reg [7:0] maskL, maskH; 	// to trigger logic for protocol triggering
output reg [7:0] matchL, matchH;	// to trigger logic for protocol triggering
output reg [7:0] baud_cntL, baud_cntH;	// to trigger logic for protocol triggering
output reg [5:0] TrigCfg;		// some bits to trigger logic, other to capture unit
// to channel trigger logic
output reg [4:0] CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg;
output reg [7:0] VIH, VIL;		// Dual PWM to set thresholds

typedef enum reg [2:0] {IDLE, RD_REG, WRT_REG, DUMP, NEG_ACK, POS_ACK} state_t;
state_t, state, nxt_state;

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		state_t <= IDLE;
	else
		state_t <= nxt_state;

///////////////////////////////////////////////
// Flops for the various control registers.
// This part is used for the write reg command
//////////////////////////////////////////////

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		decimator <= 4'h0;
	else if((wrt_reg) && (cmd[12:8] == 5'h06) )
		decimator <= cmd[3:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		maskH <= 8'h00;
	else if((wrt_reg) && (cmd[12:8] == 5'h0B))
		maskH <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		maskL <= 8'h00;
	else if((wrt_reg) && (cmd[12:0] == 5'h0C))
		maskL <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		matchH <= 8'h00;
	else if(wrt_reg) && (cmd[12:0] == 5'h09))
		matchH <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		matchL <= 8'h00;
	else if(wrt_reg) && (cmd[12:0] == 5'h0A))
		matchL <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		baud_cntH <= 8'h06; 	// Setting 57600 to baud_cnt as default
	else if(wrt_reg) && (cmd[12:0] == 5'h0D))
		baud_cntH <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		baud_cntL <= 8'hC8;		// Setting 57600 to baud_cnt as default
	else if(wrt_reg) && (cmd[12:0] == 5'h0E))
		baud_cntL <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		TrigCfg <= 6'h03;
	else if(wrt_reg) && (cmd[12:0] == 5'h00))
		TrigCfg <= cmd[5:0];
	else if(set_capture_done)
		TrigCfg <= TrigCfg | 6'h10;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		CH1TrgCfg <= 5'h01;
	else if(wrt_reg) && (cmd[12:0] == 5'h01))
		CH1TrgCfg <= cmd[4:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		CH2TrgCfg <= 5'h01;
	else if(wrt_reg) && (cmd[12:0] == 5'h02))
		CH2TrgCfg <= cmd[4:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		CH3TrgCfg <= 5'h01;
	else if(wrt_reg) && (cmd[12:0] == 5'h03))
		CH3TrigCfg <= cmd[4:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		CH4TrgCfg <= 5'h01;
	else if(wrt_reg) && (cmd[12:0] == 5'h04))
		CH4TrigCfg <= cmd[4:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		CH5TrgCfg <= 5'h01;
	else if(wrt_reg) && (cmd[12:0] == 5'h05))
		CH5TrigCfg <= cmd[4:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		VIH  <= 8'hAA;
	else if(wrt_reg) && (cmd[12:0] == 5'h07))
		VIH <= cmd[7:0];

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		VIL <= 8'h55;
	else if(wrt_reg) && (cmd[12:0] == 5'h08))
		VIL <= cmd[7:0];

// State Machine guts
always_comb begin
	// Default outputs
	resp = 8'hxx;
	send_resp = 0;
	clr_cmd_rdy = 0;
	strt_rd = 0;
	wrt_reg = 0;
	nxt_state = IDLE;

	case(state)
		IDLE: begin
			if(cmd_rdy) begin
				unique case(cmd[15:14])
					2'b00: begin 	// Read Reg
						case(cmd[12:8])
							// Determine which register to read
							5'h00 : resp = {2'h0, TrigCfg};
							5'h01 : resp = {3'h0, CH1TrigCfg};
							5'h02 : resp = {3'h0, CH2TrigCfg};
							5'h03 : resp = {3'h0, CH3TrigCfg};
							5'h04 : resp = {3'h0, CH4TrigCfg};
							5'h05 : resp = {3'h0, CH5TrigCfg};
							5'h06 : resp = {4'h0, decimator};
							5'h07 : resp = VIH:
							5'h08 : resp = VIL;
							5'h09 : resp = matchH;
							5'h0A : resp = matchL;
							5'h0B : resp = maskH;
							5'h0C : resp = maskL;
							5'h0D : resp = baud_cntH;
							5'h0E : resp = baud_cntL;
							5'h0F : resp = trig_posH;
							5'h10 : resp = trig_posL;
							default: resp = 8'hEE;
						endcase
						send_resp = 1;
						clr_cmd_rdy = 1;
						nxt_state = IDLE;
					end
					2'b01: begin	// Write reg			
						nxt_state = POS_ACK;
						wrt_reg = 1;
					end
					2'b10: begin
						// The DUMP command still needs to be done
						nxt_state = IDLE;
						clr_cmd_rdy = 1;
						send_resp = 1;
						// nxt_state = DUMP; 
					end
					2'b11: begin	// Invalid command, send NEG_ACK
						resp = 8'hEE;
						send_resp = 1;
						clr_cmd_rdy = 1;
						nxt_state = IDLE;
					end
				endcase
			end else 
				nxt_state = IDLE;
		end
		POS_ACK: begin
			resp = 8'hA5;
			send_resp = 1;
			clr_cmd_rdy = 1;
			nxt_state = IDLE;
		end

	endcase
end

endmodule
