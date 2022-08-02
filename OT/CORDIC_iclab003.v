module	CORDIC (
	input	wire				clk, rst_n, in_valid,
	input	wire	signed	[11:0]	in_x, in_y,
	output	reg		[11:0]	out_mag,
	output	reg		[20:0]	out_phase,
	output	reg					out_valid

	);

// input_x and input_y -> 1'b sign , 3'b int , 8'b fraction
// out_mag -> 4b int , 8'b fraction
// output -> 1'b int , 20'b fraction 
wire	[20:0]	cordic_angle [0:17];
wire    [14:0]	Constant;

//cordic angle -> 1'b int, 20'b fraciton
assign   cordic_angle[ 0] = 21'h04_0000; //  45        deg
assign   cordic_angle[ 1] = 21'h02_5c81; //  26.565051 deg
assign   cordic_angle[ 2] = 21'h01_3f67; //  14.036243 deg
assign   cordic_angle[ 3] = 21'h00_a222; //   7.125016 deg
assign   cordic_angle[ 4] = 21'h00_5162; //   3.576334 deg
assign   cordic_angle[ 5] = 21'h00_28bb; //   1.789911 deg
assign   cordic_angle[ 6] = 21'h00_145f; //   0.895174 deg
assign   cordic_angle[ 7] = 21'h00_0a30; //   0.447614 deg
assign   cordic_angle[ 8] = 21'h00_0518; //   0.223811 deg
assign   cordic_angle[ 9] = 21'h00_028b; //   0.111906 deg
assign   cordic_angle[10] = 21'h00_0146; //   0.055953 deg
assign   cordic_angle[11] = 21'h00_00a3; //   0.027976 deg
assign   cordic_angle[12] = 21'h00_0051; //   0.013988 deg
assign   cordic_angle[13] = 21'h00_0029; //   0.006994 deg
assign   cordic_angle[14] = 21'h00_0014; //   0.003497 deg
assign   cordic_angle[15] = 21'h00_000a; //   0.001749 deg
assign   cordic_angle[16] = 21'h00_0005; //   0.000874 deg
assign   cordic_angle[17] = 21'h00_0003; //   0.000437 deg
   
//Constant-> 1'b int, 14'b fraction
assign  Constant = {1'b0,14'b10011011011101}; // 1/K = 0.6072387695

parameter IDLE = 'd0;
parameter INPUT = 'd1;
parameter TAKE = 'd2;
parameter ROTATE = 'd3;
parameter CAL = 'd4;
parameter SAVE = 'd5;
parameter OUT = 'd6;

reg [2:0] current_state, next_state;

reg [9:0] in_cnt, out_cnt;
reg [9:0] addr_save;

reg step_done;
reg [4:0] cal_cnt;
reg out_ready;

reg signed [19:0] x_reg;
reg signed [19:0] y_reg;
wire signed [32:0] mag_reg;
reg [20:0] z_reg;

// Memory
reg [11:0] in_data12;
wire [11:0]	out_data12;
reg [20:0] in_data21;
wire [20:0]	out_data21;

reg [9:0] addr12, addr21;
reg wen12, wen21;

// Current State
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		current_state <= IDLE;
    else
		current_state <= next_state;
end

// Next State
always @(*) begin
    case (current_state)
		IDLE: begin
			if (in_valid) next_state = INPUT;
			else next_state = current_state;
		end
		INPUT: begin
			if (!in_valid) next_state = TAKE;
			else next_state = current_state;
		end
		TAKE: begin
			next_state = ROTATE;
		end
		ROTATE: begin
			next_state = CAL;
		end
		CAL: begin
			if (cal_cnt == 17) next_state = SAVE;
			else next_state = current_state;
		end
		SAVE: begin
			if(addr_save == in_cnt) next_state = OUT;
			else next_state = TAKE;
		end
		OUT: begin
			if (out_cnt == in_cnt) next_state = IDLE;
			else next_state = current_state;
		end
		default: next_state = current_state;
	endcase
end

// Memory
// Address
always @(*) begin
    if (next_state == INPUT && in_valid) begin
        addr12 = in_cnt;
		addr21 = in_cnt;
    end
    else if (next_state == TAKE) begin
        addr12 = addr_save;
		addr21 = addr_save;
    end
    else if (next_state == SAVE) begin
        addr12 = addr_save;
		addr21 = addr_save;
    end
    else if (next_state == OUT) begin
        addr12 = out_cnt;
		addr21 = out_cnt;
    end
    else begin
        addr12 = 0;
        addr21 = 0;
    end
