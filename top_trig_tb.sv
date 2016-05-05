`timescale 100ps / 10ps
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
	logic RX, TX, LED;
	
	//Signals for CommMaster
	logic [15:0] cmd;
	logic [7:0] resp;
	logic send_cmd, commTX, commRX, cmd_cmplt, resp_cmplt, clr_rdy;


	//TB signals	
	logic [10:0] channels;
	logic [5:0] CHTrigCfg;
	logic [9:0] prevChannels;	

	CommMaster comm(.clk(REF_CLK), .rst_n(RST_n), .snd_cmd(send_cmd), .cmd(cmd), .TX(commTX), .RX(commRX),
		.cmd_cmplt(cmd_cmplt), .resp(resp), .resp_cmplt(resp_cmplt), .clr_rdy(clr_rdy));
	
	LA_dig top(.clk400MHz(REF_CLK), .RST_n(RST_n), .locked(locked), .VIH_PWM(VIH_PWM), .VIL_PWM(VIL_PWM), 
		.CH1L(channels[0]), .CH1H(channels[1]), .CH2L(channels[2]), .CH2H(channels[3]), .CH3L(channels[4]), .CH3H(channels[5]), .CH4L(channels[6]), .CH4H(channels[7]),
		.CH5L(channels[8]), .CH5H(channels[9]), .RX(commTX), .TX(), .LED(LED));
	
	
	
	initial begin
		REF_CLK = 1'b0;
		channels = 11'b0;
		locked = 1'b0;
		VIH_PWM = 1'b0;
		VIL_PWM = 1'b0;
		send_cmd = 1'b0;
		commRX = 1'b0;
		
		RST_n = 0;
		@(posedge REF_CLK);
		@(posedge REF_CLK);
		@(posedge REF_CLK);
		@(posedge REF_CLK);
		@(posedge REF_CLK);
		@(negedge REF_CLK) RST_n = 1;
		
		//Disabling UART and SPI triggering
		$display("Disabling UART and SPI triggering...\n");
		cmd = {TRIG_CFG_WR, 8'h03};
		
		send_cmd = 1;
		@(posedge REF_CLK);
		@(negedge REF_CLK) send_cmd = 0;
		@(posedge cmd_cmplt);
				
		@(posedge top.iDIG.cmd_config.send_resp) begin
			$display("entering ACK checking block...\n");
			if(top.iDIG.cmd_config.resp != 8'ha5) begin
				$display("ERROR: Recieved incorrect response from cmd_cfg");
				$stop;
			end
		end
		
		$display("Wrote to registers and correct response received\n");
		
		@(posedge REF_CLK) begin
			if(~top.iDIG.protTrig) begin
			  $display("ERROR: After disabling UART and SPI triggering protTrig still not enabled\n");
			  $stop;
			end
		end
		
		if(top.iDIG.cmd_config.TrigCfg != 6'h03) begin
		
			$display("ERROR: Writing to TrigCfg failed\n");
		end
		
		force top.iDIG.armed = 1'b1;
		
		CHTrigCfg = 6'b0;
		
		while(~CHTrigCfg[5]) begin
			
			cmd = {CH1TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			send_cmd = 1;
			@(posedge REF_CLK);
			@(negedge REF_CLK) send_cmd = 0;

			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			cmd = {CH2TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			send_cmd = 1;
			@(posedge REF_CLK);
			@(negedge REF_CLK) send_cmd = 0;
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
							
			cmd = {CH3TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			send_cmd = 1;
			@(posedge REF_CLK);
			@(negedge REF_CLK) send_cmd = 0;
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			
			cmd = {CH4TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			send_cmd = 1;
			@(posedge REF_CLK);
			@(negedge REF_CLK) send_cmd = 0;
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			
			cmd = {CH5TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			send_cmd = 1;
			@(posedge REF_CLK);
			@(negedge REF_CLK) send_cmd = 0;
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);

				$display("Entering Channel Loop...\n");
				while(~channels[10]) begin
						
					repeat(6) begin
						@(posedge REF_CLK);
					end
					
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH1TrigCfg & 5'h01) begin

						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: Don't care set and Channel 1 not triggered\n");
							$stop;
						end		
					end	
					
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h02) & ~channels[0]) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: Low level set, CH1L is 0 and channel 1 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h04) & channels[1]) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: High level set, CH1H is 1 and channel 1 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h08) & (~channels[0] & prevChannels[0])) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: negedge set and channel 1 not triggered when CH1L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h10) & (channels[1] & ~prevChannels[0])) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: posedge set and channel 1 not triggered when CH1H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH2TrigCfg & 5'h01) begin

						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: Don't care set and Channel 2 not triggered\n");
							$stop;
						end		
					end
					
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h02) & ~channels[2]) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: Low level set, CH2L is 0 and channel 2 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h04) & channels[3]) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: High level set, CH2H is 1 and channel 2 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h08) & (~channels[2] & prevChannels[1])) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: negedge set and channel 2 not triggered when CH2L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h10) & (channels[3] & ~prevChannels[1])) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: posedge set and channel 2 not triggered when CH2H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH3TrigCfg & 5'h01) begin

						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: Don't care set and Channel 3 not triggered\n");
							$stop;
						end		
					end
					
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h02) & ~channels[4]) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: Low level set, CH3L is 0 and channel 3 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h04) & channels[5]) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: High level set, CH3H is 1 and channel 3 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h08) & (~channels[4] & prevChannels[2])) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: negedge set and channel 3 not triggered when CH3L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h10) & (channels[5] & ~prevChannels[2])) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: posedge set and channel 3 not triggered when CH3H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH4TrigCfg & 5'h01) begin

						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: Don't care set and Channel 4 not triggered\n");
							$stop;
						end		
					end
					
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h02) & ~channels[6]) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: Low level set, CH4L is 0 and channel 4 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h04) & channels[7]) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: High level set, CH4H is 1 and channel 4 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h08) & (~channels[6] & prevChannels[3])) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: negedge set and channel 4 not triggered when CH4L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h10) & (channels[7] & ~prevChannels[3])) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: posedge set and channel 4 not triggered when CH4H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
						
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH5TrigCfg & 5'h01) begin

						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: Don't care set and Channel 5 not triggered\n");
							$stop;
						end		
					end
					
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h02) & ~channels[8]) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: Low level set, CH5L is 0 and channel 5 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h04) & channels[9]) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: High level set, CH5H is 1 and channel 5 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h08) & (~channels[8] & prevChannels[4])) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: negedge set and channel 5 not triggered when CH5L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h10) & (channels[9] & ~prevChannels[4])) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: posedge set and channel 5 not triggered when CH5H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	

					prevChannels = channels[9:0];
					channels = channels + 1;
				end
				channels = 11'b0;
				prevChannels = 10'b0;
				CHTrigCfg = CHTrigCfg + 1;	
			end
	$display("SUCCESS!!!!!!!!!!!!!!!!!!!!!!!!\n");
	$stop;
	end
	
	always #1.25 REF_CLK = ~REF_CLK;
	

endmodule
