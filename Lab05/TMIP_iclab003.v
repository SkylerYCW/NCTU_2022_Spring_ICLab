module TMIP(
// input signals
    clk,
    rst_n,
    in_valid,
	in_valid_2,
    image,
	img_size,
    template, 
    action,
	
// output signals
    out_valid,
    out_x,
    out_y,
    out_img_pos,
    out_value
);

input        clk, rst_n, in_valid, in_valid_2;
input [15:0] image, template;
input [4:0]  img_size;
input [2:0]  action;

output reg        out_valid;
output reg [3:0]  out_x, out_y; 
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
parameter IDLE = 'd0;
parameter INPUT1 = 'd1;
parameter INPUT2 = 'd2;
parameter WAIT = 'd3;
parameter CROSS = 'd4;
parameter MAX = 'd5;
parameter HFLIP = 'd6;
parameter VFLIP = 'd7;
parameter LDFLIP = 'd8;
parameter RDFLIP = 'd9;
parameter ZOOM = 'd10;
parameter SHORT = 'd11;
parameter OUT = 'd12;


//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [3:0] current_state, next_state;

reg [7:0] input_img_cnt;
reg [4:0] img_size_s;

reg signed [15:0] template_s [0:8];
reg [3:0] input_tmp_cnt;
reg input_tmp_finish;

reg [2:0] action_s [0:15];
reg [3:0] input_act_cnt, do_act_cnt;

reg [8:0] addr_cnt1, addr_cnt2, addr_cnt3;
reg [8:0] addr_cross1, addr_cross2, addr_cross3;

reg mem1to2;

// Conv reg
reg signed [35:0] conv_reg_max;
reg [3:0] conv_max_x, conv_max_y;
reg [11:0] conv_cnt;
reg signed [15:0] cross_reg [0:38];

// Max pool reg
reg signed [15:0] max_reg;
reg [1:0] max_cnt;

// Max pool reg
reg signed [15:0] zoom_reg, zoom_reg_r;
reg [8:0] zoom_cnt;

// Shortcut reg
reg signed [15:0] short_reg, short_reg_r;
reg [6:0] short_cnt;

// Output count
reg [8:0] out_cnt;
reg signed [35:0] out_reg;
reg [3:0] out_tmp_cnt;

reg oper_finish;
reg out_finish;

integer i;

// SRAM reg & wire
reg signed [15:0] in_data1, in_data2;
reg signed [35:0] in_data3;
wire signed [15:0] out_data1, out_data2;
reg signed [15:0] out_data_r;
wire signed [35:0] out_data3;
reg [7:0] Addr1, Addr2, Addr3;
reg wen1, wen2, wen3;


SRAM1 MEM1(.Q(out_data1),.CLK(clk),.CEN(1'b0),.WEN(wen1),.A(Addr1),.D(in_data1),.OEN(1'b0));
SRAM1 MEM2(.Q(out_data2),.CLK(clk),.CEN(1'b0),.WEN(wen2),.A(Addr2),.D(in_data2),.OEN(1'b0));
SRAM2 MEM3(.Q(out_data3),.CLK(clk),.CEN(1'b0),.WEN(wen3),.A(Addr3),.D(in_data3),.OEN(1'b0));

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
			if (in_valid)	next_state = INPUT1;
			else 			next_state = current_state;
		end
		INPUT1: begin
			if (in_valid_2)   next_state = INPUT2;
			else            next_state = current_state;
		end
		INPUT2: begin
			if (!in_valid_2)   next_state = WAIT;
			else            next_state = current_state;
		end
		WAIT: begin
			case(action_s[do_act_cnt])
				0: next_state = CROSS;
				1: next_state = MAX;
				2: next_state = HFLIP;
				3: next_state = VFLIP;
				4: next_state = LDFLIP;
				5: next_state = RDFLIP;
				6: next_state = ZOOM;
				7: next_state = SHORT;
			endcase
		end
		CROSS: begin
			if (oper_finish)	next_state = OUT;
			else 			next_state = current_state;
		end
		MAX: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		HFLIP: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		VFLIP: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		LDFLIP: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		RDFLIP: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		ZOOM: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		SHORT: begin
			if (oper_finish)	next_state = WAIT;
			else 			next_state = current_state;
		end
		OUT: begin
			if (out_finish)		next_state = IDLE;
			else			next_state = current_state;
		end
		default:			next_state = current_state;
	endcase
end

// MEM1 & MEM2
// Addr1 & Addr2
always @(*) begin
    if (next_state == INPUT1 && in_valid) begin
        Addr1 = input_img_cnt;
		Addr2 = 0;
    end
    else if (next_state == MAX || next_state == HFLIP || next_state == VFLIP || next_state == LDFLIP || next_state == RDFLIP || next_state == ZOOM || next_state == SHORT) begin
		if (mem1to2) begin
			Addr1 = addr_cnt1;
			Addr2 = addr_cnt2;
		end
		else begin
			Addr1 = addr_cnt2;
			Addr2 = addr_cnt1;
		end
	end
	else if (next_state == CROSS) begin
		if (mem1to2) begin
			Addr1 = addr_cross1;
			Addr2 = addr_cross2;
		end
		else begin
			Addr1 = addr_cross2;
			Addr2 = addr_cross1;
		end
	end
    else begin
        Addr1 = 0;
        Addr2 = 0;
    end
end
// Addr3
always @(*) begin
	if (next_state == CROSS) begin
		Addr3 = addr_cross3;
	end
	else if (next_state == OUT) begin
		Addr3 = addr_cnt3;
	end
	else begin
		Addr3 = 0;
	end
