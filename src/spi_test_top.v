module spi_test_top (
  input pin1,
  input pin2,
  output pin3,
  input pin4,
  input pin5,
  input pin6,
  input pin7,
  input pin8,
  output pin9,
  //inout pin10_sda,
  //inout pin11_scl,
  output pin16,
  output pin17,
  output pin18,
  //inout pin19_sclk,
  inout pin20,
  inout pin21,
  inout pin22
);

wire clk;
wire [3:0] tx;
wire [3:0] rx;

assign tx = {pin5, pin6, pin7, pin8};
assign rx = {pin9, pin16, pin17, pin18};

OSCH #(
	.NOM_FREQ("2.08")
) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
);

spi_slave #(
	.TXWIDTH(4),
	.RXWIDTH(4)
) spi (
	.clk(clk),
	.rst(pin22),
	.sclk(pin1),
	.mosi(pin2),
	.miso(pin3),
	.ss(pin4),
	.tx_buffer(tx),
	.wr(pin21),
	.rx_buffer(rx),
	.rx_dv(pin20)
);

endmodule
