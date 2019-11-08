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
reg [6:0] rollover; // 7 bits
parameter INTERNAL_COUNT = 78125;
integer counter;
reg last_rollover;

// synchronize the external source
assign trig_edge_pulse = trig && (~s_trig);

always @(posedge clk) begin
	s_trig <= trig;
	if (rst) begin
		s_trig <= 0;
	end
end

always @(posedge clk) begin
	counter <= counter;
	rollover <= rollover;
	one_hz <= 0;
	half_hz_50 <= half_hz_50;
	last_rollover <= rollover[6];
	if (rst) begin
		one_hz <= 0;
		half_hz_50 <= 0;
		counter <= 0;
		rollover <= 0;
		last_rollover <= 0;
	end
	if (rollover[6] && ~(last_rollover)) begin
		counter <= counter + 1;
	end
	if (counter == INTERNAL_COUNT) begin
		one_hz <= 1;
		half_hz_50 <= ~half_hz_50;
		counter <= 0;
	end
	if (trig_edge_pulse) begin
		rollover <= rollover + 1;
	end
end

endmodule