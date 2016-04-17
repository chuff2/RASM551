module prot_trig(protTrig, clk, rst_n,  TrigCfg, maskH, maskL, matchH, matchL, CH1L, CH2L, CH3L, baud_cntH, baud_cntL);

input logic clk, rst_n, CH1L, CH2L, CH3L;
input logic [7:0] maskH, maskL, matchH, matchL, baud_cntH, baud_cntL;
input logic [5:0] TrigCfg;
output logic protTrig;

//SPI originating signals
logic SPItrig;
//UART originating signals
logic UARTtrig;


//SPI as documented in the spec
SPI_RX spiRX(.SPItrig(SPItrig), .clk(clk), .rst_n(rst_n), .SS_n(CH1L),
	 .SCLK(CH2L), .MOSI(CH3L), .edg(TrigCfg[3]), .len8_16(TrigCfg[2]),
	 .mask({maskH,maskL}), .match({matchH,matchL}));

//modified version of UART rx as seen in the spec
UART_trig_rx uart_trig_rx(.clk(clk), .rst_n(rst_n), .RX(CH1L),
	 .baud_cnt({baud_cntH,baud_cntL}), .match(matchL), .mask(maskL), .UARTtrig(UARTtrig));

assign protTrig = (SPItrig | TrigCfg[1]) & (UARTtrig | TrigCfg[0]);


endmodule
