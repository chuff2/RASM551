module chan_capture(clk, rst_n, trig_pos, run_mode, wrt_smpl, armed, capture_done, we, smpl_cnt, trig);

parameter ENTRIES = 384,		// defaults to 384 for simulation 12288 for DE0
	LOG2 = 9;					// Log base 2 of number of entries

input logic clk, rst_n;
input logic trig_pos;		// Count how many samples we have recorded after trigger
input logic run_mode;		// starts the capture state macine
input logic wrt_smpl;		// Tells us when to write a sample to RAM
input logic trig;
output logic armed;			// Tell the trigger logic when we are ready to start checking for triggers
output logic capture_done;	// Signal goes high when capture is finished and stays high
output logic we;					// we signal going to RAM
output logic [LOG2-1:0] smpl_cnt;	// This will connect to waddr of RAMqueues

logic [LOG2-1:0] trig_cnt;

logic rst_smpl_cnt, rst_trig_cnt, inc_smpl_cnt, inc_trig_cnt; 
logic set_armed, clr_armed, set_cap_done, clr_cap_done;

typedef enum reg [2:0] {IDLE, WAIT_WRT_SMPL, INCR, CHECK_TRIG_CNT, CHECK_SMPL_CNT, WAIT_CAP_DONE} state_t;
state_t state, nstate;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= nstate;

// Flip flops to store signals
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n || rst_trig_cnt)
		trig_cnt <= 0;
	else if(inc_trig_cnt)
		trig_cnt <= trig_cnt + 1'b1;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n || rst_smpl_cnt)
		smpl_cnt <= 0;
	else if(inc_smpl_cnt)
		smpl_cnt <= smpl_cnt + 1'b1;

always_ff @(posedge clk, negedge rst_n)
	if(!rst_n || clr_armed)
		armed <= 0;
	else if(set_armed)
		armed <= 1;
		
//note here that we do not need clr_cap_done because that is handled by the "command processing SM"
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		capture_done <= 0;
	else if(set_cap_done)
		capture_done <= 1;
		
always_comb begin
	// Default outputs
	rst_smpl_cnt = 0;
	inc_smpl_cnt = 0;
	rst_trig_cnt = 0;
	inc_trig_cnt = 0;
	set_armed = 0;
	clr_armed = 0;
	set_cap_done = 0;
	we = 0;

	case(state)
		IDLE: 
			if(run_mode) begin
				nstate = WAIT_WRT_SMPL;
				rst_smpl_cnt = 1;
				rst_trig_cnt = 1;
			end else
				nstate = IDLE;
		WAIT_WRT_SMPL:
			if(wrt_smpl) begin
				we = 1;
				nstate = INCR;
			end else
				nstate = WAIT_WRT_SMPL;
		INCR: 
			if(trig) begin
				inc_trig_cnt = 1;
				nstate = CHECK_TRIG_CNT;
			end else begin
				inc_smpl_cnt = 1;
				nstate = CHECK_SMPL_CNT;
			end
		CHECK_TRIG_CNT: 
			if(trig_cnt == trig_pos) begin
				set_cap_done = 1;
				clr_armed = 1;
				nstate = WAIT_CAP_DONE;
			end else
				nstate = WAIT_WRT_SMPL;
		CHECK_SMPL_CNT: begin
			nstate = WAIT_WRT_SMPL;
			if(smpl_cnt + trig_pos == ENTRIES)
				set_armed = 1;
		end
		WAIT_CAP_DONE: 
			if(capture_done)
				nstate = WAIT_CAP_DONE;
			else
				nstate = IDLE;
		default: nstate = IDLE;
	endcase
end
	
endmodule
	
	
