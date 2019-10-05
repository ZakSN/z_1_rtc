module counter #(
	parameter WIDTH = 4
)(
	input clk,
	input rst,
	input trig,

	output reg [WIDTH-1:0] count
);

parameter [1:0] S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
reg [1:0] current_state, next_state;
reg [WIDTH-1:0] c;

// state register
always @(posedge clk) begin
	if (rst) begin
		current_state <= S0;
		count <= 0;
	end else begin
		current_state <= next_state;
		count <= c;
	end
end

// transition logic and output
always @(*) begin
	case(current_state)
		S0: begin
			next_state = (trig == 1'b1)? S2: S1;
			c = count;
		end
		S1: begin
			next_state = (trig == 1'b1)? S3: S1;
			c = count;
		end
		S2: begin
			next_state = (trig == 1'b1)? S2: S1;
			c = count;
		end
		S3: begin
			next_state = (trig == 1'b1)? S2: S1;
			c = count + 1;
		end
	endcase
end
endmodule
