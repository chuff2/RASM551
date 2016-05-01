module top_trig_tb();
	
	localparam TRIG_CFG_WR = {2'b01, 6'h0};
	localparam TRIG_CFG_RD = {2'b00, 6'h0};
	
	localparam CH1TrigCfgWr = {2'b01, 6'h01};
	localparam CH2TrigCfgWr = {2'b01, 6'h02};
	localparam CH3TrigCfgWr = {2'b01, 6'h03};
	localparam CH4TrigCfgWr = {2'b01, 6'h04};
	localparam CH5TrigCfgWr = {2'b01, 6'h05};
	
	localparam CH1TrigCfgRd = {2'b0, 6'h01};
	localparam CH2TrigCfgRd = {2'b0, 6'h02};
	localparam CH3TrigCfgRd = {2'b0, 6'h03};
	localparam CH4TrigCfgRd = {2'b0, 6'h04};
	localparam CH5TrigCfgRd = {2'b0, 6'h05};
	
	//Signals for top level
	logic REF_CLK, RST_n, locked;
	logic VIH_PWM, VIL_PWM;
	logic CH1L, CH1H;
	logic CH2L, CH2H;
	logic CH3L, CH3H;
	logic CH4L, CH4H;
	logic CH5L, CH5H;
	logic RX, TX, LED;
	
	//Signals for CommMaster
	logic [15:0] cmd;
	logic [7:0] resp;
	logic snd_cmd, commTX, commRX, cmd_cmplt, resp_cmplt, clr_rdy;
	
	logic [10:0] channels;
	logic [7:0];
	CommMaster comm(.clk(REF_CLK), .rst_n(RST_n), .snd_cmd(snd_cmd), .cmd(cmd), .TX(commTX), .RX(commRX),
		.cmd_cmplt(cmd_cmplt), .resp(resp), .resp_cmplt(resp_cmplt), .clr_rdy(clr_rdy));
	
	LA_dig top(.clk400MHz(REF_CLK), .RST_n(RST_n), locked(locked), .VIH_PWM(VIH_PWM), .VIL_PWM(VIL_PWM), 
		.CH1L(CH1L), .CH1H(CH1H), .CH2L(CH2L), .CH2H(CH2H), .CH3L(CH3L), .CH3H(CH3H), .CH4L(CH4L), .CH4H(CH4H),
		.CH5L(CH5L), .CH5H(CH5H), .RX(commTX), .TX(), .LED(LED));
	
	channels = {1'b0, CH5H, CH5L, CH4H, CH4L, CH3H, CH3L, CH2H, CH2L, CH1H, CH1L};
	
	initial begin
		channels = 11'b0;
		locked = 1'b0;
		VIH_PWM = 1'b0;
		VIL_PWM = 1'b0;
		snd_cmd = 1'b0;
		commRX = 1'b0;
		Initialize;
		
		//Disabling UART and SPI triggering
		$display("Disabling UART and SPI triggering...\n");
		cmd = {TRIG_CFG_WR, 8'h03};
		sendCmd(cmd);
		
		@(posedge top.iDIG.cmd_config.send_resp) begin
			if(top.iDIG.cmd_config.resp != 8'ha5) begin
				$display("Recieved incorrect response from cmd_cfg");
				$stop;
			end
		end
		
		$display("Wrote to registers and correct response received\n");
		
		@(posedge REF_CLK) begin
			if(~top.iDIG.protTrig) begin
			  $display("After disabling UART and SPI triggering protTrig still not enabled\n");
			  $stop;
			end
		end
		
		if(top.iDIG.cmd_config.TrigCfg != 6'h03) begin
		
			$display("Writing to TrigCfg failed~\n");
		end
		
		force top.iDIG.armed = 1'b1;
		
		
		
		while(~channels[10]) begin
			
			
			
			
		end
	end
	
	always #1.25 REF_CLK = ~REF_CLK;
	
	`include "tb_tasks.sv"
endmodule