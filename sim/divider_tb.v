`timescale 10ns/1ns

module divider_tb #(
	parameter BASE_FREQ = 4
);

reg clk;
reg rst;
reg trig;

wire opps;

divider #(
	.BASE_FREQ(BASE_FREQ)
) dut (
	.clk(clk),
	.rst(rst),
	.trig(trig),
	.one_hz(opps)
);

wire [63:0] o_time;

timer epoch (
	.clk(clk),
	.rst(rst),
	.count_enable(1'b1),
	.load_enable(1'b0),
	.one_hz(opps),
	.i_time(64'b0),
	.o_time(o_time)
);

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
	forever #1 clk = ~clk;
end

integer idx;

initial begin
	trig = 0;
	for(idx = 0; idx < 17; idx = idx + 1) begin
		#(($urandom%10) + 2);
		trig = 1;
		#(($urandom%10) + 2);
		trig = 0;
	end
	$finish;
end

initial begin
	$dumpfile("divider.vcd");
	$dumpvars;
	$dumplimit(5000000);
end

endmodule
