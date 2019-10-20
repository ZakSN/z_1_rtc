module spi_fsm #(
	parameter DEPTH = 8, // number of chunks
	parameter WIDTH = 8, // bits per chunk
	parameter WRCMD = 8'h01,
	parameter RDCMD = 8'h02
)(
	input clk,
	input rst,

	output reg spi_we, // spi_slave wr
	input spi_dv, // spi_slave rx_dv
	input spi_halt,
	input [WIDTH-1:0] i_data, // chunks from spi slave
	output reg [WIDTH-1:0] o_data, // chunks to spi slave

	output reg buf_dv, // fsm buffer data valid
	input [(DEPTH*WIDTH)-1:0] i_buffer,
	output reg [(DEPTH*WIDTH)-1:0] o_buffer
);
parameter [2:0] S0 = 3'b000,
		S1 = 3'b001,
		S2 = 3'b010,
		S3 = 3'b011,
		S4 = 3'b100,
		S5 = 3'b101;

integer count;
reg [2:0] current_state, next_state;

// state register
always @(posedge clk) begin
	if (rst) begin
		current_state <= S0;
	end else begin
		current_state <= next_state;
	end
end

// transition logic
always @(*) begin
	case(current_state)
		S0: begin
			if (spi_dv && (i_data == WRCMD)) begin
				next_state =  S1;
			end else if (spi_dv && (i_data == RDCMD)) begin
				next_state = S3;
			end else begin
				next_state = S0;
			end
		end
		S1: begin
			if(count != 0) begin
				next_state = S1;
			end else begin
				next_state = S2;
			end
		end
		S2: begin
			next_state = S0;
		end
		S3: begin
			next_state = S4;
		end
		S4: begin
			if(count != 0) begin
				next_state = S5;
			end else begin
				next_state = S0;
			end
		end
		S5: begin
			next_state <= S4;
		end
	endcase
end

// output logic
always @(posedge clk) begin
	spi_we <= spi_we;
	o_data <= o_data;
	buf_dv <= buf_dv;
	o_buffer <= o_buffer;
	count <= count;
	if(rst) begin
		spi_we <= 0;
		o_data <= 0;
		buf_dv <= 0;
		o_buffer <= 0;
		count <= DEPTH;
	end else begin
		case(current_state)
			S0: begin
				spi_we <= 0;
				buf_dv <= 0;
				count <= DEPTH;
			end
			S1: begin
				if(spi_dv) begin
					o_buffer <= {o_buffer[(WIDTH*(DEPTH-1))-1:0], i_data};
					count <= count - 1;
				end
			end
			S2: begin
				buf_dv <= 1;
			end
			S3: begin
				o_buffer <= i_buffer;
			end
			S4: begin
				if(~spi_halt) begin 
					spi_we <= 1;
					o_data <= o_buffer[(WIDTH*DEPTH)-1:(WIDTH*(DEPTH-1))];
					o_buffer <= {o_buffer[(WIDTH*(DEPTH-1))-1:0], {WIDTH{1'b0}}};
					count <= count - 1;
				end else begin
					spi_we <= 0;
				end
			end
			S5: begin
				count <= count; // wait for SPI to assert halt
			end
		endcase
	end
end

endmodule
