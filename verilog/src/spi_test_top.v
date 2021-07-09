module spi_test_top (
  `ifdef SIM
	input sim_clk,
  `endif
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
  input pin22
);

wire clk, rst;
assign rst = pin22;

wire sclk, mosi, miso, ss;
assign sclk = pin1;
assign mosi = pin2;
assign miso = pin3;
assign ss = pin4;

wire spi_dv, spi_halt, spi_we;
wire data_register_we;
wire [63:0] d, q;
wire [7:0] o_data;
wire [7:0] i_data;

`ifndef SIM
OSCH #(
	.NOM_FREQ("53.2")
) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
);
`else
	assign clk = sim_clk;
`endif

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
	.tx_buffer(o_data),
	.wr(spi_we),
	.tx_halt(spi_halt),
	.rx_buffer(i_data),
	.rx_dv(spi_dv)
);

register #(
	.WIDTH(64)
) data_register (
	.clk(clk),
	.rst(rst),
	.we(data_register_we),
	.d(d),
	.q(q)
);

spi_fsm controller (
	.clk(clk),
	.rst(rst),
	.spi_we(spi_we),
	.spi_dv(spi_dv),
	.spi_halt(spi_halt),
	.i_data(i_data),
	.o_data(o_data),
	.buf_dv(data_register_we),
	.i_buffer(q),
	.o_buffer(d)
);

endmodule
