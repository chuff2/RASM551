task test1;

integer i;
logic [5:0] addr;
logic error;
logic anyErrors;

Initialize();
anyErrors = 0;
//loop through each of the registers in the register file
for (addr = 6'h00; addr < 16; addr= addr+1'b1) begin
	WriteReadCheck(addr, error);
	if (error == 1) begin
		$display("Failed test 1 with address = %h", addr);
		anyErrors = 1;
	end
end

if (anyErrors == 1) begin
	$display("Test 1 did not pass in its entirity");
end

endtask
