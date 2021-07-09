`timescale 10ns/1ns

module spi_test_top_tb #(
	parameter SCLK_PERIOD = 9
)();

reg clk, rst, sclk, mosi;
wire miso;

//reset
initial begin
        clk = 0;
        rst = 1;
        #1;
        rst = 1;
        clk = 1;
        #1;
        clk = 0;
        rst = 1;
        #1;
        clk = 1;
        rst = 0;
	#1;
	clk = 0;
	#1;
	clk = 1;
	#1;
	clk = 0;
        forever #1 clk = ~clk;
end

// read transaction
/*
integer idx;
initial begin
	sclk = 0;
	mosi = 0;
	#7 //offset sclk from clk
	
	// write 0x02 (RDCMD) to SPI port
	for (idx = 0; idx < 5; idx = idx + 1) begin
		sclk = 1; #SCLK_PERIOD;
		mosi = 0;
		sclk = 0; #SCLK_PERIOD;
	end
	sclk = 1; #SCLK_PERIOD;
	mosi = 1;
	sclk = 0; #SCLK_PERIOD;
	sclk = 1; #SCLK_PERIOD;
	mosi = 0;
	sclk = 0; #SCLK_PERIOD;
	sclk = 1; #SCLK_PERIOD;
	
	for (idx = 0; idx < 64; idx = idx + 1) begin
	sclk = 0; #SCLK_PERIOD;
	sclk = 1; #SCLK_PERIOD;
	end

	$finish;
end
*/

//write transaction
integer idx;
initial begin
	sclk = 0;
	mosi = 0;
	#7 //offset sclk from clk
	
	// write 0x01 (WRCMD) to SPI port
	for (idx = 0; idx < 6; idx = idx + 1) begin
		sclk = 1; #SCLK_PERIOD;
		mosi = 0;
		sclk = 0; #SCLK_PERIOD;
	end
	sclk = 1; #SCLK_PERIOD;
	mosi = 1;
	sclk = 0; #SCLK_PERIOD;
	
	// write 0xFF_FF_FF_FF_FF_FF_FF_FF
	for (idx = 0; idx < 64; idx = idx + 1) begin
	sclk = 1; #SCLK_PERIOD;
	mosi = 1;
	sclk = 0; #SCLK_PERIOD;
	end

	sclk = 1; #SCLK_PERIOD;
	sclk = 0; #SCLK_PERIOD;
	$finish;
end
spi_test_top dut (
	.sim_clk(clk),
	.pin1(sclk),
	.pin2(mosi),
	.pin3(miso),
	.pin4(1'b0),
	.pin22(rst)
);

initial begin
	$dumpfile("spi_test_top.vcd");
	$dumpvars;
	$dumplimit(5000000);
end

endmodule
