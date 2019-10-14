module SIPO #(
	parameter DEPTH=8,
	parameter WIDTH=8
)(
	input clk,
	input rst,

	input [WIDTH-1:0] si,
	input we,

	output reg [(DEPTH*WIDTH)-1:0] po,
	output reg po_dv
);

integer chunks_in;

always @(posedge clk) begin
	if (rst) begin
		po_dv <= 0;
		po <= 0;
		chunks_in <= 0;
	end else if (we) begin
		po <= {po[(WIDTH*(DEPTH-1))-1:0], si};
		chunks_in <= chunks_in + 1;
	end

	if (chunks_in == DEPTH) begin
		chunks_in <= 0;
		po_dv <=1;
	end else begin
		po_dv <=0;
	end
end

endmodule
