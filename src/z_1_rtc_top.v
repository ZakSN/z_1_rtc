module z_1_rtc_top (
	`ifdef SIM
		input sim_clk,
	`endif
	//***SPI0 BUS***
	inout  pin11, // SPI0_CLK
	inout  pin4,  // SPI0_MOSI
	inout pin20, // SPI0_MISO
	input  pin18, // SPI0_CS/b_ATMEGA328PB_RST
	
	//***EPOCH CNTRL***
	input  pin1,  // EPOCH_S
	input  pin2,  // EPOCH_R

	//***MFREQ & RST***
	input  pin5,  // MASTER_FREQ
	input  pin22, // b_FPGA_RST
	
	//***OUTPUT PINS***
	//inout pin6,  // out1 (TIMER_S)
	//inout pin7,  // out2 (TIMER_R)
	output pin19, // out3 (half_hz_50)
	//output pin21, // out4
	output pin3  // out5
	//inout pin8,  // out6
	//inout pin9,  // out7
	//inout pin10, // out8
	//inout pin16, // out9
	//inout pin17, // out10
	
	//***UNUSED***
	//PRGM pin12,
	//PRGM pin13,
	//PRGM pin14,
	//PRGM pin15,
);

// global clk and rst
wire clk, rst;
assign rst = ~pin22;

// SPI0 interface
wire sclk, mosi, miso, ss;
assign ss = pin18;

assign pin11 = ss ? pin11 : 1'bz;
assign sclk = pin11;

assign pin4 = ss ? pin4 : 1'bz;
assign mosi = pin4;

assign pin20 = ss ? miso : 1'bz;

// other external pins
wire frequency_source, epoch_set, epoch_reset;
assign frequency_source = pin5;
assign epoch_set = pin1;
assign epoch_reset = pin2;

// SPI internal signals
wire [7:0] o_spi_data, i_spi_data;
wire spi_we, spi_halt, spi_dv;

// epoch signals
wire [63:0] i_epoch_data, o_epoch_data;
wire epoch_le, epoch_ce;

// divider signals
wire one_hz;
wire half_hz_50;

// debug outputs
assign pin19 = rst;
assign pin3 = half_hz_50;

`ifndef SIM
OSCH #(
	.NOM_FREQ("88.67")
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

trigger epoch_trigger (
	.rst(rst),
	.s(epoch_set),
	.r(epoch_reset),
	.q(epoch_ce)
);

endmodule
