module divider #(
	parameter BASE_FREQ = 10_000_000
)(
	input clk,
	input rst,
	input trig,

	output reg one_hz
);

parameter [1:0] S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
reg [1:0] current_state, next_state;
integer count;

// state register
always @(posedge clk) begin
	if (rst) begin
		current_state <= S0;
		count <= 0;
	end else begin
		current_state <= next_state;
	end
end

// transition logic
always @(*) begin
	case(current_state)
		S0: begin
			next_state = (trig == 1'b1)? S2: S1;
		end
		S1: begin
			next_state = (trig == 1'b1)? S3: S1;
		end
		S2: begin
			next_state = (trig == 1'b1)? S2: S1;
		end
		S3: begin
			next_state = (trig == 1'b1)? S2: S1;
		end
	endcase
end

// output logic
always @(posedge clk) begin
	count <= count;
	one_hz <= 0;
	if (current_state == S3) begin
		count <= count + 1;
	end
	if (count == BASE_FREQ) begin
		count <= 0;
		one_hz <= 1;
	end
end
endmodule
