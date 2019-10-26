module divider #(
	parameter BASE_FREQ = 10_000_000
)(
	input clk,
	input rst,
	input trig,

	output reg one_hz,
	output reg half_hz_50
);

reg s_trig;
wire trig_edge_pulse;
integer count;

assign trig_edge_pulse = trig && (~s_trig);

always @(posedge clk) begin
	s_trig <= s_trig;
	count <= count;
	one_hz <= 0;
	if (rst) begin
		one_hz <= 0;
		half_hz_50 <= 0;
		s_trig <= 0;
		count <= 0;
	end else begin
		s_trig <= trig;
	end
	if (trig_edge_pulse) begin
		count <= count + 1;
	end
	if (count >= BASE_FREQ) begin
		count <= 0;
		one_hz <= 1;
		half_hz_50 <= ~half_hz_50;
	end
end

endmodule