end
// Wen1 & Wen2
always @(*) begin
    if (next_state == INPUT1 && in_valid) begin
        wen1 = 0;
        wen2 = 1;
    end
	else if (next_state == MAX || next_state == HFLIP || next_state == VFLIP || next_state == LDFLIP || next_state == RDFLIP || next_state == ZOOM || next_state == SHORT) begin
		if (mem1to2) begin
			wen1 = 1;
			wen2 = 0;
		end
		else begin
			wen1 = 0;
			wen2 = 1;
		end
	end
    else if (current_state == CROSS && !oper_finish) begin
		wen1 = 1;
		wen2 = 1;
	end
    else begin
        wen1 = 1;
        wen2 = 1;
    end
end
// Wen3
always @(*) begin
	if (current_state == CROSS && !oper_finish) begin
		wen3 = 0;
	end
	else begin
		wen3 = 1;
	end
end
// Input data1 & data2
always @(*) begin
    if(next_state == INPUT1) begin
        in_data1 = image;
        in_data2 = 0;
    end
    else if (next_state == HFLIP ||  next_state == VFLIP || next_state == LDFLIP || next_state == RDFLIP) begin
		if (mem1to2) begin
			in_data1 = 0;
			in_data2 = out_data1;
		end
		else begin
			in_data1 = out_data2;
			in_data2 = 0;
		end
	end
	else if (next_state == MAX) begin
		if (mem1to2) begin
			in_data1 = 0;
			in_data2 = max_reg;
		end
		else begin
			in_data1 = max_reg;
			in_data2 = 0;
		end
	end
	else if (next_state == SHORT) begin
		if (mem1to2) begin
			in_data1 = 0;
			in_data2 = short_reg_r;
		end
		else begin
			in_data1 = short_reg_r;
			in_data2 = 0;
		end
	end
	else if (next_state == ZOOM) begin
		if (mem1to2) begin
			in_data1 = 0;
			case (zoom_cnt%4)
				0: in_data2 = out_data1;
				1: in_data2 = out_data1 / 3;
				2: in_data2 = (out_data1 <<< 1) / 3 + 20;
				3: in_data2 = out_data1 >>> 1;
			endcase
		end
		else begin
			case (zoom_cnt%4)
				0: in_data1 = out_data2;
				1: in_data1 = out_data2 / 3;
				2: in_data1 = (out_data2 <<< 1) / 3 + 20;
				3: in_data1 = out_data2 >>> 1;
			endcase
			in_data2 = 0;
		end
	end
	else begin
		in_data1 = 0;
		in_data2 = 0;
	end
    
end
// Input data3
always @(*) begin
	in_data3 = 0;
	if (next_state == CROSS) begin
		case(img_size_s)
			4: in_data3 = 	cross_reg[0]*template_s[0] + cross_reg[1]*template_s[1] + cross_reg[2]*template_s[2] + 
							cross_reg[6]*template_s[3] + cross_reg[7]*template_s[4] + cross_reg[8]*template_s[5] + 
							cross_reg[12]*template_s[6] + cross_reg[13]*template_s[7] + cross_reg[14]*template_s[8];

			8: in_data3 = 	cross_reg[0]*template_s[0] + cross_reg[1]*template_s[1] + cross_reg[2]*template_s[2] + 
							cross_reg[10]*template_s[3] + cross_reg[11]*template_s[4] + cross_reg[12]*template_s[5] + 
							cross_reg[20]*template_s[6] + cross_reg[21]*template_s[7] + cross_reg[22]*template_s[8];

			16: in_data3 = 	cross_reg[0]*template_s[0] + cross_reg[1]*template_s[1] + cross_reg[2]*template_s[2] + 
							cross_reg[18]*template_s[3] + cross_reg[19]*template_s[4] + cross_reg[20]*template_s[5] + 
							cross_reg[36]*template_s[6] + cross_reg[37]*template_s[7] + cross_reg[38]*template_s[8];
		endcase
	end
end

// Input image count
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_img_cnt <= 0;
    end
    else begin
        if (next_state == INPUT1) begin
            input_img_cnt <= input_img_cnt + 1;
        end
		else if (next_state == IDLE) begin
			input_img_cnt <= 0;
		end
    end
end

// Input template and count
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_tmp_cnt <= 0;
        input_tmp_finish <= 0;
    end
    else begin
        if (next_state == INPUT1 && !input_tmp_finish) begin
			template_s[input_tmp_cnt] <= template;

            if (input_tmp_cnt == 8) begin
                input_tmp_cnt <= 0;
				input_tmp_finish <= 1;
            end
            else begin
                input_tmp_cnt <= input_tmp_cnt + 1;
            end
        end
		else if (next_state == IDLE) begin
			input_tmp_finish <= 0;
		end
    end
end

// Input action
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_act_cnt <= 0;
    end
    else begin
        if (next_state == INPUT2) begin
            action_s[input_act_cnt] <= action;
            input_act_cnt <= input_act_cnt + 1;
        end
        else if (next_state == IDLE) begin
			input_act_cnt <= 0;
        end
    end
end

