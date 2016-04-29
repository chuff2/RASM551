module SPI_tb();

//common signals
logic clk, width8_len8_16, rst_n, SS_n, MOSI, SCLK;

//rx only signals
logic [15:0] mask, match;
logic SPItrig;

//mstr only signals
logic [15:0] data_out;
logic done, wrt, mstr_edg;

//misc 
logic [15:0] masked_match;

SPI_RX rx(.SPItrig(SPItrig), .clk(clk), .rst_n(rst_n), .SS_n(SS_n), 
	.SCLK(SCLK), .MOSI(MOSI), .edg(rx_edg), .len8_16(width8_len8_16),
	 .mask(mask), .match(match));

SPI_mstr mstr(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .SCLK(SCLK), .wrt(wrt), 
	.done(done) , .data_out(data_out), .MOSI(MOSI), .pos_edge(mstr_edg),
	 .width8(width8_len8_16));



assign rx_edg = ~mstr_edg;
assign masked_match = (~mask | 16'hXXXX) & match;

initial begin
	clk = 0;
	rst_n = 0;
	mask = 16'h0000;
	match = 16'h8123; //after masking should match data_out
	data_out = 16'h8123; //value that should be the end result
	mstr_edg = 1'b1;
	width8_len8_16 = 0; //first test for 16 bits
	repeat (2) @(posedge clk);
	rst_n = 1;
	repeat (2) @(negedge clk);
	wrt = 1;//start the transaction
	@(negedge clk);
	wrt = 0;
	
	// first transaction doesnt work... but that is fine hoffman says
	@(posedge SPItrig);
	$display("First transaction complete:mstr_edg = 1");
	if (!(rx.shft_reg inside {masked_match})) begin
		$display("Failure....");
	end
	else begin
		$display("Success!!!");
	end
	
	#10000;
	
	//test the other edge trigger
	mstr_edg = 1'b0;
	//test out mask functionality
	mask = 16'h8000;
	data_out = 16'h0123;
	repeat (2) @(negedge clk);
	wrt = 1;//start the transaction
	@(negedge clk);
	wrt = 0;
	
	@(posedge SPItrig);
	$display("Second transaction complete:mstr_edg = 0");
	if (!(rx.shft_reg inside {masked_match})) begin
		$display("Failure....");
	end
	else begin
		$display("Success!!!");
	end

	#1000;
	//do the 8 it version as well
	width8_len8_16 = 1;
	repeat (2) @(negedge clk);
	wrt = 1;//start the transaction
	@(negedge clk);
	wrt = 0;
	
	@(posedge SPItrig);
	$display("Third transaction complete:mstr_edg = 0, 8 bit version");
	if (!(rx.shft_reg[15:8] inside {masked_match[7:0]})) begin
		$display("Failure....");
	end
	else begin
		$display("Success!!!");
$stop;
	end

	#1000;
	//do the 8 it version as well
	width8_len8_16 = 1;
	//this time we want the values to not match
	data_out = 16'h1111; 
	repeat (2) @(negedge clk);
	wrt = 1;//start the transaction
	@(negedge clk);
	wrt = 0;
	
	@(posedge rx.SS_n2);
	$display("Fourth transaction complete:mstr_edg = 0, 8 bit version, should not match");
	if ((rx.shft_reg[15:8] inside {masked_match[7:0]})) begin
		$display("Failure....");
		$stop;
	end
	else begin
		$display("Success!!!");
		$stop;
	end

end

always #5 clk = ~clk;

endmodule
