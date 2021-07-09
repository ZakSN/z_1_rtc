module register #(
	parameter WIDTH = 8
)(
	input clk,
	input rst,

	input we,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q
);

always @(posedge clk) begin
	if (rst) begin
		q <= 0;
	end else if (we) begin
		q <= d;
	end else begin
		q <= q;
	end
end

endmodule
