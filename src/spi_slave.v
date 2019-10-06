/*
* This module is a simple single mode spi slave, with a configurable tx and rx
* buffer width.
* clock polarity (CPOL) is 0
* clock phase (CPHA) is 0
*/
module spi_slave #(
	parameter TXWIDTH = 8,
	parameter RXWIDTH = 8
)(
	input clk,
	input rst,

	// SPI interface signals
	input sclk,
	input mosi,
	output miso,
	input ss,

	// buffer to serialize and transmit
	input [TXWIDTH-1:0] tx_buffer,
	input wr,

	// recived bits
	output reg [RXWIDTH-1:0] rx_buffer
);

wire ah_ss;
assign ah_ss = ~ss;

reg [TXWIDTH-1:0] txb;
reg [RXWIDTH-1:0] rxb;

// reset and write buffers
always @(posedge clk) begin
	if (rst) begin
		rxb <= 0;
		txb <= 0;
	end else if (wr) begin
		txb <= tx_buffer;
	end else begin
		txb <= txb;
		rx_buffer <= rxb;
	end
end

// recieve SPI bits
always @(posedge sclk) begin
	rxb <= {rxb[RXWIDTH-2:0], mosi};
end

endmodule
