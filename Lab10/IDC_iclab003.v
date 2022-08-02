// synopsys translate_off 
`ifdef RTL
`include "GATED_OR.v"
`else
`include "Netlist/GATED_OR_SYN.v"
`endif
// synopsys translate_on
module IDC(
	// Input signals
	clk,
	rst_n,
	cg_en,
	in_valid,
	in_data,
	op,
	// Output signals
	out_valid,
	out_data
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------  
input		clk;
input		rst_n;
input		in_valid;
input		cg_en;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid;//
output reg  signed [6:0] out_data;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
parameter IDLE 	= 'd0;
parameter INPUT = 'd1;
parameter OPER 	= 'd2;
parameter OUT 	= 'd3;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [3:0] current_state, next_state;

reg signed [6:0] img_r [0:7][0:7];
reg [3:0] op_r [0:14];
reg [3:0] in_cnt1, in_cnt2;
reg [4:0] in_cnt3;

reg [3:0] oper_cnt;
reg [2:0] oper_p_row, oper_p_col;
reg [2:0] out_cnt1, out_cnt2;
wire [3:0] out_row, out_col;

wire signed [6:0] midpoint, midpoint1, midpoint2;
wire signed [6:0] max1_1, max1_2, min1_1, min1_2;
wire signed [6:0] mid1_1, mid1_2;

wire signed [6:0] average;

// Clock gating logic
wire G_clock_img;
wire G_sleep_img = !(next_state == IDLE || next_state == INPUT || next_state == OPER);
GATED_OR GATED_img (
	.CLOCK(clk),
	.SLEEP_CTRL(cg_en && G_sleep_img),	// gated clock
	.RST_N(rst_n),
	.CLOCK_GATED(G_clock_img)
);

wire G_clock_in;
wire G_sleep_in = !(next_state == INPUT || next_state == IDLE);
GATED_OR GATED_in (
	.CLOCK(clk),
	.SLEEP_CTRL(cg_en && G_sleep_in),	// gated clock
	.RST_N(rst_n),
	.CLOCK_GATED(G_clock_in)
);

wire G_clock_oper;
wire G_sleep_oper = !(next_state == IDLE || next_state == INPUT || next_state == OPER);
GATED_OR GATED_oper (
	.CLOCK(clk),
	.SLEEP_CTRL(cg_en && G_sleep_oper),	// gated clock
	.RST_N(rst_n),
	.CLOCK_GATED(G_clock_oper)
);

wire G_clock_out;
wire G_sleep_out = !(next_state == IDLE || next_state == OUT);
GATED_OR GATED_out (
	.CLOCK(clk),
	.SLEEP_CTRL(cg_en && G_sleep_out),	// gated clock
	.RST_N(rst_n),
	.CLOCK_GATED(G_clock_out)
);

//================================================================
// DESIGN
//================================================================

// current state
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end
// next state
always @(*) begin
	case (current_state)
		IDLE: begin
			if (in_valid)		next_state = INPUT;
			else				next_state = current_state;
		end
		INPUT: begin
			if (!in_valid)		next_state = OPER;
			else 				next_state = current_state;
		end
		OPER: begin
			if (oper_cnt == 15)	next_state = OUT;
			else				next_state = current_state;
		end
		OUT: begin
			if (out_cnt1 == 0 && out_cnt2 == 0)	next_state = IDLE;
			else				next_state = current_state;
		end
		default: 				next_state = current_state;
	endcase
end

// input count
always @(posedge G_clock_in or negedge rst_n) begin
	if (!rst_n) begin
		in_cnt1 <= 0;
		in_cnt2 <= 0;
	end
	else begin
		if (next_state == INPUT) begin
			if (in_cnt1 == 7) begin
				if (in_cnt2 == 7) begin
					in_cnt1 <= 0;
					in_cnt2 <= 0;
				end
				else begin
					in_cnt2 <= in_cnt2 + 1;
				end
			end
			else begin
				if (in_cnt2 == 7) begin
					in_cnt1 <= in_cnt1 + 1;
					in_cnt2 <= 0;
				end
				else begin
					in_cnt2 <= in_cnt2 + 1;
				end
			end
		end
		else if (next_state == IDLE) begin
			in_cnt1 <= 0;
			in_cnt2 <= 0;
		end
	end
end
always @(posedge G_clock_in or negedge rst_n) begin
	if (!rst_n) begin
		in_cnt3 <= 0;
	end
	else begin
		if (next_state == INPUT) begin
			if (in_cnt3 < 16) begin
				in_cnt3 <= in_cnt3 + 1;
			end
		end
		else if (next_state == IDLE) begin
			in_cnt3 <= 0;
		end
	end
end
// operation count
always @(posedge G_clock_oper or negedge rst_n) begin
	if (!rst_n) begin
		oper_cnt <= 0;
	end
	else begin
		if (next_state == OPER) begin
			oper_cnt <= oper_cnt + 1;
		end
		else if (next_state == IDLE) begin
			oper_cnt <= 0;
		end
	end
end
// op reg
always @(posedge G_clock_in or negedge rst_n) begin
	if (!rst_n) begin

	end
	else begin
		if (next_state == INPUT) begin
			if (in_cnt3 < 16) begin
				op_r[in_cnt3] <= op;
			end
		end
	end
end

// midpoint
assign max1_1 = (img_r[oper_p_row][oper_p_col] > img_r[oper_p_row][oper_p_col+1])? img_r[oper_p_row][oper_p_col] : img_r[oper_p_row][oper_p_col+1];
assign min1_1 = (img_r[oper_p_row][oper_p_col] < img_r[oper_p_row][oper_p_col+1])? img_r[oper_p_row][oper_p_col] : img_r[oper_p_row][oper_p_col+1];
assign max1_2 = (img_r[oper_p_row+1][oper_p_col] > img_r[oper_p_row+1][oper_p_col+1])? img_r[oper_p_row+1][oper_p_col] : img_r[oper_p_row+1][oper_p_col+1];
assign min1_2 = (img_r[oper_p_row+1][oper_p_col] < img_r[oper_p_row+1][oper_p_col+1])? img_r[oper_p_row+1][oper_p_col] : img_r[oper_p_row+1][oper_p_col+1];

assign midpoint1 = (max1_1 > max1_2)? max1_2 : max1_1;
assign midpoint2 = (min1_1 > min1_2)? min1_1 : min1_2;

assign midpoint = (midpoint1 + midpoint2) / 2;

assign average = (img_r[oper_p_row][oper_p_col] + img_r[oper_p_row][oper_p_col+1] + img_r[oper_p_row+1][oper_p_col] + img_r[oper_p_row+1][oper_p_col+1]) / 4;

// image
always @(posedge G_clock_img or negedge rst_n) begin
	if (!rst_n) begin

	end
	else begin
		if (next_state == INPUT) begin
			img_r[in_cnt1][in_cnt2] <= in_data;
		end
		else if (next_state == OPER) begin
			case (op_r[oper_cnt])
				0: begin
					img_r[oper_p_row][oper_p_col] <= midpoint;
					img_r[oper_p_row][oper_p_col+1] <= midpoint;
					img_r[oper_p_row+1][oper_p_col] <= midpoint;
					img_r[oper_p_row+1][oper_p_col+1] <= midpoint;
				end
				1: begin
					img_r[oper_p_row][oper_p_col] <= average;
					img_r[oper_p_row][oper_p_col+1] <= average;
					img_r[oper_p_row+1][oper_p_col] <= average;
					img_r[oper_p_row+1][oper_p_col+1] <= average;
				end
				2: begin
					img_r[oper_p_row][oper_p_col] <= img_r[oper_p_row][oper_p_col+1];
					img_r[oper_p_row][oper_p_col+1] <= img_r[oper_p_row+1][oper_p_col+1];
					img_r[oper_p_row+1][oper_p_col] <= img_r[oper_p_row][oper_p_col];
					img_r[oper_p_row+1][oper_p_col+1] <= img_r[oper_p_row+1][oper_p_col];
				end
				3: begin
					img_r[oper_p_row][oper_p_col] <= img_r[oper_p_row+1][oper_p_col];
					img_r[oper_p_row][oper_p_col+1] <= img_r[oper_p_row][oper_p_col];
					img_r[oper_p_row+1][oper_p_col] <= img_r[oper_p_row+1][oper_p_col+1];
					img_r[oper_p_row+1][oper_p_col+1] <= img_r[oper_p_row][oper_p_col+1];
				end
				4: begin
					img_r[oper_p_row][oper_p_col] <= -img_r[oper_p_row][oper_p_col];
					img_r[oper_p_row][oper_p_col+1] <= -img_r[oper_p_row][oper_p_col+1];
					img_r[oper_p_row+1][oper_p_col] <= -img_r[oper_p_row+1][oper_p_col];
					img_r[oper_p_row+1][oper_p_col+1] <= -img_r[oper_p_row+1][oper_p_col+1];
				end
			endcase
		end
	end
end

// operation point
always @(posedge G_clock_oper or negedge rst_n) begin
	if (!rst_n) begin
		oper_p_row <= 3;
		oper_p_col <= 3;
	end
	else begin
		if (next_state == IDLE) begin
			oper_p_row <= 3;
			oper_p_col <= 3;
		end
		else if (next_state == OPER) begin
			case (op_r[oper_cnt])
				5: begin
					if (oper_p_row == 0) begin
						oper_p_row <= 0;
					end
					else begin
						oper_p_row <= oper_p_row - 1;
					end
				end
				6: begin
					if (oper_p_col == 0) begin
						oper_p_col <= 0;
					end
					else begin
						oper_p_col <= oper_p_col - 1;
					end
				end
				7: begin
					if (oper_p_row == 6) begin
						oper_p_row <= 6;
					end
					else begin
						oper_p_row <= oper_p_row + 1;
					end
				end
				8: begin
					if (oper_p_col == 6) begin
						oper_p_col <= 6;
					end
					else begin
						oper_p_col <= oper_p_col + 1;
					end
				end
			endcase
		end
	end
end

// output count
always @(posedge G_clock_out or negedge rst_n) begin
	if (!rst_n) begin
		out_cnt1 <= 0;
		out_cnt2 <= 0;
	end
	else begin
		if (next_state == OUT) begin
			if (out_cnt1 == 3) begin
				if (out_cnt2 == 3) begin
					out_cnt1 <= 0;
					out_cnt2 <= 0;
				end
				else begin
					out_cnt2 <= out_cnt2 + 1;
				end
			end
			else begin
				if (out_cnt2 == 3) begin
					out_cnt1 <= out_cnt1 + 1;
					out_cnt2 <= 0;
				end
				else begin
					out_cnt2 <= out_cnt2 + 1;
				end
			end
		end
		else if (next_state == IDLE) begin
			out_cnt1 <= 0;
			out_cnt2 <= 0;
		end
	end
end

assign out_row = (oper_p_row < 4 && oper_p_col < 4)? (oper_p_row + 1'b1 + out_cnt1) : (out_cnt1 + out_cnt1);
assign out_col = (oper_p_row < 4 && oper_p_col < 4)? (oper_p_col + 1'b1 + out_cnt2) : (out_cnt2 + out_cnt2);

// output data
always @(posedge G_clock_out or negedge rst_n) begin
	if (!rst_n) begin
		out_valid <= 0;
		out_data <= 0;
	end
	else begin
		if (next_state == OUT) begin
			out_valid <= 1;
			out_data <= img_r[out_row][out_col];
		end
		else if (next_state == IDLE) begin
			out_valid <= 0;
			out_data <= 0;
		end
	end
end

endmodule // IDC