module z_1_rtc_top (
	`ifdef SIM
		input sim_clk,
	`endif
	             //micro pins  //usage
	output pb8b, //pc0 ------> miso
	input  pb8a, //pc1 ------> sck
	input  pb5a, //pe2 ------> ss
	input  pb25b,//pe3 ------> mosi
	inout  pl9a, //pb1 ------> n/a
	output pl2a, //n/a ------> one_hz
	input  pl2b  //n/a ------> freq source
);

// global clk and rst
wire clk, rst;
assign rst = 1'b0;

// SPI0 interface
wire sclk, mosi, miso, ss;
assign ss = ~pb5a;
assign mosi = pb25b & ss;
assign pb8b = miso; //ss ? miso : 1'bz;
assign sclk = pb8a & ss;

// other external pins
wire frequency_source, epoch_set, epoch_reset;
assign frequency_source = pl2b;
//assign epoch_set = pin1;
//assign epoch_reset = pin2;

// SPI internal signals
wire [7:0] o_spi_data, i_spi_data;
wire spi_we, spi_halt, spi_dv;

// epoch signals
wire [63:0] i_epoch_data, o_epoch_data;
wire epoch_le, epoch_ce;
assign epoch_ce = 1'b1;

// divider signals
wire one_hz;
wire half_hz_50;

// debug outputs
assign pl2a = half_hz_50;
//assign pin9 = half_hz_50;

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

divider #(
	//.INTERNAL_COUNT(375),
	.INTERNAL_COUNT(78125),
	//.ROLLOVER_WIDTH(16)
	.ROLLOVER_WIDTH(8)
) main_divider (
	.clk(clk),
	.rst(rst),
	.trig(frequency_source),
	.one_hz(one_hz),
	.half_hz_50(half_hz_50)
);

spi_slave spi (
	.clk(clk),
	.rst(rst),
	.sclk(sclk),
	.mosi(mosi),
	.miso(miso),
	.tx_buffer(i_spi_data),
	.wr(spi_we),
	.tx_halt(spi_halt),
	.rx_buffer(o_spi_data),
	.rx_dv(spi_dv)
);

spi_fsm #(
	.WRCMD(8'h01),
	.RDCMD(8'h02)
) epoch_controller (
	.clk(clk),
	.rst(rst),
	.spi_we(spi_we),
	.spi_dv(spi_dv),
	.spi_halt(spi_halt),
	.i_data(o_spi_data),
	.o_data(i_spi_data),
	.buf_dv(epoch_le),
	.i_buffer(o_epoch_data),
	.o_buffer(i_epoch_data)
);

timer epoch (
	.clk(clk),
	.rst(rst),
	.count_enable(epoch_ce),
	.load_enable(epoch_le),
	.one_hz(one_hz),
	.i_time(i_epoch_data),
	.o_time(o_epoch_data)
);

/*trigger epoch_trigger (
	.rst(rst),
	.s(epoch_set),
	.r(epoch_reset),
	.q(epoch_ce)
);*/

endmodule
