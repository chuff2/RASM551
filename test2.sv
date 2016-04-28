initial begin

Initialize();

repeat(5)  @(posedge clk);
cmd = {2'b01, 6'h01, 8'h10};
SendCmd(cmd);
checkResp(received_resp);

repeat(10) @(posedge clk);
cmd = {2'b10, 6'h01, 8'h00};

RecvDump(3'b001);

end