// Cross reg
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		for (i = 0; i < 40; i = i + 1) begin
			cross_reg[i] <= 0;
		end
	end
	else begin
		if (current_state == CROSS) begin
			case (img_size_s)
				4: begin
					case (conv_cnt-1)
						0: begin
							if (mem1to2) begin
								cross_reg[7] <= out_data1;
							end
							else begin
								cross_reg[7] <= out_data2;
							end
						end
						1: begin
							if (mem1to2) begin
								cross_reg[8] <= out_data1;
							end
							else begin
								cross_reg[8] <= out_data2;
							end
						end
						2: begin
							if (mem1to2) begin
								cross_reg[9] <= out_data1;
							end
							else begin
								cross_reg[9] <= out_data2;
							end
						end
						3: begin
							if (mem1to2) begin
								cross_reg[10] <= out_data1;
							end
							else begin
								cross_reg[10] <= out_data2;
							end
						end
						4: begin
							if (mem1to2) begin
								cross_reg[13] <= out_data1;
							end
							else begin
								cross_reg[13] <= out_data2;
							end
						end
						5: begin
							if (mem1to2) begin
								cross_reg[14] <= out_data1;
							end
							else begin
								cross_reg[14] <= out_data2;
							end
						end
						8, 9, 14, 15: begin
							cross_reg[14] <= 0;

							for (i = 0; i < 14; i = i + 1) begin
								cross_reg[i] <= cross_reg[i+1];
							end
						end
						default: begin
							if (conv_cnt > 20) begin
								cross_reg[14] <= 0;

								for (i = 0; i < 14; i = i + 1) begin
									cross_reg[i] <= cross_reg[i+1];
								end
							end
							else begin
								if (mem1to2) begin
									cross_reg[14] <= out_data1;

									for (i = 0; i < 14; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
								else begin
									cross_reg[14] <= out_data2;

									for (i = 0; i < 14; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
							end
						end
					endcase
				end
				8: begin
					case (conv_cnt-1)
						0: begin
							if (mem1to2) begin
								cross_reg[11] <= out_data1;
							end
							else begin
								cross_reg[11] <= out_data2;
							end
						end
						1: begin
							if (mem1to2) begin
								cross_reg[12] <= out_data1;
							end
							else begin
								cross_reg[12] <= out_data2;
							end
						end
						2: begin
							if (mem1to2) begin
								cross_reg[13] <= out_data1;
							end
							else begin
								cross_reg[13] <= out_data2;
							end
						end
						3: begin
							if (mem1to2) begin
								cross_reg[14] <= out_data1;
							end
							else begin
								cross_reg[14] <= out_data2;
							end
						end
						4: begin
							if (mem1to2) begin
								cross_reg[15] <= out_data1;
							end
							else begin
								cross_reg[15] <= out_data2;
							end
						end
						5: begin
							if (mem1to2) begin
								cross_reg[16] <= out_data1;
							end
							else begin
								cross_reg[16] <= out_data2;
							end
						end
						6: begin
							if (mem1to2) begin
								cross_reg[17] <= out_data1;
							end
							else begin
								cross_reg[17] <= out_data2;
							end
						end
						7: begin
							if (mem1to2) begin
								cross_reg[18] <= out_data1;
							end
							else begin
								cross_reg[18] <= out_data2;
							end
						end
						8: begin
							if (mem1to2) begin
								cross_reg[21] <= out_data1;
							end
							else begin
								cross_reg[21] <= out_data2;
							end
						end
						9: begin
							if (mem1to2) begin
								cross_reg[22] <= out_data1;
							end
							else begin
								cross_reg[22] <= out_data2;
							end
						end
						16, 17, 26, 27, 36, 37, 46, 47, 56, 57, 66, 67: begin
							cross_reg[22] <= 0;

							for (i = 0; i < 22; i = i + 1) begin
								cross_reg[i] <= cross_reg[i+1];
							end
						end
						default: begin
							if (conv_cnt > 76) begin
								cross_reg[22] <= 0;

								for (i = 0; i < 22; i = i + 1) begin
									cross_reg[i] <= cross_reg[i+1];
								end
							end
							else begin
								if (mem1to2) begin
									cross_reg[22] <= out_data1;

									for (i = 0; i < 22; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
								else begin
									cross_reg[22] <= out_data2;

									for (i = 0; i < 22; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
							end
						end
					endcase
				end
				16: begin
					case (conv_cnt-1)
						0: begin
							if (mem1to2) begin
								cross_reg[19] <= out_data1;
							end
							else begin
								cross_reg[19] <= out_data2;
							end
						end
						1: begin
							if (mem1to2) begin
								cross_reg[20] <= out_data1;
							end
							else begin
								cross_reg[20] <= out_data2;
							end
						end
						2: begin
							if (mem1to2) begin
								cross_reg[21] <= out_data1;
							end
							else begin
								cross_reg[21] <= out_data2;
							end
						end
						3: begin
							if (mem1to2) begin
								cross_reg[22] <= out_data1;
							end
							else begin
								cross_reg[22] <= out_data2;
							end
						end
						4: begin
							if (mem1to2) begin
								cross_reg[23] <= out_data1;
							end
							else begin
								cross_reg[23] <= out_data2;
							end
						end
						5: begin
							if (mem1to2) begin
								cross_reg[24] <= out_data1;
							end
							else begin
								cross_reg[24] <= out_data2;
							end
						end
						6: begin
							if (mem1to2) begin
								cross_reg[25] <= out_data1;
							end
							else begin
								cross_reg[25] <= out_data2;
							end
						end
						7: begin
							if (mem1to2) begin
								cross_reg[26] <= out_data1;
							end
							else begin
								cross_reg[26] <= out_data2;
							end
						end
						8: begin
							if (mem1to2) begin
								cross_reg[27] <= out_data1;
							end
							else begin
								cross_reg[27] <= out_data2;
							end
						end
						9: begin
							if (mem1to2) begin
								cross_reg[28] <= out_data1;
							end
							else begin
								cross_reg[28] <= out_data2;
							end
						end
						10: begin
							if (mem1to2) begin
								cross_reg[29] <= out_data1;
							end
							else begin
								cross_reg[29] <= out_data2;
							end
						end
						11: begin
							if (mem1to2) begin
								cross_reg[30] <= out_data1;
							end
							else begin
								cross_reg[30] <= out_data2;
							end
						end
						12: begin
							if (mem1to2) begin
								cross_reg[31] <= out_data1;
							end
							else begin
								cross_reg[31] <= out_data2;
							end
						end
						13: begin
							if (mem1to2) begin
								cross_reg[32] <= out_data1;
							end
							else begin
								cross_reg[32] <= out_data2;
							end
						end
						14: begin
							if (mem1to2) begin
								cross_reg[33] <= out_data1;
							end
							else begin
								cross_reg[33] <= out_data2;
							end
						end
						15: begin
							if (mem1to2) begin
								cross_reg[34] <= out_data1;
							end
							else begin
								cross_reg[34] <= out_data2;
							end
						end
						16: begin
							if (mem1to2) begin
								cross_reg[37] <= out_data1;
							end
							else begin
								cross_reg[37] <= out_data2;
							end
						end
						17: begin
							if (mem1to2) begin
								cross_reg[38] <= out_data1;
							end
							else begin
								cross_reg[38] <= out_data2;
							end
						end
						32, 33, 50, 51, 68, 69, 86, 87, 104, 105, 122, 123, 140, 141, 158, 159, 176, 177, 194, 195, 212, 213, 230, 231, 248, 249, 266, 267: begin
							cross_reg[38] <= 0;

							for (i = 0; i < 38; i = i + 1) begin
								cross_reg[i] <= cross_reg[i+1];
							end
						end
						default: begin
							if (conv_cnt > 284) begin
								cross_reg[38] <= 0;

								for (i = 0; i < 38; i = i + 1) begin
									cross_reg[i] <= cross_reg[i+1];
								end
							end
							else begin
								if (mem1to2) begin
									cross_reg[38] <= out_data1;

									for (i = 0; i < 38; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
								else begin
									cross_reg[38] <= out_data2;

									for (i = 0; i < 38; i = i + 1) begin
										cross_reg[i] <= cross_reg[i+1];
									end
								end
							end
						end
					endcase
				end
			endcase
		end
		else if (current_state == IDLE) begin
			for (i = 0; i < 40; i = i + 1) begin
				cross_reg[i] <= 0;
			end
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		addr_cross1 <= 0;
	end
	else begin
		if (next_state == CROSS) begin
			if (conv_cnt < img_size_s + 2) begin
				addr_cross1 <= addr_cross1 + 1;
			end
			else begin
				case (img_size_s)
					4: begin
						if (conv_cnt%6 != 2 && conv_cnt%6 != 3) begin
							addr_cross1 <= addr_cross1 + 1;
						end
					end
					8: begin
						if (conv_cnt%10 != 6 && conv_cnt%10 != 7) begin
							addr_cross1 <= addr_cross1 + 1;
						end
					end
					16: begin
						if (conv_cnt%18 != 14 && conv_cnt%18 != 15) begin
							addr_cross1 <= addr_cross1 + 1;
						end
					end
				endcase
			end
		end
		else if (next_state == IDLE) begin
			addr_cross1 <= 0;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		addr_cross3 <= 0;
	end
	else begin
		addr_cross3 <= addr_cross2;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		conv_max_x <= 0;
		conv_max_y <= 0;
		conv_reg_max <= {1'b1, 35'b0};
	end
	else if (current_state == IDLE) begin
		conv_max_x <= 0;
		conv_max_y <= 0;
		conv_reg_max <= {1'b1, 35'b0};
	end
	else if (current_state == CROSS && !oper_finish) begin
		case (img_size_s)
			4: begin
				if ($signed(in_data3) > $signed(conv_reg_max) && conv_cnt > 6 && !(conv_cnt%6 == 0 || conv_cnt%6 == 5)) begin
					conv_reg_max <= in_data3;
					conv_max_x <= addr_cross3 >>> 2;
					conv_max_y <= addr_cross3 % 4;
				end
			end
			8: begin
				if ($signed(in_data3) > $signed(conv_reg_max) && conv_cnt > 10 && !(conv_cnt%10 == 0 || conv_cnt%10 == 9)) begin
					conv_reg_max <= in_data3;
					conv_max_x <= addr_cross3 >>> 3;
					conv_max_y <= addr_cross3 % 8;
				end
			end
			16: begin
				if ($signed(in_data3) > $signed(conv_reg_max) && conv_cnt > 18 && !(conv_cnt%18 == 0 || conv_cnt%18 == 17)) begin
					conv_reg_max <= in_data3;
					conv_max_x <= addr_cross3 >>> 4;
					conv_max_y <= addr_cross3 % 16;
				end
			end
		endcase
	end
end

// Do action addr1 & addr2 & count & image size
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        do_act_cnt <= 0;
        addr_cnt1 <= 0;
        addr_cnt2 <= 0;
		
		oper_finish <= 0;

        img_size_s <= 0;
        mem1to2 <= 1;
		
		max_cnt <= 0;
		zoom_cnt <= 0;
		short_cnt <= 0;
		conv_cnt <= 0;
		
		

		addr_cross2 <= 0;
    end
    else begin
        if (next_state == INPUT1) begin
            if (input_tmp_cnt == 0 && !input_tmp_finish) begin
                img_size_s <= img_size;
            end
        end
        
		if (next_state == CROSS) begin    // Cross Correlation
			conv_cnt <= conv_cnt + 1;

			case (img_size_s)
				4: begin
					case (conv_cnt)
						6, 7, 8, 12, 13, 14, 18, 19, 20, 24, 25, 26: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						9, 15, 21, 27: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						28: begin
							oper_finish <= 1;
						end
					endcase
				end
				8: begin
					case (conv_cnt)
						10, 11, 12, 13, 14, 15, 16, 20, 21, 22, 23, 24, 25, 26, 30, 31, 32, 33, 34, 35, 36, 40, 41, 42, 43, 44, 45, 46, 
						50, 51, 52, 53, 54, 55, 56, 60, 61, 62, 63, 64, 65, 66, 70, 71, 72, 73, 74, 75, 76, 80, 81, 82, 83, 84, 85, 86: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						17, 27, 37, 47, 57, 67, 77, 87: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						88: begin
							oper_finish <= 1;
						end
					endcase
				end
				16: begin
					case (conv_cnt)
						18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 
						36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
						54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 
						72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 
						90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 
						108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
						126, 127, 128, 129, 130 ,131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 
						144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 
						162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 
						180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 
						198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 
						216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 
						234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 
						252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 
						270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 
						288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						33, 51, 69, 87, 105, 123, 141, 159, 177, 195, 213, 231, 249, 267, 285, 303: begin
							addr_cross2 <= addr_cross2 + 1;
						end
						304: begin
							oper_finish <= 1;
						end
					endcase
				end
			endcase
		end
        else if (next_state == MAX) begin    // Max pooling
			if (max_cnt == 3) begin
				max_cnt <= 0;
			end
			else begin
				max_cnt <= max_cnt + 1;	// can only keep this
			end
			
			case (img_size_s)
				4: begin
					do_act_cnt <= do_act_cnt + 1;
					oper_finish <= 1;
				end
				8: begin
					if (mem1to2) begin
						if (max_cnt == 1) begin
							max_reg <= out_data1;
						end
						else begin
							if (out_data1 > max_reg) begin
								max_reg <= out_data1;
							end
						end
					end
					else begin
						if (max_cnt == 1) begin
							max_reg <= out_data2;
						end
						else begin
							if (out_data2 > max_reg) begin
								max_reg <= out_data2;
							end
						end
					end
					
					if (max_cnt == 0 || max_cnt == 2) begin
						addr_cnt1 <= addr_cnt1 + 1;
					end
					else if (max_cnt == 1) begin
						addr_cnt1 <= addr_cnt1 + 7;
						
						if (addr_cnt1 == 1) begin
							addr_cnt2 <= 0;
						end
						else if (addr_cnt1 == 65) begin		// Finish
							do_act_cnt <= do_act_cnt + 1;
							img_size_s <= 4;
							oper_finish <= 1;
							
							if (mem1to2) begin
								mem1to2 <= 0;
							end
							else begin
								mem1to2 <= 1;
							end
						end
						else begin
							addr_cnt2 <= addr_cnt2 + 1;
						end
					end
					else if (max_cnt == 3) begin
						if (addr_cnt1 % 16 == 15) begin
							addr_cnt1 <= addr_cnt1 + 1;
						end
						else begin
							addr_cnt1 <= addr_cnt1 - 7;
						end
					end
				end
				16: begin
					if (mem1to2) begin
						if (max_cnt == 1) begin
							max_reg <= out_data1;
						end
						else begin
							if (out_data1 > max_reg) begin
								max_reg <= out_data1;
							end
						end
					end
					else begin
						if (max_cnt == 1) begin
							max_reg <= out_data2;
						end
						else begin
							if (out_data2 > max_reg) begin
								max_reg <= out_data2;
							end
						end
					end
					
					if (max_cnt == 0 || max_cnt == 2) begin
						addr_cnt1 <= addr_cnt1 + 1;
					end
					else if (max_cnt == 1) begin
						addr_cnt1 <= addr_cnt1 + 15;
						
						if (addr_cnt1 == 1) begin
							addr_cnt2 <= 0;
						end
						else if (addr_cnt1 == 257) begin		// Finish
							do_act_cnt <= do_act_cnt + 1;
							img_size_s <= 8;
							oper_finish <= 1;
							
							if (mem1to2) begin
								mem1to2 <= 0;
							end
							else begin
								mem1to2 <= 1;
							end
						end
						else begin
							addr_cnt2 <= addr_cnt2 + 1;
						end
					end
					else if (max_cnt == 3) begin
						if (addr_cnt1 % 32 == 31) begin
							addr_cnt1 <= addr_cnt1 + 1;
						end
						else begin
							addr_cnt1 <= addr_cnt1 - 15;
						end
					end
				end
			endcase
		end
        else if (next_state == HFLIP) begin    // Horizontal Flip
			case (img_size_s)
				4: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 3;
					end
					else if (addr_cnt1 == 4) begin
						addr_cnt2 <= 7;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 11;
					end
					else if (addr_cnt1 == 12) begin
						addr_cnt2 <= 15;
					end
					else if (addr_cnt1 == 16) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 1;
					end
				end
				8: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 7;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 15;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 23;
					end
					else if (addr_cnt1 == 24) begin
						addr_cnt2 <= 31;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 39;
					end
					else if (addr_cnt1 == 40) begin
						addr_cnt2 <= 47;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 55;
					end
					else if (addr_cnt1 == 56) begin
						addr_cnt2 <= 63;
					end
					else if (addr_cnt1 == 64) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 1;
					end
				end
				16: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 15;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 31;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 47;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 63;
					end
					else if (addr_cnt1 == 64) begin
						addr_cnt2 <= 79;
					end
					else if (addr_cnt1 == 80) begin
						addr_cnt2 <= 95;
					end
					else if (addr_cnt1 == 96) begin
						addr_cnt2 <= 111;
					end
					else if (addr_cnt1 == 112) begin
						addr_cnt2 <= 127;
					end
					else if (addr_cnt1 == 128) begin
						addr_cnt2 <= 143;
					end
					else if (addr_cnt1 == 144) begin
						addr_cnt2 <= 159;
					end
					else if (addr_cnt1 == 160) begin
						addr_cnt2 <= 175;
					end
					else if (addr_cnt1 == 176) begin
						addr_cnt2 <= 191;
					end
					else if (addr_cnt1 == 192) begin
						addr_cnt2 <= 207;
					end
					else if (addr_cnt1 == 208) begin
						addr_cnt2 <= 223;
					end
					else if (addr_cnt1 == 224) begin
						addr_cnt2 <= 239;
					end
					else if (addr_cnt1 == 240) begin
						addr_cnt2 <= 255;
					end
					else if (addr_cnt1 == 256) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 1;
					end
				end
			endcase
		end
        else if (next_state == VFLIP) begin    // Vertical Flip
			case (img_size_s)
				4: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 12;
					end
					else if (addr_cnt1 == 4) begin
						addr_cnt2 <= 8;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 4;
					end
					else if (addr_cnt1 == 12) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 16) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
				end
				8: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 56;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 48;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 40;
					end
					else if (addr_cnt1 == 24) begin
						addr_cnt2 <= 32;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 24;
					end
					else if (addr_cnt1 == 40) begin
						addr_cnt2 <= 16;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 8;
					end
					else if (addr_cnt1 == 56) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 64) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
				end
				16: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 240;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 224;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 208;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 192;
					end
					else if (addr_cnt1 == 64) begin
						addr_cnt2 <= 176;
					end
					else if (addr_cnt1 == 80) begin
						addr_cnt2 <= 160;
					end
					else if (addr_cnt1 == 96) begin
						addr_cnt2 <= 144;
					end
					else if (addr_cnt1 == 112) begin
						addr_cnt2 <= 128;
					end
					else if (addr_cnt1 == 128) begin
						addr_cnt2 <= 112;
					end
					else if (addr_cnt1 == 144) begin
						addr_cnt2 <= 96;
					end
					else if (addr_cnt1 == 160) begin
						addr_cnt2 <= 80;
					end
					else if (addr_cnt1 == 176) begin
						addr_cnt2 <= 64;
					end
					else if (addr_cnt1 == 192) begin
						addr_cnt2 <= 48;
					end
					else if (addr_cnt1 == 208) begin
						addr_cnt2 <= 32;
					end
					else if (addr_cnt1 == 224) begin
						addr_cnt2 <= 16;
					end
					else if (addr_cnt1 == 240) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 256) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
				end
			endcase
		end
        else if (next_state == LDFLIP) begin    // Left diagonal Flip
			case (img_size_s)
				4: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 15;
					end
					else if (addr_cnt1 == 4) begin
						addr_cnt2 <= 14;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 13;
					end
					else if (addr_cnt1 == 12) begin
						addr_cnt2 <= 12;
					end
					else if (addr_cnt1 == 16) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 4;
					end
				end
				8: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 63;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 62;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 61;
					end
					else if (addr_cnt1 == 24) begin
						addr_cnt2 <= 60;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 59;
					end
					else if (addr_cnt1 == 40) begin
						addr_cnt2 <= 58;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 57;
					end
					else if (addr_cnt1 == 56) begin
						addr_cnt2 <= 56;
					end
					else if (addr_cnt1 == 64) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 8;
					end
				end
				16: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 255;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 254;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 253;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 252;
					end
					else if (addr_cnt1 == 64) begin
						addr_cnt2 <= 251;
					end
					else if (addr_cnt1 == 80) begin
						addr_cnt2 <= 250;
					end
					else if (addr_cnt1 == 96) begin
						addr_cnt2 <= 249;
					end
					else if (addr_cnt1 == 112) begin
						addr_cnt2 <= 248;
					end
					else if (addr_cnt1 == 128) begin
						addr_cnt2 <= 247;
					end
					else if (addr_cnt1 == 144) begin
						addr_cnt2 <= 246;
					end
					else if (addr_cnt1 == 160) begin
						addr_cnt2 <= 245;
					end
					else if (addr_cnt1 == 176) begin
						addr_cnt2 <= 244;
					end
					else if (addr_cnt1 == 192) begin
						addr_cnt2 <= 243;
					end
					else if (addr_cnt1 == 208) begin
						addr_cnt2 <= 242;
					end
					else if (addr_cnt1 == 224) begin
						addr_cnt2 <= 241;
					end
					else if (addr_cnt1 == 240) begin
						addr_cnt2 <= 240;
					end
					else if (addr_cnt1 == 256) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 - 16;
					end
				end
			endcase
		end
        else if (next_state == RDFLIP) begin    // Right diagonal Flip
			case (img_size_s)
				4: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 4) begin
						addr_cnt2 <= 1;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 2;
					end
					else if (addr_cnt1 == 12) begin
						addr_cnt2 <= 3;
					end
					else if (addr_cnt1 == 16) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 4;
					end
				end
				8: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 8) begin
						addr_cnt2 <= 1;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 2;
					end
					else if (addr_cnt1 == 24) begin
						addr_cnt2 <= 3;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 4;
					end
					else if (addr_cnt1 == 40) begin
						addr_cnt2 <= 5;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 6;
					end
					else if (addr_cnt1 == 56) begin
						addr_cnt2 <= 7;
					end
					else if (addr_cnt1 == 64) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 8;
					end
				end
				16: begin
					addr_cnt1 <= addr_cnt1 + 1;
					if (addr_cnt1 == 0) begin
						addr_cnt2 <= 0;
					end
					else if (addr_cnt1 == 16) begin
						addr_cnt2 <= 1;
					end
					else if (addr_cnt1 == 32) begin
						addr_cnt2 <= 2;
					end
					else if (addr_cnt1 == 48) begin
						addr_cnt2 <= 3;
					end
					else if (addr_cnt1 == 64) begin
						addr_cnt2 <= 4;
					end
					else if (addr_cnt1 == 80) begin
						addr_cnt2 <= 5;
					end
					else if (addr_cnt1 == 96) begin
						addr_cnt2 <= 6;
					end
					else if (addr_cnt1 == 112) begin
						addr_cnt2 <= 7;
					end
					else if (addr_cnt1 == 128) begin
						addr_cnt2 <= 8;
					end
					else if (addr_cnt1 == 144) begin
						addr_cnt2 <= 9;
					end
					else if (addr_cnt1 == 160) begin
						addr_cnt2 <= 10;
					end
					else if (addr_cnt1 == 176) begin
						addr_cnt2 <= 11;
					end
					else if (addr_cnt1 == 192) begin
						addr_cnt2 <= 12;
					end
					else if (addr_cnt1 == 208) begin
						addr_cnt2 <= 13;
					end
					else if (addr_cnt1 == 224) begin
						addr_cnt2 <= 14;
					end
					else if (addr_cnt1 == 240) begin
						addr_cnt2 <= 15;
					end
					else if (addr_cnt1 == 256) begin
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;

						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
					else begin
						addr_cnt2 <= addr_cnt2 + 16;
					end
				end
			endcase
		end
        else if (next_state == ZOOM) begin    // Zoom in
			zoom_cnt <= zoom_cnt + 1;
			
			case (img_size_s)
				4: begin
					if (zoom_cnt%4 == 0) begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (zoom_cnt%4 == 1) begin
						addr_cnt2 <= addr_cnt2 + 7;
					end
					else if (zoom_cnt%4 == 2) begin
						addr_cnt1 <= addr_cnt1 + 1;
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (zoom_cnt%4 == 3) begin
						if (addr_cnt2 % 16 == 15) begin
							addr_cnt2 <= addr_cnt2 + 1;
						end
						else begin
							addr_cnt2 <= addr_cnt2 - 7;
						end
					end

					if (addr_cnt2 == 63) begin		// Finish
						do_act_cnt <= do_act_cnt + 1;
						img_size_s <= 8;
						oper_finish <= 1;
						
						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
				end
				8: begin
					if (zoom_cnt%4 == 0) begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (zoom_cnt%4 == 1) begin
						addr_cnt2 <= addr_cnt2 + 15;
					end
					else if (zoom_cnt%4 == 2) begin
						addr_cnt1 <= addr_cnt1 + 1;
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (zoom_cnt%4 == 3) begin
						if (addr_cnt2 % 32 == 31) begin
							addr_cnt2 <= addr_cnt2 + 1;
						end
						else begin
							addr_cnt2 <= addr_cnt2 - 15;
						end
					end

					if (addr_cnt2 == 255) begin		// Finish
						do_act_cnt <= do_act_cnt + 1;
						img_size_s <= 16;
						oper_finish <= 1;
						
						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
				end
				16: begin
					do_act_cnt <= do_act_cnt + 1;
					oper_finish <= 1;
				end
			endcase
		end
        else if (next_state == SHORT) begin
			short_cnt <= short_cnt + 1;
			
			case (img_size_s)
				4: begin
					if (mem1to2) begin
						short_reg <= out_data1;
					end
					else begin
						short_reg <= out_data2;
					end
					
					short_reg_r <= (short_reg >> 1) + 50;
					
					addr_cnt1 <= addr_cnt1 + 1;
					
					if (short_cnt > 2 && short_cnt < 18) begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (short_cnt == 18) begin		// Finish
						do_act_cnt <= do_act_cnt + 1;
						oper_finish <= 1;
						
						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
				end
				8: begin
					if (mem1to2) begin
						short_reg <= out_data1;
					end
					else begin
						short_reg <= out_data2;
					end
					
					short_reg_r <= (short_reg >> 1) + 50;
					
					if (addr_cnt1 == 0) begin
						addr_cnt1 <= 18;
					end
					else if (addr_cnt1 == 21 || addr_cnt1 == 29 || addr_cnt1 == 37) begin
						addr_cnt1 <= addr_cnt1 + 5;
					end
					else begin
						addr_cnt1 <= addr_cnt1 + 1;
					end
					
					
					if (short_cnt > 3 && short_cnt < 19) begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (short_cnt == 19) begin		// Finish
						do_act_cnt <= do_act_cnt + 1;
						img_size_s <= 4;
						oper_finish <= 1;
						
						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
				end
				16: begin
					if (mem1to2) begin
						short_reg <= out_data1;
					end
					else begin
						short_reg <= out_data2;
					end
					
					short_reg_r <= (short_reg >> 1) + 50;
					
					if (addr_cnt1 == 0) begin
						addr_cnt1 <= 68;
					end
					else if (addr_cnt1 == 75 || addr_cnt1 == 91 || addr_cnt1 == 107 || addr_cnt1 == 123 || addr_cnt1 == 139 || addr_cnt1 == 155 || addr_cnt1 == 171) begin
						addr_cnt1 <= addr_cnt1 + 9;
					end
					else begin
						addr_cnt1 <= addr_cnt1 + 1;
					end
					
					
					if (short_cnt > 3 && short_cnt < 67) begin
						addr_cnt2 <= addr_cnt2 + 1;
					end
					else if (short_cnt == 67) begin		// Finish
						do_act_cnt <= do_act_cnt + 1;
						img_size_s <= 8;
						oper_finish <= 1;
						
						if (mem1to2) begin
							mem1to2 <= 0;
						end
						else begin
							mem1to2 <= 1;
						end
					end
				end
			endcase
		end
		else if (next_state == WAIT) begin
			oper_finish <= 0;
			addr_cnt1 <= 0;
			addr_cnt2 <= 0;
			short_cnt <= 0;
			max_cnt <= 0;
			zoom_cnt <= 0;
		end
		else if (next_state == IDLE) begin
			oper_finish <= 0;
			do_act_cnt <= 0;
			addr_cnt1 <= 0;
			addr_cnt2 <= 0;
			addr_cross2 <= 0;
			
			short_cnt <= 0;
			conv_cnt <= 0;
			mem1to2 <= 1;
			
			max_cnt <= 0;
			zoom_cnt <= 0;
		end
    end
