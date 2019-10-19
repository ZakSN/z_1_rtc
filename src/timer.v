module timer #(
	parameter WIDTH = 64
)(
	input clk,
	input rst,

	input count_enable,
	input load_enable,

	input one_hz,

	input [WIDTH-1:0] i_time,
	output [WIDTH-1:0] o_time
);

reg [WIDTH-1:0] d;
reg we;

always @(posedge clk) begin
	we <= 0;
	d <= d;
	if (load_enable) begin
		d <= i_time;
		we <= 1;
	end else if(count_enable && one_hz) begin
		d <= o_time + 1;
		we <= 1;
	end
end

register #(
	.WIDTH(WIDTH)
) r (
	.clk(clk),
	.rst(rst),
	.we(we),
	.d(d),
	.q(o_time)
);

endmodule
