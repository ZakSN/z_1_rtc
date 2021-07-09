module trigger (
	input rst,
	input s, // set
	input r, // reset
	output reg q
);

always @(posedge rst, posedge s, posedge r) begin
	q <= q;
	if (rst) begin
		q <= 0;
	end
	if (s) begin
		q <= 1;
	end

	if (r) begin
		q <= 0;
	end
end

endmodule
