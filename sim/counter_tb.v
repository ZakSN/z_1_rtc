`timescale 10ns/1ns

module counter_tb #(
	parameter WIDTH = 4
);

reg clk;
reg rst;
reg trig;

wire [WIDTH-1:0]count;

counter #(
	.WIDTH(WIDTH)
) dut (
	.clk(clk),
	.rst(rst),
	.trig(trig),
	.count(count)
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
	$dumpfile("counter.vcd");
	$dumpvars;
	$dumplimit(5000000);
end

endmodule
