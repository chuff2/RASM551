module prot_trig_tb();

//inputs
logic clk, rst_n, SS_n_RX, SCLK, MOSI;
logic [7:0] maskH, maskL, matchH, matchL, baud_cntH, baud_cntL;
logic [5:0] TrigCfg;
//output
logic protTrig;
//misc
logic [15:0] MOSIreg;
logic [8:0] SS_n_RXreg;
logic baud_cnt, uartTransInProg;
logic SS_n_SPI, SPIgoing;
logic debug;

assign baud_cnt = {baud_cntH,baud_cntL};

prot_trig pt(.protTrig(protTrig), .clk(clk), .rst_n(rst_n),  .TrigCfg(TrigCfg), .maskH(maskH), .maskL(maskL),
 .matchH(matchH), .matchL(matchL), .CH1L(SS_n_RX), .CH2L(SCLK), .CH3L(MOSI), .baud_cntH(baud_cntH), .baud_cntL(baud_cntL));

//build a psuedo driver for the SPI and the UART
initial begin
debug = 0;

clk = 0;
rst_n = 0;
SCLK = 0;
//SS_n_RX = 1;
MOSIreg = 16'h5555;
uartTransInProg = 0;
SPIgoing = 1;

maskH = 8'h00;
maskL = 8'h00;
matchH = 8'h55;
matchL = 8'h55;
//arbitrary baud count
baud_cntH = 8'h03;//16?h0364 from slides
baud_cntL = 8'h64;


//first test the SPI 16 bit posedge sampled
TrigCfg = 6'b001001; //SCLK rise 16 bit word
repeat (3) @(negedge clk);
rst_n = 1;
repeat (3) @(negedge clk);
SS_n_SPI = 0;
repeat (16) begin
	@(negedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_SPI = 1;
@(posedge protTrig) begin
	if (pt.spiRX.shft_reg == 16'h5555) begin
		$display("Success first test!!!");
		//$stop;
	end
end

//second test SPI 16 bit negedge sampled with mask
#1000
MOSIreg = 16'h0444;
matchH = 8'h44;
matchL = 8'h44;
maskH = 8'h40;
maskL = 8'h00;
TrigCfg = 6'b000001; //SCLK rise 16 bit word
repeat (3) @(negedge clk);
SS_n_SPI = 0;
repeat (16) begin
	@(posedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_SPI = 1;
@(posedge protTrig) begin
	if (pt.spiRX.shft_reg == 16'h0444) begin
		$display("Success second test!!!");
		//$stop;
	end
end

//third test SPI 8 bit sample
#1000
MOSIreg = 16'h3328;
matchH = 8'h00;
matchL = 8'h33;
maskH = 8'h00;
maskL = 8'h00;
TrigCfg = 6'b000101; //SCLK rise 16 bit word
repeat (3) @(negedge clk);
SS_n_SPI = 0;
repeat (8) begin
	@(posedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_SPI = 1;
@(posedge protTrig) begin
	if (pt.spiRX.shft_reg[7:0] == 8'h33) begin
		$display("Success third test!!!");
		//$stop;
	end
end


//UART test
SPIgoing = 0;
#1000
//MOSIreg = 16'h2333;
matchH = 8'h00;
matchL = 8'h23;
maskH = 8'h00;
maskL = 8'h00;
TrigCfg = 6'b000010; //SCLK rise 16 bit word
uartTransInProg = 0;
repeat (15) @(negedge clk);
SS_n_RXreg = 9'h023;
uartTransInProg = 1;
baud_cntH = 8'h03;//16?h0364 from slides
baud_cntL = 8'h64;
repeat (9) begin
	@(posedge pt.uart_trig_rx.shift)
		SS_n_RXreg = SS_n_RXreg >> 1;
end
uartTransInProg = 0;
@(posedge protTrig) begin
	if (pt.uart_trig_rx.cmd[7:0] == 8'h23) begin
		$display("Success fourth test!!!");
		//$stop;
	end
	else begin
		$display("Failure on 4th test");
		//$stop;
	end
end

//UART test 2, with mask
SPIgoing = 0;
#1000
//MOSIreg = 16'h2333;
matchH = 8'h00;
matchL = 8'h05;
maskH = 8'h00;
maskL = 8'h40;
TrigCfg = 6'b000010; //SCLK rise 16 bit word
uartTransInProg = 0;
repeat (15) @(negedge clk);
SS_n_RXreg = 9'h08A;//45->89 // start bit is 0
uartTransInProg = 1;
baud_cntH = 8'h03;//16?h0364 from slides
baud_cntL = 8'h64;
repeat (9) begin
	@(posedge pt.uart_trig_rx.shift)
		SS_n_RXreg = SS_n_RXreg >> 1;
end
uartTransInProg = 0;
@(posedge protTrig) begin
	if (pt.uart_trig_rx.cmd[7:0] == 8'h45) begin
		$display("Success fifth test!!!");
		$stop;
	end
	else begin
		$display("Failure on 5th test");
		$stop;
	end
end



end //end initial block



//signal assignments
assign MOSI = MOSIreg[15];
//if the spi is going then let this signal inherit a buffer signal. Otherwise it is being used by UART
assign SS_n_RX = (SPIgoing)? SS_n_SPI:(uartTransInProg) ? SS_n_RXreg[0] : 1;

always #100 SCLK = ~SCLK;

always #5 clk = ~clk;

endmodule
