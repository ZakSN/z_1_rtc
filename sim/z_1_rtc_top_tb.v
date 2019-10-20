`timescale 10ns/1ns

module z_1_rtc_top_tb #(
	parameter SCLK_PERIOD = 29
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

integer idx;
integer idx2;
initial begin
	sclk = 0;
	mosi = 0;
	#17 //offset sclk from clk
	
	for(idx2 = 0; idx2 < 2; idx2 = idx2 + 1) begin
		sclk = 0; #SCLK_PERIOD;
		mosi = 0; #SCLK_PERIOD;
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
		
		for (idx = 0; idx < 65; idx = idx + 1) begin
		sclk = 1; #SCLK_PERIOD;
		mosi = 0;
		sclk = 0; #SCLK_PERIOD;
		end
	end
	$finish;
end

reg time_signal;
initial begin
	time_signal = 0;
	forever #3 time_signal = ~time_signal;
end

z_1_rtc_top dut (
	.sim_clk(clk),
	.pin1(sclk),
	.pin2(mosi),
	.pin3(msio),
	.pin4(1'b0),
	.pin5(time_signal),
	.pin6(1'b0),
	.pin7(1'b0),
	.pin22(rst)
);

initial begin
	$dumpfile("z_1_rtc_top.vcd");
	$dumpvars;
	$dumplimit(5000000);
end

endmodule
