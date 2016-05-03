class stim_t;
	rand bit [7:0] wdata8;
	rand bit [5:0] wdata6;
	rand bit [4:0] wdata5;
	rand bit [3:0] wdata4;
	constraint RF_lim{
		wdata8 dist { [8'h00:8'hFF]:=99};
		wdata6 dist { [6'h00:6'hF3]:=99};
		wdata5 dist { [5'h00:5'h1F]:=99};
		wdata4 dist { [4'h0:4'hF]:=99};
	}

endclass

// Basically just asserts and deasserts RST_n
task Initialize();
	RST_n = 0;
	@(posedge REF_CLK);
	@(negedge REF_CLK) RST_n = 1;
endtask

// sends UART command using commMaster to LA_dig
task sendCmd(input logic[15:0] cmd);
	host_cmd = cmd;
	send_cmd = 1;
	@(posedge clk);
	@(negedge clk) send_cmd = 0;
endtask

// Checks the response received from cmd_cfg
task checkResp(output logic [7:0] resp_recv);
	@(posedge resp_rdy) resp_recv = resp;
endtask

// Check the cap_done bit in TrigCfg
task waitCapDone;
	@(posedge iDUT.iDIG.TrigCfg[5]);
endtask

// Setting the LA into run mode allows it to begin storing samples
task setRunMode();
	logic [15:0] cmd;
	logic [7:0] run_mode_resp;
	cmd = {2'b01, 6'h00, 8'h13};
	sendCmd(cmd);
	checkResp(run_mode_resp);
	if(run_mode_resp !== 8'hA5) begin
		$display("error: positive ACK (A5) not received");
		$stop;
	end
endtask

// Takes a channel as input (indexed from 1) dumps the channel's RAM_contents
// Writes contents of RAM to a file
task RecvDump(input logic[2:0] ch);
	reg [LOG2-1:0] i;
	reg [15:0] cmd;
	logic [7:0] RAM_contents[ENTRIES-1:0];
	logic capture_done;
	integer fid;
	string filename;
	case(ch)
		3'h1: filename = "CH1dmp.txt";
		3'h2: filename = "CH2dmp.txt";
		3'h3: filename = "CH3dmp.txt";
		3'h4: filename = "CH4dmp.txt";
		3'h5: filename = "CH5dmp.txt";
		default: filename = "invalid_ch.txt";
	endcase
	fid = $fopen(filename,"w");
	$display("filename = %s. fid=%d", filename, fid);
	
	// Send channel dump comand on channel ch
	cmd = {2'b10, 3'b000, ch, 8'h00};
	sendCmd(cmd); 
	for(i=0; i<ENTRIES; i=i+1'b1) begin
		checkResp(RAM_contents[i]);
		$fwrite(fid,"%h\n", RAM_contents[i]);
	end
	$fclose(fid);
	
endtask

// Accepts a register address as input. Writes random data to address,
// reads data back and checks that read matches write

// Random mumber generator
/* Figure this out later
class stim_t
	rand bit [7:0] data;
endclass
*/
	
task WriteReadCheck(input logic [5:0] addr, output logic error, output logic [7:0] rdata);
	logic [7:0] wdata, resp;
	logic [15:0] cmd;
	//stim_t stim;
	
	// Figure out randomizer later
	//stim = new();
	//stim.randomize();
	wdata = 8'h17;
	if (addr == 0) 
		wdata = {2'b00,wdata[5:0]};
	else if (addr > 0  && addr < 6)
		wdata = {3'b000, wdata[4:0]};
	else if (addr == 6)
		wdata = {4'b0000, wdata[3:0]};
	else 
		wdata = wdata; 
	/*
	if (addr == 0) 
		wdata = {2'b00,stim.wdata6};
	else if (addr > 0  && addr < 6)
		wdata = {3'b000, stim.wdata5};
	else if (addr == 6)
		wdata = {4'b0000, stim.wdata4};
	else 
		wdata = stim.wdata8; 
	*/
	
	// Send Write command
	cmd = {2'b01, addr, wdata};
	sendCmd(cmd);
	checkResp(resp);
	// Check for positive ACK
	if(resp !== 8'hA5)
		error = 1;
	else
		error = 0;
		
	// Send read command
	cmd = {2'b00, addr, 8'h00};
	sendCmd(cmd);
	checkResp(rdata);
	// Check that data matches
	if(rdata !== wdata && (addr == 2'b00 && (wdata|6'h32) !== rdata))
		error = 1;

endtask



