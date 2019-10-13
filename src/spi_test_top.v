module spi_test_top (
  input pin1,
  input pin2,
  output pin3,
  input pin4,
  //input pin5,
  //input pin6,
  //input pin7,
  //input pin8,
  //output pin9,
  //inout pin10_sda,
  //inout pin11_scl,
  //output pin16,
  //output pin17,
  //output pin18,
  //inout pin19_sclk,
  //inout pin20,
  //inout pin21,
  inout pin22
);

wire clk, rst;
assign rst = pin22;

wire sclk, mosi, miso, ss;
assign sclk = pin1;
assign mosi = pin2;
assign miso = pin3;
assign ss = pin4;

wire [7:0] loopback;
wire rx_dv;
reg wr;

always @(posedge clk) begin
	if (rx_dv && (loopback != 8'b00000000)) begin
		wr <= 1;
	end else begin
		wr <= 0;
	end
end

OSCH #(
	.NOM_FREQ("53.2")
) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
);

spi_slave #(
	.TXWIDTH(8),
	.RXWIDTH(8)
) spi (
	.clk(clk),
	.rst(rst),
	.sclk(sclk),
	.mosi(mosi),
	.miso(miso),
	.ss(ss),
	.tx_buffer(loopback),
	.wr(wr),
	.rx_buffer(loopback),
	.rx_dv(rx_dv)
);

endmodule
