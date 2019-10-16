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
  input pin22
);

wire clk, rst;
assign rst = pin22;

wire sclk, mosi, miso, ss;
assign sclk = pin1;
assign mosi = pin2;
assign miso = pin3;
assign ss = pin4;

wire rx_dv;
wire tx_halt;
wire wr;
wire [7:0] data_out;
wire [7:0] data_in;

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
	.tx_buffer(data_out),
	.wr(wr),
	.tx_halt(tx_halt),
	.rx_buffer(data_in),
	.rx_dv(rx_dv)
);

wire cmd_vld;
wire [7:0] cmd;
assign cmd_vld = (rx_dv && ((data_in == 8'h01) || (data_in == 8'h02)))? 1'b1: 1'b0;

wire [63:0] d_dat;
wire [63:0] q_dat;
wire d_we;

register #(
	.WIDTH(8)
) cmd_reg (
	.clk(clk),
	.rst(rst),
	.we(cmd_vld),
	.d(data_in),
	.q(cmd)
);

register #(
	.WIDTH(64)
) data_reg (
	.clk(clk),
	.rst(rst),
	.we(d_we),
	.d(d_dat),
	.q(q_dat)
);

wire s2p_we;
assign s2p_we = ((cmd == 8'h01) && rx_dv)? 1'b1: 1'b0;

SIPO #(
	.DEPTH(8),
	.WIDTH(8)
) s2p (
	.clk(clk),
	.rst(rst),
	.si(data_in),
	.we(s2p_we),
	.po(d_dat),
	.po_dv(d_we)
);

wire p2s_we;
assign p2s_we = ((cmd == 8'h02) && (rx_dv))? 1'b1: 1'b0;

PISO #(
	.DEPTH(8),
	.WIDTH(8)
) p2s (
	.clk(clk),
	.rst(rst),
	.pi(q_dat),
	.we(p2s_we),
	.so(data_out),
	.so_dv(wr),
	.halt(tx_halt)
);

endmodule
