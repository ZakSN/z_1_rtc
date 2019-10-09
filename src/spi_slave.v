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
	output reg miso,
	input ss,

	// buffer to serialize and transmit
	input [TXWIDTH-1:0] tx_buffer,
	input wr,

	// parallelized recived bits
	output reg [RXWIDTH-1:0] rx_buffer,
	output reg rx_dv
);

wire ah_ss;
assign ah_ss = ~ss;

reg [TXWIDTH-1:0] txb;
reg [RXWIDTH-1:0] rxb;

integer bits_in, bits_out;

// clock synchronization
always @(posedge clk) begin
	if (rst) begin
		rxb <= 0;
		txb <= 0;
		rx_buffer <= 0;
		bits_in <= 0;
		bits_out <= 0;
		miso <= 0;
	end else if (wr) begin
		txb <= tx_buffer;
		bits_out <= TXWIDTH;
	end else begin
		txb <= txb;
	end
	if (bits_in == RXWIDTH) begin
		rx_dv <= 1;
		bits_in <= 0;
		rx_buffer <= rxb;
	end else begin
		rx_dv <= 0;
	end
end

// recieve bits
always @(posedge sclk) begin
	rxb <= {rxb[RXWIDTH-2:0], mosi};
	bits_in <= bits_in + 1;
end

// transmit bits
always @(posedge ~sclk) begin
	if (bits_out != 0) begin
		miso <= txb[TXWIDTH-1];
		txb <= {txb[TXWIDTH-2:0], 1'b0};
		bits_out <= bits_out - 1;
	end
end

endmodule
