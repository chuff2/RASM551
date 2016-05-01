task test2;

logic [15:0] cmd;
logic [7:0] received_resp;
logic [2:0] ch;

Initialize();

repeat(5)  @(posedge clk);
// Set Ch1TrigCfg to have a low level trigger. Other channels not part of trigger at the moment
cmd = {2'b01, 6'h01, 8'h10};
sendCmd(cmd);
checkResp(received_resp);
if(received_resp !== 8'hA5) begin
	$display("error: positive ACK (A5) not received");
	$stop;
end

// Sets run mode bit high (bit 4 in TrigCfg). Default TrigCfg has SPI and UART triggering disabled
setRunMode();

waitCapDone;
$display("capture done set at time %t", $time);
$stop;

for(ch=3'h1; ch<3'h2; ch=ch+1'b1)
	channel_dump(ch);

endtask

// Helper task that does the process of the channel dump for a given channel
task channel_dump(input logic [2:0] ch);
	logic [15:0] cmd;
	string filename;
	repeat(10) @(posedge clk);
	cmd = {2'b10, 3'h0, ch, 8'h00};
	sendCmd(cmd);
	/*case(ch)
		3'h1: filename = "CH1dmp.txt";
		3'h2: filename = "CH2dmp.txt";
		3'h3: filename = "CH3dmp.txt";
		3'h4: filename = "CH4dmp.txt";
		3'h5: filename = "CH5dmp.txt";
		default: filename = "invalid_ch.txt";
	endcase */
	RecvDump(ch);
endtask


