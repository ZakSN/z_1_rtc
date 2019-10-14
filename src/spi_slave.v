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
	output reg tx_halt,

	// parallelized recived bits
	output reg [RXWIDTH-1:0] rx_buffer,
	output reg rx_dv
);

reg [TXWIDTH-1:0] txb;

integer bits_in, bits_out;

reg s_sclk, ds_sclk; //sync'd sclk, snyc'd delayed sclk
wire ppulse_s_sclk, npulse_s_sclk; //pulse on +ve/-ve edge of s_sclk

// synchronize sclk to the internal clock
always @(posedge clk) begin
	s_sclk <= sclk;
	ds_sclk <= s_sclk;
end

//generate pulses on the +ve and -ve edges
assign ppulse_s_sclk = s_sclk & (~ds_sclk);
assign npulse_s_sclk = (~s_sclk) & ds_sclk;

always @(posedge clk) begin
	if(rst) begin
		miso <= 0;
		rx_buffer <= 0;
		rx_dv <= 0;
		bits_in <= 0;
		bits_out <= 0;
	end else if (ppulse_s_sclk) begin
		// posedge of s_sclk
		rx_buffer <= {rx_buffer[RXWIDTH-2:0], mosi};
		bits_in <= bits_in + 1;
	end else if (npulse_s_sclk) begin
		// negedge of s_sclk
		if (bits_out != 0) begin
			miso <= txb[TXWIDTH-1];
			txb <= {txb[TXWIDTH-2:0], 1'b0};
			bits_out <= bits_out - 1;
			tx_halt <= 1;
		end else begin
			tx_halt <= 0;
		end
	end
	if (bits_in == RXWIDTH) begin
		rx_dv <= 1;
		bits_in <= 0;
	end else begin
		rx_dv <= 0;
	end
	if (wr & ~tx_halt) begin
		txb <= tx_buffer;
		bits_out <= TXWIDTH;
	end
end

endmodule