end

// Output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        out_x <= 0;
        out_y <= 0;
        out_img_pos <= 0;
        out_value <= 0;
		
		out_cnt <= 0;
		out_tmp_cnt <= 0;
		addr_cnt3 <= 0;
		out_reg <= 0;
		out_finish <= 0;
    end
	else begin
		if (next_state == OUT) begin
			
			addr_cnt3 <= addr_cnt3 + 1;
			out_cnt <= out_cnt + 1;
			out_reg <= out_data3;
			if (out_cnt > 1 && out_cnt < img_size_s*img_size_s+2) begin
				out_value <= out_reg;
				if (out_cnt == 2) begin
					out_valid <= 1;
					out_x <= conv_max_x;
					out_y <= conv_max_y;
				end
				else if (out_cnt == img_size_s*img_size_s+1) begin
					out_finish <= 1;
				end
			end
			else begin
				out_value <= 0;
			end
			
			
			if (conv_max_x == 0) begin
				if (conv_max_y == 0) begin
					out_tmp_cnt <= 4;
				end
				else if (conv_max_y == img_size_s - 1) begin
					out_tmp_cnt <= 4;
				end
				else begin
					out_tmp_cnt <= 6;
				end
			end
			else if (conv_max_x == img_size_s - 1) begin
				if (conv_max_y == 0) begin
					out_tmp_cnt <= 4;
				end
				else if (conv_max_y == img_size_s - 1) begin
					out_tmp_cnt <= 4;
				end
				else begin
					out_tmp_cnt <= 6;
				end
			end
			else begin
				if (conv_max_y == 0) begin
					out_tmp_cnt <= 6;
				end
				else if (conv_max_y == img_size_s - 1) begin
					out_tmp_cnt <= 6;
				end
				else begin
					out_tmp_cnt <= 9;
				end
			end
			

			// Output out_img_pos
			if (out_cnt > 1 && out_cnt < out_tmp_cnt + 2) begin
				if (out_cnt == 2) begin
					if (conv_max_x == 0) begin
						if (conv_max_y == 0) begin
							out_img_pos <= 0;
						end
						else if (conv_max_y == img_size_s - 1) begin
							out_img_pos <= img_size_s - 2;
						end
						else begin
							out_img_pos <= conv_max_y - 1;
						end
					end
					else if (conv_max_x == img_size_s - 1) begin
						if (conv_max_y == 0) begin
							out_img_pos <= img_size_s*(conv_max_x - 1);
						end
						else if (conv_max_y == img_size_s - 1) begin
							out_img_pos <= img_size_s*(conv_max_x) - 2;
						end
						else begin
							out_img_pos <= img_size_s*(conv_max_x - 1) + conv_max_y - 1;///////////////////
						end
					end
					else begin
						if (conv_max_y == 0) begin
							out_img_pos <= (conv_max_x-1)*img_size_s;
						end
						else if (conv_max_y == img_size_s - 1) begin
							out_img_pos <= (conv_max_x)*img_size_s - 2;
						end
						else begin
							out_img_pos <= (conv_max_x-1)*img_size_s + conv_max_y-1;
						end
					end
				end
				else begin
					case (out_tmp_cnt)
						4: begin
							if (out_cnt == 3) begin
								out_img_pos <= out_img_pos + 1;
							end
							else if (out_cnt == 4) begin
								out_img_pos <= out_img_pos + img_size_s - 1;
							end
							else begin
								out_img_pos <= out_img_pos + 1;
							end
						end
						6: begin
							if (conv_max_y == 0 || conv_max_y == img_size_s - 1) begin
								if (out_cnt == 3) begin
									out_img_pos <= out_img_pos + 1;
								end
								else if (out_cnt == 4) begin
									out_img_pos <= out_img_pos + img_size_s - 1;
								end
								else if (out_cnt == 5) begin
									out_img_pos <= out_img_pos + 1;
								end
								else if (out_cnt == 6) begin
									out_img_pos <= out_img_pos + img_size_s - 1;
								end
								else begin
									out_img_pos <= out_img_pos + 1;
								end
							end
							else begin
								if (out_cnt == 3) begin
									out_img_pos <= out_img_pos + 1;
								end
								else if (out_cnt == 4) begin
									out_img_pos <= out_img_pos + 1;
								end
								else if (out_cnt == 5) begin
									out_img_pos <= out_img_pos + img_size_s - 2;
								end
								else if (out_cnt == 6) begin
									out_img_pos <= out_img_pos + 1;
								end
								else begin
									out_img_pos <= out_img_pos + 1;
								end
							end
						end
						9: begin
							if (out_cnt == 3) begin
								out_img_pos <= out_img_pos + 1;
							end
							else if (out_cnt == 4) begin
								out_img_pos <= out_img_pos + 1;
							end
							else if (out_cnt == 5) begin
								out_img_pos <= out_img_pos + img_size_s - 2;
							end
							else if (out_cnt == 6) begin
								out_img_pos <= out_img_pos + 1;
							end
							else if (out_cnt == 7) begin
								out_img_pos <= out_img_pos + 1;
							end
							else if (out_cnt == 8) begin
								out_img_pos <= out_img_pos + img_size_s - 2;
							end
							else if (out_cnt == 9) begin
								out_img_pos <= out_img_pos + 1;
							end
							else begin
								out_img_pos <= out_img_pos + 1;
							end
						end
					endcase
				end
			end
			else begin
				out_img_pos <= 0;
			end
		end
		else if (next_state == IDLE) begin
			out_finish <= 0;
			out_cnt <= 0;
			addr_cnt3 <= 0;
			out_valid <= 0;
			out_value <= 0;
			out_reg <= 0;
			out_x <= 0;
			out_y <= 0;
		end
	end
end

endmodule
