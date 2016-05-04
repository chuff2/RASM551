// This performs triggering with SPI and UART triggering disabled and dumps the RAM

task test2;

logic [15:0] cmd;
logic [7:0] received_resp;
logic [2:0] ch;

Initialize();

repeat(5)  @(posedge clk);
// Set Ch1TrigCfg to have a positive edge trigger. Other channels not part of trigger at the moment
sendAndCheckAck({WRITE, 6'h01, 8'h10});


// Sets run mode bit high (bit 4 in TrigCfg). Default TrigCfg has SPI and UART triggering disabled
setRunMode();

waitCapDone;

for(ch=3'h1; ch<3'h6; ch=ch+1'b1)
	channel_dump(ch);

endtask

// Helper task that does the process of the channel dump for a given channel
task channel_dump(input logic [2:0] ch);
	logic [15:0] cmd;
	string filename;
	repeat(10) @(posedge clk);
	cmd = {2'b10, 3'h0, ch, 8'h00};
	sendCmd(cmd);
	RecvDump(ch);
endtask


