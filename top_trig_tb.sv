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
	logic send_cmd, commTX, commRX, cmd_cmplt, resp_cmplt, clr_rdy;


	//TB signals	
	logic [10:0] channels;
	logic [5:0] CHtrigCfg;
	logic [9:0] prevChannels;	

	CommMaster comm(.clk(REF_CLK), .rst_n(RST_n), .snd_cmd(send_cmd), .cmd(cmd), .TX(commTX), .RX(commRX),
		.cmd_cmplt(cmd_cmplt), .resp(resp), .resp_cmplt(resp_cmplt), .clr_rdy(clr_rdy));
	
	LA_dig top(.clk400MHz(REF_CLK), .RST_n(RST_n), locked(locked), .VIH_PWM(VIH_PWM), .VIL_PWM(VIL_PWM), 
		.CH1L(CH1L), .CH1H(CH1H), .CH2L(CH2L), .CH2H(CH2H), .CH3L(CH3L), .CH3H(CH3H), .CH4L(CH4L), .CH4H(CH4H),
		.CH5L(CH5L), .CH5H(CH5H), .RX(commTX), .TX(), .LED(LED));
	
	assign channels = {1'b0, CH5H, CH5L, CH4H, CH4L, CH3H, CH3L, CH2H, CH2L, CH1H, CH1L};
	
	
	initial begin
		channels = 11'b0;
		locked = 1'b0;
		VIH_PWM = 1'b0;
		VIL_PWM = 1'b0;
		send_cmd = 1'b0;
		commRX = 1'b0;
		Initialize;
		
		//Disabling UART and SPI triggering
		$display("Disabling UART and SPI triggering...\n");
		cmd = {TRIG_CFG_WR, 8'h03};
		sendCmd(cmd);
		
		@(posedge top.iDIG.cmd_config.send_resp) begin
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
		
		CHTrigCfg = 5'b0;
		
		while(~CHTrigCfg[10])
			
			cmd = {CH1TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
		 	sendCmd(cmd);
			@(posedge clk);
			@(negedge clk);
			
			cmd = {CH2TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
		 	sendCmd(cmd);
			@(posedge clk);
			@(negedge clk);
			
							
			cmd = {CH3TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
		 	sendCmd(cmd);
			@(posedge clk);
			@(negedge clk);
			
			
			cmd = {CH4TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
		 	sendCmd(cmd);
			@(posedge clk);
			@(negedge clk);
			
			
			cmd = {CH5TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
		 	sendCmd(cmd);
			@(posedge clk);
			@(negedge clk);

				while(~channels[10]) begin
			
					repeat(6) begin
						@(posedge clk);
					end
					
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH1TrigCfg & 5'h01){

						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: Don't care set and Channel 1 not triggered\n");
							$stop;
						end		
					}	
					
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h02) & ~CH1L) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: Low level set, CH1L is 0 and channel 1 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h04) & CH1H) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: High level set, CH1H is 1 and channel 1 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h08) & (~CH1L & prevChannels[0])) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: negedge set and channel 1 not triggered when CH1L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH1TrigCfg & 5'h10) & (CH1H & ~prevChannels[0])) begin
						
						if(~top.iDIG.CH1Trig) begin
							$display("ERROR: posedge set and channel 1 not triggered when CH1H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH2TrigCfg & 5'h01){

						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: Don't care set and Channel 2 not triggered\n");
							$stop;
						end		
					}	
					
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h02) & ~CH2L) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: Low level set, CH2L is 0 and channel 2 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h04) & CH2H) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: High level set, CH2H is 1 and channel 2 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h08) & (~CH2L & prevChannels[1])) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: negedge set and channel 2 not triggered when CH2L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH2TrigCfg & 5'h10) & (CH2H & ~prevChannels[1])) begin
						
						if(~top.iDIG.CH2Trig) begin
							$display("ERROR: posedge set and channel 2 not triggered when CH2H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH3TrigCfg & 5'h01){

						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: Don't care set and Channel 3 not triggered\n");
							$stop;
						end		
					}	
					
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h02) & ~CH3L) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: Low level set, CH3L is 0 and channel 3 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h04) & CH3H) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: High level set, CH3H is 1 and channel 3 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h08) & (~CH3L & prevChannels[2])) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: negedge set and channel 3 not triggered when CH3L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH3TrigCfg & 5'h10) & (CH3H & ~prevChannels[2])) begin
						
						if(~top.iDIG.CH3Trig) begin
							$display("ERROR: posedge set and channel 3 not triggered when CH3H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH4TrigCfg & 5'h01){

						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: Don't care set and Channel 4 not triggered\n");
							$stop;
						end		
					}	
					
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h02) & ~CH4L) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: Low level set, CH4L is 0 and channel 4 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h04) & CH4H) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: High level set, CH4H is 1 and channel 4 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h08) & (~CH4L & prevChannels[3])) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: negedge set and channel 4 not triggered when CH4L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH4TrigCfg & 5'h10) & (CH4H & ~prevChannels[3])) begin
						
						if(~top.iDIG.CH4Trig) begin
							$display("ERROR: posedge set and channel 4 not triggered when CH4H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
						
					//Channel triggering testing block
					if(top.iDIG.cmd_config.CH5TrigCfg & 5'h01){

						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: Don't care set and Channel 5 not triggered\n");
							$stop;
						end		
					}	
					
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h02) & ~CH5L) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: Low level set, CH5L is 0 and channel 5 not triggered\n");
							$stop;
						end	
					end
					
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h04) & CH5H) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: High level set, CH5H is 1 and channel 5 not triggered\n");
							$stop;
						end	
					end
									
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h08) & (~CH5L & prevChannels[4])) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: negedge set and channel 5 not triggered when CH5L has negedge\n");
							$stop;
						end	
					end
										
					if((top.iDIG.cmd_config.CH5TrigCfg & 5'h10) & (CH5H & ~prevChannels[4])) begin
						
						if(~top.iDIG.CH5Trig) begin
							$display("ERROR: posedge set and channel 5 not triggered when CH5H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	

					prevChannels = channels;
					channels = channels + 1;
				end
				channels = 11'b0;
				prevChannels = 10'b0;
				CHTrigCfg = CHTrigCfg + 1;	
			end

		end
	end
	
	always #1.25 REF_CLK = ~REF_CLK;
	
	`include "tb_tasks.sv"
endmodule
