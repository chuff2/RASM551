module UART(clk, rst_n, trmt, tx_data, TX, RX, tx_done, clr_rdy, cmd, rdy);

input logic clk, rst_n, trmt, RX, clr_rdy;
input logic [7:0] tx_data;
output logic rdy, TX, tx_done;
output logic [7:0] cmd;

// Instantiate transmitter and receiver
uart_tx transmitter (.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_data(tx_data), .TX(TX), .tx_done(tx_done) );
uart_rx receiver (.clk(clk), .rst_n(rst_n), .RX(RX), .clr_rdy(clr_rdy), .cmd(cmd), .rdy(rdy) );

endmodule
