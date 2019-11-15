module z_1_rtc_top (
	`ifdef SIM
		input sim_clk,
	`endif
	input pin1, // sclk
	input pin2, // mosi
	output pin3, // miso
	input pin4, // ss

	input pin5, // master frequency
	input pin6, // epoch set
	input pin7, // epoch reset

	//input pin8,
	output pin9,
	//inout pin10_sda,
	//inout pin11_scl,
	//output pin16,
	//output pin17,
	//output pin18,
	//inout pin19_sclk,
	//inout pin20,
	//inout pin21,

	input pin22 // global reset
);

// global clk and rst
wire clk, rst;
assign rst = pin22;

// external SPI interface pins
wire sclk, mosi, miso, ss;
assign sclk = pin1;
assign mosi = pin2;
assign miso = pin3;
assign ss = pin4;

// other external pins
wire frequency_source, epoch_set, epoch_reset;
assign frequency_source = pin5;
assign epoch_set = pin6;
assign epoch_reset = pin7;

// SPI internal signals
wire [7:0] o_spi_data, i_spi_data;
wire spi_we, spi_halt, spi_dv;

// epoch signals
wire [63:0] i_epoch_data, o_epoch_data;
wire epoch_le, epoch_ce;

// divider signals
wire one_hz;
wire half_hz_50;
assign pin9 = half_hz_50;

`ifndef SIM
OSCH #(
	.NOM_FREQ("53.20")
) internal_oscillator_inst (
	.STDBY(1'b0),
	.OSC(clk)
);
`else
assign clk = sim_clk;
`endif

divider #(
	.INTERNAL_COUNT(375),
	.ROLLOVER_WIDTH(16)
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
	.ss(ss),
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

trigger epoch_trigger (
	.rst(rst),
	.s(epoch_set),
	.r(epoch_reset),
	.q(epoch_ce)
);

endmodule
