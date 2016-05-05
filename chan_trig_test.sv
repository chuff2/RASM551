task chan_trig_test;
		
		//Disabling UART and SPI triggering
		$display("Disabling UART and SPI triggering...\n");
		
		
		repeat(10000) @(posedge clk);
		/*send_cmd = 1;
		@(posedge REF_CLK);
		@(negedge REF_CLK) send_cmd = 0;
		@(posedge cmd_cmplt);
				
		@(posedge iDUT.iDIG.cmd_config.send_resp) begin
			$display("entering ACK checking block...\n");
			if(iDUT.iDIG.cmd_config.resp != 8'ha5) begin
				$display("ERROR: Recieved incorrect response from cmd_cfg");
				$stop;
			end
		end */
		
		//$display("Wrote to registers and correct response received\n");
		
		sendAndCheckAck({TRIG_CFG_WR, 8'h03});
		
		
		@(posedge REF_CLK) begin
			if(~iDUT.iDIG.protTrig) begin
			  $display("ERROR: After disabling UART and SPI triggering protTrig still not enabled\n");
			  $stop;
			end
		end
		
		force iDUT.iDIG.armed = 1'b1;
		
		CHTrigCfg = 6'b0;
		
		channels = 11'b0;
		prevChannels = 10'b0;
		
		CH1L = channels[0];
		CH1H = channels[1];
		CH2L = channels[2];
		CH2H = channels[3];
		CH3L = channels[4];
		CH3H = channels[5];
		CH4L = channels[6];
		CH4H = channels[7];
		CH5L = channels[8];
		CH5H = channels[9];
		
		while(~CHTrigCfg[5]) begin
			
			host_cmd = {CH1TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			sendCmd(host_cmd);

			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			host_cmd = {CH2TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			sendCmd(host_cmd);
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
							
			host_cmd = {CH3TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			sendCmd(host_cmd);
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			
			host_cmd = {CH4TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			sendCmd(host_cmd);
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);
			
			
			host_cmd = {CH5TrigCfgWr, 3'b0, CHTrigCfg[4:0]};
			
			sendCmd(host_cmd);
			
			@(posedge REF_CLK);
			@(negedge REF_CLK);

				$display("Entering Channel Loop...\n");
				while(~channels[10]) begin
						
					repeat(6) begin
						@(posedge REF_CLK);
					end
					
					//Channel triggering testing block
					if(iDUT.iDIG.cmd_config.CH1TrigCfg & 5'h01) begin

						if(~iDUT.iDIG.CH1Trig) begin
							$display("ERROR: Don't care set and Channel 1 not triggered\n");
							$stop;
						end		
					end	
					
					if((iDUT.iDIG.cmd_config.CH1TrigCfg & 5'h02) & channels[0]) begin
						
						if(~iDUT.iDIG.CH1Trig) begin
							$display("ERROR: Low level set, CH1L is 1 and channel 1 not triggered\n");
							$stop;
						end	
					end
					
					if((iDUT.iDIG.cmd_config.CH1TrigCfg & 5'h04) & channels[1]) begin
						
						if(~iDUT.iDIG.CH1Trig) begin
							$display("ERROR: High level set, CH1H is 1 and channel 1 not triggered\n");
							$stop;
						end	
					end
									
					if((iDUT.iDIG.cmd_config.CH1TrigCfg & 5'h08) & (channels[0] & ~prevChannels[0])) begin
						
						if(~iDUT.iDIG.CH1Trig) begin
							$display("ERROR: negedge set and channel 1 not triggered when CH1L has posedge\n");
							$stop;
						end	
					end
										
					if((iDUT.iDIG.cmd_config.CH1TrigCfg & 5'h10) & (channels[1] & ~prevChannels[0])) begin
						
						if(~iDUT.iDIG.CH1Trig) begin
							$display("ERROR: posedge set and channel 1 not triggered when CH1H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
					//Channel triggering testing block
					if(iDUT.iDIG.cmd_config.CH2TrigCfg & 5'h01) begin

						if(~iDUT.iDIG.CH2Trig) begin
							$display("ERROR: Don't care set and Channel 2 not triggered\n");
							$stop;
						end		
					end
					
					if((iDUT.iDIG.cmd_config.CH2TrigCfg & 5'h02) & channels[2]) begin
						
						if(~iDUT.iDIG.CH2Trig) begin
							$display("ERROR: Low level set, CH2L is 1 and channel 2 not triggered\n");
							$stop;
						end	
					end
					
					if((iDUT.iDIG.cmd_config.CH2TrigCfg & 5'h04) & channels[3]) begin
						
						if(~iDUT.iDIG.CH2Trig) begin
							$display("ERROR: High level set, CH2H is 1 and channel 2 not triggered\n");
							$stop;
						end	
					end
									
					if((iDUT.iDIG.cmd_config.CH2TrigCfg & 5'h08) & (channels[2] & ~prevChannels[1])) begin
						
						if(~iDUT.iDIG.CH2Trig) begin
							$display("ERROR: negedge set and channel 2 not triggered when CH2L has posedge\n");
							$stop;
						end	
					end
										
					if((iDUT.iDIG.cmd_config.CH2TrigCfg & 5'h10) & (channels[3] & ~prevChannels[1])) begin
						
						if(~iDUT.iDIG.CH2Trig) begin
							$display("ERROR: posedge set and channel 2 not triggered when CH2H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(iDUT.iDIG.cmd_config.CH3TrigCfg & 5'h01) begin

						if(~iDUT.iDIG.CH3Trig) begin
							$display("ERROR: Don't care set and Channel 3 not triggered\n");
							$stop;
						end		
					end
					
					if((iDUT.iDIG.cmd_config.CH3TrigCfg & 5'h02) & channels[4]) begin
						
						if(~iDUT.iDIG.CH3Trig) begin
							$display("ERROR: Low level set, CH3L is 1 and channel 3 not triggered\n");
							$stop;
						end	
					end
					
					if((iDUT.iDIG.cmd_config.CH3TrigCfg & 5'h04) & channels[5]) begin
						
						if(~iDUT.iDIG.CH3Trig) begin
							$display("ERROR: High level set, CH3H is 1 and channel 3 not triggered\n");
							$stop;
						end	
					end
									
					if((iDUT.iDIG.cmd_config.CH3TrigCfg & 5'h08) & (channels[4] & ~prevChannels[2])) begin
						
						if(~iDUT.iDIG.CH3Trig) begin
							$display("ERROR: negedge set and channel 3 not triggered when CH3L has posedge\n");
							$stop;
						end	
					end
										
					if((iDUT.iDIG.cmd_config.CH3TrigCfg & 5'h10) & (channels[5] & ~prevChannels[2])) begin
						
						if(~iDUT.iDIG.CH3Trig) begin
							$display("ERROR: posedge set and channel 3 not triggered when CH3H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
										
					//Channel triggering testing block
					if(iDUT.iDIG.cmd_config.CH4TrigCfg & 5'h01) begin

						if(~iDUT.iDIG.CH4Trig) begin
							$display("ERROR: Don't care set and Channel 4 not triggered\n");
							$stop;
						end		
					end
					
					if((iDUT.iDIG.cmd_config.CH4TrigCfg & 5'h02) & channels[6]) begin
						
						if(~iDUT.iDIG.CH4Trig) begin
							$display("ERROR: Low level set, CH4L is 1 and channel 4 not triggered\n");
							$stop;
						end	
					end
					
					if((iDUT.iDIG.cmd_config.CH4TrigCfg & 5'h04) & channels[7]) begin
						
						if(~iDUT.iDIG.CH4Trig) begin
							$display("ERROR: High level set, CH4H is 1 and channel 4 not triggered\n");
							$stop;
						end	
					end
									
					if((iDUT.iDIG.cmd_config.CH4TrigCfg & 5'h08) & (channels[6] & ~prevChannels[3])) begin
						
						if(~iDUT.iDIG.CH4Trig) begin
							$display("ERROR: negedge set and channel 4 not triggered when CH4L has posedge\n");
							$stop;
						end	
					end
										
					if((iDUT.iDIG.cmd_config.CH4TrigCfg & 5'h10) & (channels[7] & ~prevChannels[3])) begin
						
						if(~iDUT.iDIG.CH4Trig) begin
							$display("ERROR: posedge set and channel 4 not triggered when CH4H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	
					
						
					//Channel triggering testing block
					if(iDUT.iDIG.cmd_config.CH5TrigCfg & 5'h01) begin

						if(~iDUT.iDIG.CH5Trig) begin
							$display("ERROR: Don't care set and Channel 5 not triggered\n");
							$stop;
						end		
					end
					
					if((iDUT.iDIG.cmd_config.CH5TrigCfg & 5'h02) & channels[8]) begin
						
						if(~iDUT.iDIG.CH5Trig) begin
							$display("ERROR: Low level set, CH5L is 1 and channel 5 not triggered\n");
							$stop;
						end	
					end
					
					if((iDUT.iDIG.cmd_config.CH5TrigCfg & 5'h04) & channels[9]) begin
						
						if(~iDUT.iDIG.CH5Trig) begin
							$display("ERROR: High level set, CH5H is 1 and channel 5 not triggered\n");
							$stop;
						end	
					end
									
					if((iDUT.iDIG.cmd_config.CH5TrigCfg & 5'h08) & (channels[8] & ~prevChannels[4])) begin
						
						if(~iDUT.iDIG.CH5Trig) begin
							$display("ERROR: negedge set and channel 5 not triggered when CH5L has posedge\n");
							$stop;
						end	
					end
										
					if((iDUT.iDIG.cmd_config.CH5TrigCfg & 5'h10) & (channels[9] & ~prevChannels[4])) begin
						
						if(~iDUT.iDIG.CH5Trig) begin
							$display("ERROR: posedge set and channel 5 not triggered when CH5H has posedge\n");
							$stop;
						end	
					end
					//End of channel block	

					prevChannels = channels[9:0];
					channels = channels + 1;
					
					CH1L = channels[0];
					CH1H = channels[1];
					CH2L = channels[2];
					CH2H = channels[3];
					CH3L = channels[4];
					CH3H = channels[5];
					CH4L = channels[6];
					CH4H = channels[7];
					CH5L = channels[8];
					CH5H = channels[9];
					
				end
				channels = 11'b0;
				prevChannels = 10'b0;
				
				CH1L = channels[0];
				CH1H = channels[1];
				CH2L = channels[2];
				CH2H = channels[3];
				CH3L = channels[4];
				CH3H = channels[5];
				CH4L = channels[6];
				CH4H = channels[7];
				CH5L = channels[8];
				CH5H = channels[9];
				
				
				CHTrigCfg = CHTrigCfg + 1;	
			end
	$display("chan_trig_test SUCCESS!!!!!!!!!!!!!!!!!!!!!!!!\n");
	$stop;

endtask

