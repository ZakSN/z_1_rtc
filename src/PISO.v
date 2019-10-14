module PISO #(
	parameter DEPTH=8,
	parameter WIDTH=8
)(
	input clk,
	input rst,

	input [(DEPTH*WIDTH)-1:0] pi,
	input we,

	output reg [WIDTH-1:0] so,
	output reg so_dv,
	input halt
);

integer chunks_out;
reg [(DEPTH*WIDTH)-1:0] pib;

always @(posedge clk) begin
	if (rst) begin
		so <= 0;
		so_dv <= 0;
		chunks_out <= 0;
	end else if (we) begin
		chunks_out <= DEPTH;
		pib <= pi;
	end
	if (chunks_out != 0 & ~halt) begin
		so <= pib[(DEPTH*WIDTH)-1:((DEPTH-1)*WIDTH)];
		pib <= {pib[((DEPTH-1)*WIDTH)-1:0], {WIDTH{1'b0}}};
		chunks_out <= chunks_out - 1;
	end else begin
		pib <= pib;
		chunks_out <= chunks_out;
	end
end

endmodule
