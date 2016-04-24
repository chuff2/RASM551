// Basically just asserts and deasserts RST_n
task Initialize();
	RST_n = 0;
	@(posedge clk);
	@(negedge clk) RST_n = 1;
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

// Takes a channel as input (indexed from 1) dumps the channel's RAM_contents
// Writes contents of RAM to a file
task RecvDump(input logic[2:0] ch);
	reg [LOG2-1:0] i;
	reg [15:0] cmd;
	logic [7:0] RAM_contents[ENTRIES-1:0];
	static integer fd = $fopen("channel_dump.txt","w");
	
	cmd = {2'b10, 3'b000, ch, 8'h00};
	sendCmd(cmd); 
	for(i=0; i<ENTRIES; i=i+1'b1) begin
		checkResp(RAM_contents[i]);
		$fwrite("@0 %h\n", RAM_contents[i]);
	end
	
endtask

// Accepts a register address as input. Writes random data to address,
// reads data back and checks that read matches write

// Random mumber generator
/* Figure this out later
class stim_t
	rand bit [7:0] data;
endclass
*/
	
task WriteReadCheck(input logic [5:0] addr, output logic error);
	logic [7:0] wdata, rdata, resp;
	logic [15:0] cmd;
	
	// Figure out randomizer later
	//stim_t = stim = new();
	// stim.randomize();
	wdata = 8'h17;
	
	// Send Write command
	cmd = {2'b01, 1'b0, addr, wdata};
	sendCmd(cmd);
	checkResp(resp);
	// Check for positive ACK
	if(resp !== 8'hA5)
		error = 1;
	else
		error = 0;
		
	// Send read command
	cmd = {2'b00, 1'b0, addr, 8'h00};
	sendCmd(cmd);
	checkResp(rdata);
	// Check that data matches
	if(rdata !== wdata)
		error = 1;

endtask