end
// Wen
always @(*) begin
    if (next_state == INPUT && in_valid) begin
        wen12 = 0;
        wen21 = 0;
    end
	else if (next_state == SAVE) begin
		wen12 = 0;
		wen21 = 0;
	end
	else if (next_state == OUT) begin
		wen12 = 1;
		wen21 = 1;
	end
	else begin
		wen12 = 1;
        wen21 = 1;
	end
end
// Input
always @(*) begin
    if(next_state == INPUT) begin
        in_data12 = in_x;
        in_data21 = {9'b0, in_y};
    end
	else if (next_state == SAVE) begin
		in_data12 = mag_reg[31:20];
		in_data21 = z_reg;
	end
	else begin
		in_data12 = 0;
        in_data21 = 0;
	end
end

// Input count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		in_cnt <= 0;
    else begin
		if (next_state == INPUT) begin
			in_cnt <= in_cnt + 1;
		end
		else if (next_state == IDLE) begin
			in_cnt <= 0;
		end 
	end
end


// Cal count
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cal_cnt <= 0;
	end
	else begin
		if (current_state == CAL) begin
			cal_cnt <= cal_cnt + 1;
		end
		else if (current_state == SAVE) begin
			cal_cnt <= 0;
		end
		else if (current_state == IDLE) begin
			cal_cnt <= 0;
		end
	end
end

// Addr save
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		addr_save <= 0;
	end
	else begin
		if (next_state == SAVE) begin
			addr_save <= addr_save + 1;
		end
		else if (next_state == IDLE) begin
			addr_save <= 0;
		end
	end
end


// Do
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		x_reg <= 0;
		y_reg <= 0;
		z_reg <= 0;
	end
	else begin
		if (current_state == TAKE) begin
			x_reg <= {out_data12[11], out_data12[11], out_data12[11:0], {6'b0}};
			y_reg <= {out_data21[11], out_data21[11], out_data21[11:0], {6'b0}};
			z_reg <= 0;
		end
		else if (current_state == ROTATE) begin
			if (x_reg[19] == 1) begin
				if(y_reg[19] == 1) begin
					x_reg <= x_reg * -1;
					y_reg <= y_reg * -1;
					z_reg[20] <= 1;
				end
				else begin
					x_reg <= y_reg;
					y_reg <= x_reg * -1;
					z_reg[19] <= 1;
				end
			end
			else begin
				if(y_reg[19] == 1) begin
					y_reg <= x_reg;
					x_reg <= y_reg * -1;
					z_reg[20] <= 1;
					z_reg[19] <= 1;
				end
			end
		end
		else if (current_state == CAL) begin
			if (y_reg[19] == 1) begin
				x_reg <= x_reg - (y_reg >>> cal_cnt);
				y_reg <= y_reg + (x_reg >> cal_cnt);
				z_reg <= z_reg - cordic_angle[cal_cnt];
			end
			else begin
				x_reg <= x_reg + (y_reg >>> cal_cnt);
				y_reg <= y_reg - (x_reg >> cal_cnt);
				z_reg <= z_reg + cordic_angle[cal_cnt];
			end
		end
		else if (current_state == IDLE) begin
			x_reg <= 0;
			y_reg <= 0;
			z_reg <= 0;
		end
	end
end

assign mag_reg = x_reg * Constant;

//Output count
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		out_cnt <= 0;
	end
    else if (next_state == OUT) begin
		out_cnt <= out_cnt + 1;
	end
	else if (next_state == IDLE) begin
		out_cnt <= 0;
	end
end

//Output
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		out_valid <= 0;
		out_mag <= 0;
		out_phase <= 0;
	end
    else if (current_state == OUT) begin
		out_valid <= 1;
		out_mag <= out_data12;
		out_phase <= out_data21;
	end
	else if (current_state == IDLE) begin
		out_valid <= 0;
		out_mag <= 0;
		out_phase <= 0;
	end
end

//12bits * 1024 SRAM
RA1SH_12 MEM_12(
   .Q(out_data12),
   .CLK(clk),
   .CEN(1'b0),
   .WEN(wen12),
   .A(addr12),
   .D(in_data12),
   .OEN(1'b0)
);
//21bits * 1024 SRAM
RA1SH_21 MEM_21(
   .Q(out_data21),
   .CLK(clk),
   .CEN(1'b0),
   .WEN(wen21),
   .A(addr21),
   .D(in_data21),
   .OEN(1'b0)
);

endmodule
