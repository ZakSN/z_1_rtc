`timescale 10ns/1ns

module spi_slave_tb #(
	parameter WIDTH = 8
);

reg clk;
reg rst;

initial begin
        clk = 0;
        rst = 1;
	wr = 0;
        #1;
        rst = 1;
        clk = 1;
        #1;
        clk = 0;
        rst = 1;
        #1;
        clk = 1;
        rst = 0;
	wr = 1;
	#1;
	clk = 0;
	#1;
	clk = 1;
	#1;
	clk = 0;
	wr = 0;
        forever #1 clk = ~clk;
end

reg sclk, mosi, ss, wr;
wire [WIDTH-1:0] to_tx;
wire [WIDTH-1:0] rxed;
wire miso;

spi_slave #(
	.TXWIDTH(WIDTH),
	.RXWIDTH(WIDTH)
) dut (
	.clk(clk),
	.rst(rst),
	.sclk(sclk),
	.mosi(mosi),
	.miso(miso),
	.ss(ss),
	.tx_buffer(to_tx),
	.wr(wr),
	.rx_buffer(rxed)
);

integer idx;
reg [8:0] to_shift = 9'b101010101;

// test dut RX
initial begin
	mosi = 0;
	sclk = 0;
	for(idx = 0; idx < 9; idx = idx + 1) begin
		sclk = 0;
		mosi = to_shift[(8)-idx];
		#17;
		sclk = 1;
		#17;
	end
	$finish;
end

//test dut TX
assign to_tx = 8'b01010101;

initial begin
	$dumpfile("spi_slave.vcd");
	$dumpvars;
	$dumplimit(5000000);
end

endmodule
