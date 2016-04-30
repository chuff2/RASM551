task test2;

logic [15:0] cmd;
logic [7:0] received_resp;

Initialize();

repeat(5)  @(posedge clk);
cmd = {2'b01, 6'h01, 8'h10};
sendCmd(cmd);
checkResp(received_resp);
if(received_resp !== 8'hA5) begin
	$display("error: positive ACK (A5) not received");
	$stop;
end

setRunMode();

waitCapDone;
$display("capture done set at time %t", $time);
$stop;

repeat(10) @(posedge clk);
cmd = {2'b10, 6'h01, 8'h00};
sendCmd(cmd);

RecvDump(3'b001);

endtask
