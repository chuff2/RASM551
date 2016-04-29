module prot_trig_tb();

//inputs
logic clk, rst_n, SS_n_RX, SCLK, MOSI;
logic [7:0] maskH, maskL, matchH, matchL, baud_cntH, baud_cntL;
logic [5:0] TrigCfg;
//output
logic protTrig;
//misc
logic [15:0] MOSIreg;

prot_trig pt(.protTrig(protTrig), .clk(clk), .rst_n(rst_n),  .TrigCfg(TrigCfg), .maskH(maskH), .maskL(maskL),
 .matchH(matchH), .matchL(matchL), .CH1L(SS_n_RX), .CH2L(SCLK), .CH3L(MOSI), .baud_cntH(baud_cntH), .baud_cntL(baud_cntL));

//build a psuedo driver for the SPI and the UART
initial begin
clk = 0;
rst_n = 0;
SCLK = 0;
SS_n_RX = 1;
MOSIreg = 16'h5555;

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
SS_n_RX = 0;
repeat (16) begin
	@(negedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_RX = 1;
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
SS_n_RX = 0;
repeat (16) begin
	@(posedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_RX = 1;
@(posedge protTrig) begin
	if (pt.spiRX.shft_reg == 16'h0444) begin
		$display("Success second test!!!");
		//$stop;
	end
end
//second test SPI 8 bit sample
#1000
MOSIreg = 16'h3323;
matchH = 8'h00;
matchL = 8'h23;
maskH = 8'h00;
maskL = 8'h00;
TrigCfg = 6'b000101; //SCLK rise 16 bit word
repeat (3) @(negedge clk);
SS_n_RX = 0;
repeat (16) begin
	@(posedge SCLK)
		MOSIreg = MOSIreg << 1;
end
SS_n_RX = 1;
@(posedge protTrig) begin
	if (pt.spiRX.shft_reg[7:0] == 8'h23) begin
		$display("Success third test!!!");
		$stop;
	end
end


end //end initial block



//signal assignments
assign MOSI = MOSIreg[15];

always #100 SCLK = ~SCLK;

always #5 clk = ~clk;

endmodule
