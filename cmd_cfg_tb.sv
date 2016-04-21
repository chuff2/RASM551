module cmd_cfg_tb();
	
	//General signals and signals for UART_wrapper
  	logic clk, rst_n, clr_cmd_rdy, send_resp, RX_TX, cmd_rdy,  resp_sent, TX_RX;
	logic [7:0] resp_to_send;
	logic [15:0] cmd_rcvd;	
	
	//CommMaster signals
	logic resp_cmplt, cmd_cmplt, snd_cmd;
	logic [7:0] resp_rcvd;
	logic [15:0] cmd_to_send;
	
	//cmd_cfg signals
	logic cfg_set_capture_done;
	logic [3:0] decimator;
	logic [4:0] CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg;
	logic [5:0] TrigCfg;
	logic [7:0] rdataCH1, rdataCH2, rdataCH3, rdataCH4, rdataCH5, maskL, maskH;
	logic [7:0] matchL, matchH, baud_cntL, baud_cntH, VIH, VIL;
	logic [8:0] waddr, trig_pos, addr_ptr;	
	logic cmd_cfg_clr_cmd_rdy;
	
	//capture unit model signals
	logic we1, we2, we3, we4, we5;
	logic [2:0] writeSelect, weSelect, weCounter;
	logic [7:0] wdata;
	logic capturing;

	//TB signals
	logic [1:0] command;
	logic [5:0] address;
	logic [7:0] data;
	logic [7:0] response_counter;	
	
	/*
	Process: 
	1. CommMaster sends a 2 Byte command. snd_cmd goes high
	2. When cmd_cmplt goes high the transmission is done and UART should have received command.
	    So cmd_rdy signal from UART should have already gone high. This trips the cmd_cfg SM.
	3. cmd_cfg decodes the command and figures out what response to send
	4. cmd_cfg tells UART_wrapper the response (resp_to_send) and when to send it (send_resp pulse)
	5. commMaster receives the signal and resp_rcvd should pulse
	
	
	*/
	UART_wrapper UART_wrapper(.clk(clk), .rst_n(rst_n), .clr_cmd_rdy(clr_cmd_rdy), .send_resp(send_resp), 
		.resp(resp_to_send), .RX(TX_RX), .cmd_rdy(cmd_rdy), .cmd(cmd_rcvd), .resp_sent(resp_sent), .TX(RX_TX));
	
	CommMaster commMaster(.clk(clk), .rst_n(rst_n), .snd_cmd(snd_cmd), .cmd(cmd_to_send), .TX(TX_RX), 
		.RX(RX_TX), .cmd_cmplt(cmd_cmplt),.resp(resp_rcvd), .resp_cmplt(resp_cmplt));
	
	
	cmd_cfg cmd_cfg_INST(.clk(clk), .rst_n(rst_n), .cmd(cmd_rcvd), .cmd_rdy(cmd_rdy), .resp_sent(resp_sent), 
		.set_capture_done(cfg_set_capture_done), .waddr(waddr),.rdataCH1(rdataCH1), .rdataCH2(rdataCH2), 
		.rdataCH3(rdataCH3), .rdataCH4(rdataCH4), .rdataCH5(rdataCH5), .resp(resp_to_send), 
		.send_resp(send_resp), .clr_cmd_rdy(clr_cmd_rdy), .trig_pos(trig_pos), .addr_ptr(addr_ptr), 
		.decimator(decimator), .maskL(maskL), .maskH(maskH), .matchL(matchL), .matchH(matchH), 
		.baud_cntL(baud_cntL), .baud_cntH(baud_cntH), .TrigCfg(TrigCfg), .CH1TrigCfg(CH1TrigCfg), 
		.CH2TrigCfg(CH2TrigCfg), .CH3TrigCfg(CH3TrigCfg), .CH4TrigCfg(CH4TrigCfg), .CH5TrigCfg(CH5TrigCfg), 
		.VIH(VIH), .VIL(VIL));
	
		
	RAMqueue RAM1 (.clk(clk), .we(we1), .waddr(waddr), .raddr(addr_ptr), .wdata(wdata), .rdata(rdataCH1));
	RAMqueue RAM2 (.clk(clk), .we(we2), .waddr(waddr), .raddr(addr_ptr), .wdata(wdata), .rdata(rdataCH2));
	RAMqueue RAM3 (.clk(clk), .we(we3), .waddr(waddr), .raddr(addr_ptr), .wdata(wdata), .rdata(rdataCH3));
	RAMqueue RAM4 (.clk(clk), .we(we4), .waddr(waddr), .raddr(addr_ptr), .wdata(wdata), .rdata(rdataCH4));
	RAMqueue RAM5 (.clk(clk), .we(we5), .waddr(waddr), .raddr(addr_ptr), .wdata(wdata), .rdata(rdataCH5));

	assign cfg_set_capture_done = ~capturing;
    
	/*
	assign waddr = (writeSelect == 1) ? waddr1 :
		       (writeSelect == 2) ? waddr2 :
		       (writeSelect == 3) ? waddr3 :
		       (writeSelect == 4) ? waddr4 :
		       (writeSelect == 5) ? waddr5 : 
		       10'b0;
	*/

	assign we1 = (weSelect == 3'd1);
	assign we2 = (weSelect == 3'd2);	
	assign we3 = (weSelect == 3'd3);
	assign we4 = (weSelect == 3'd4);
	assign we5 = (weSelect == 3'd5);
	
	
	initial begin
		
		clk = 1'b0;
		rst_n = 1'b0;
		capturing = 1'b0;
		snd_cmd = 1'b0;
		writeSelect = 3'd0;
		wdata = 8'h00;
		weCounter = 3'b0;
		weSelect = 3'b0;
		waddr = 9'h0;
	
		@(negedge clk) rst_n = 1'b1;
		capturing = 1'b1;
		@(negedge clk);	

		//write data to RAMQueue
		repeat(384) begin
		    repeat(5) begin				
				if(weCounter == 5) 
					weCounter = 3'b1;
				else 
					weCounter = weCounter + 1;
				
				weSelect = weCounter;
				@(negedge clk);
			end
			if(waddr == 383)
				waddr = 0;
			else
				waddr = waddr + 1;
			writeSelect = writeSelect + 1;
			wdata = wdata + 1;	
		end
		
		weSelect = 3'b0;	
		@(negedge clk) capturing = 1'b0;
		@(negedge clk);

		command = 2'b01;
		address = 6'b0;
		data = 8'b1;
		
		//writing to all registers
		repeat(17) begin
			cmd_to_send = {command, address, data};
			snd_cmd = 1'b1;

			@(negedge clk);
			@(negedge clk) snd_cmd = 1'b0;

			@(posedge resp_cmplt) begin

				if(resp_rcvd != 8'hA5) begin

					$display("Error in writing to register: positive ACK not received.\n");
					$stop;
				end
				
				else begin
					data = data + 1;
					address = address + 1;
				end
			end
			@(negedge clk);
		end
		
		//Reading from all registers
		command = 2'b00;
		address = 6'b0;
			
		repeat(17) begin
			cmd_to_send = {command, address, data};
			snd_cmd = 1'b1;

			@(negedge clk);
			@(negedge clk) snd_cmd = 1'b0;

			@(posedge resp_cmplt) begin
				// Cover the case where set_capture_done = 1; Then, we don't store exactly what we wrote
				if(address == 6'b0 && cfg_set_capture_done) begin
					if(resp_rcvd != 6'h11) begin
					$display("Error in reading from register: incorrect data");
					$stop;	
					end
				end
				else if((resp_rcvd != (address + 1))) begin
					$display("Error in reading from register: incorrect data");
					$stop;	
				end
				address = address + 1;
			end	
		end	
		
		//Channel dump
		command = 2'b10;
		address = 6'b1;
		response_counter = waddr;

		repeat(5) begin
			cmd_to_send = {command, address, data};
			snd_cmd = 1'b1;
			
			@(negedge clk);
			@(negedge clk) snd_cmd = 1'b0;
			
			repeat(384) begin
				@(posedge resp_cmplt) begin
					if(resp_rcvd != response_counter[7:0]) begin
						$display("Channel dump error: Incorrect data\n");
						$stop;
					end
					
					else response_counter = response_counter + 1;
				end
				
				@(negedge clk);
			end
			response_counter = 0;
			address = address + 1;
		end
		
		//Reserved case
		command = 2'b11;
  		cmd_to_send = {command, address, data};
		
		snd_cmd = 1'b1;

		@(negedge clk);
		@(negedge clk) snd_cmd = 1'b0;
		
		@(posedge resp_cmplt) begin
			if(resp_rcvd != 8'hee) begin
				$display("Negative ACK not received for reserved function\n");
				$stop;
			end

			else begin
				$display("Success!!\n");
				$stop;
			end
		end
	end
	
	always #2 clk = ~clk;
endmodule
