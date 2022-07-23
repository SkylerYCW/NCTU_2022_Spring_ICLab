module NN(
	// Input signals
	clk,
	rst_n,
	in_valid_i,
	in_valid_k,
	in_valid_o,
	Image1,
	Image2,
	Image3,
	Kernel1,
	Kernel2,
	Kernel3,
	Opt,
	// Output signals
	out_valid,
	out
);
//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;
parameter inst_arch = 2;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [inst_sig_width+inst_exp_width:0] Image1, Image2, Image3;
input [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [2:0] current_state, next_state;
integer i, j;

reg [inst_sig_width+inst_exp_width:0] image [0:2][0:5][0:5];
reg [2:0] image_cnt1;
reg [2:0] image_cnt2;

reg [inst_sig_width+inst_exp_width:0] kernel1 [0:3][0:8];
reg [inst_sig_width+inst_exp_width:0] kernel2 [0:3][0:8];
reg [inst_sig_width+inst_exp_width:0] kernel3 [0:3][0:8];
reg [3:0] ker_cnt1;
reg [3:0] ker_cnt2;

reg [1:0] opt_data;

reg ker_start;
reg ker_start_flag1, ker_start_flag2, ker_start_flag3, ker_start_flag4;

reg [1:0] cal_cntr, cal_cntc;
reg [1:0] cal_ker;

// Use for designware
reg [inst_sig_width+inst_exp_width:0] kernel11 [0:2][0:2], kernel22 [0:2][0:2], kernel33 [0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] image11 [0:2][0:2], image22 [0:2][0:2], image33 [0:2][0:2];
wire [inst_sig_width+inst_exp_width:0] out11 [0:2][0:2], out22 [0:2][0:2], out33 [0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] in11 [0:2][0:2], in22 [0:2][0:2], in33 [0:2][0:2];
reg [inst_sig_width+inst_exp_width:0] out111 [0:2][0:2], out222 [0:2][0:2], out333 [0:2][0:2];

wire [inst_sig_width+inst_exp_width:0] out_sum27;

reg [inst_sig_width+inst_exp_width:0] input_data1, input_data2, input_data3, input_data4;
reg [inst_sig_width+inst_exp_width:0] input_data11, input_data22, input_data33, input_data441, input_data442;
wire [inst_sig_width+inst_exp_width:0] output_data1, output_data2, output_data3, output_data41, output_data42;
reg [inst_sig_width+inst_exp_width:0] output_data11, output_data22;
wire [inst_sig_width+inst_exp_width:0] output_data33, output_data44;

// DesignWare

DW_fp_conv27 CONV(
	.kernel000(kernel11[0][0]), .kernel001(kernel11[0][1]), .kernel002(kernel11[0][2]), .kernel010(kernel11[1][0]), .kernel011(kernel11[1][1]), .kernel012(kernel11[1][2]), .kernel020(kernel11[2][0]), .kernel021(kernel11[2][1]), .kernel022(kernel11[2][2]),
	.kernel100(kernel22[0][0]), .kernel101(kernel22[0][1]), .kernel102(kernel22[0][2]), .kernel110(kernel22[1][0]), .kernel111(kernel22[1][1]), .kernel112(kernel22[1][2]), .kernel120(kernel22[2][0]), .kernel121(kernel22[2][1]), .kernel122(kernel22[2][2]),
	.kernel200(kernel33[0][0]), .kernel201(kernel33[0][1]), .kernel202(kernel33[0][2]), .kernel210(kernel33[1][0]), .kernel211(kernel33[1][1]), .kernel212(kernel33[1][2]), .kernel220(kernel33[2][0]), .kernel221(kernel33[2][1]), .kernel222(kernel33[2][2]),
	.ima000(image11[0][0]), .ima001(image11[0][1]), .ima002(image11[0][2]), .ima010(image11[1][0]), .ima011(image11[1][1]), .ima012(image11[1][2]), .ima020(image11[2][0]), .ima021(image11[2][1]), .ima022(image11[2][2]),
	.ima100(image22[0][0]), .ima101(image22[0][1]), .ima102(image22[0][2]), .ima110(image22[1][0]), .ima111(image22[1][1]), .ima112(image22[1][2]), .ima120(image22[2][0]), .ima121(image22[2][1]), .ima122(image22[2][2]),
	.ima200(image33[0][0]), .ima201(image33[0][1]), .ima202(image33[0][2]), .ima210(image33[1][0]), .ima211(image33[1][1]), .ima212(image33[1][2]), .ima220(image33[2][0]), .ima221(image33[2][1]), .ima222(image33[2][2]),
	.out000(out11[0][0]), .out001(out11[0][1]), .out002(out11[0][2]), .out010(out11[1][0]), .out011(out11[1][1]), .out012(out11[1][2]), .out020(out11[2][0]), .out021(out11[2][1]), .out022(out11[2][2]),
	.out100(out22[0][0]), .out101(out22[0][1]), .out102(out22[0][2]), .out110(out22[1][0]), .out111(out22[1][1]), .out112(out22[1][2]), .out120(out22[2][0]), .out121(out22[2][1]), .out122(out22[2][2]),
	.out200(out33[0][0]), .out201(out33[0][1]), .out202(out33[0][2]), .out210(out33[1][0]), .out211(out33[1][1]), .out212(out33[1][2]), .out220(out33[2][0]), .out221(out33[2][1]), .out222(out33[2][2])
);

DW_fp_sum27 Sum27(
	.in000(in11[0][0]), .in001(in11[0][1]), .in002(in11[0][2]), .in010(in11[1][0]), .in011(in11[1][1]), .in012(in11[1][2]), .in020(in11[2][0]), .in021(in11[2][1]), .in022(in11[2][2]),
	.in100(in22[0][0]), .in101(in22[0][1]), .in102(in22[0][2]), .in110(in22[1][0]), .in111(in22[1][1]), .in112(in22[1][2]), .in120(in22[2][0]), .in121(in22[2][1]), .in122(in22[2][2]),
	.in200(in33[0][0]), .in201(in33[0][1]), .in202(in33[0][2]), .in210(in33[1][0]), .in211(in33[1][1]), .in212(in33[1][2]), .in220(in33[2][0]), .in221(in33[2][1]), .in222(in33[2][2]),
	.out_sum(out_sum27)
);

// Input opt
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		opt_data <= 0;
    else begin
		if (in_valid_o) begin
			opt_data <= Opt;
		end
	end
end

// Input image
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		image_cnt1 <= 1;
		image_cnt2 <= 1;
	end
    else begin
		if (in_valid_i) begin
			image[0][image_cnt1][image_cnt2] <= Image1;
			image[1][image_cnt1][image_cnt2] <= Image2;
			image[2][image_cnt1][image_cnt2] <= Image3;
		
			if (image_cnt2 == 4) begin
				image_cnt2 <= 1;
				image_cnt1 <= image_cnt1 + 1;
			end
			else begin
				image_cnt2 <= image_cnt2 + 1;
			end
		end
		if (image_cnt1 == 5) begin
			case(opt_data)
				2'b00: begin
					image[0][0][0] <= image[0][1][1];
					image[0][0][1] <= image[0][1][1];
					image[0][0][2] <= image[0][1][2];
					image[0][0][3] <= image[0][1][3];
					image[0][0][4] <= image[0][1][4];
					image[0][0][5] <= image[0][1][4];
					image[0][1][0] <= image[0][1][1];
					image[0][1][5] <= image[0][1][4];
					image[0][2][0] <= image[0][2][1];
					image[0][2][5] <= image[0][2][4];
					image[0][3][0] <= image[0][3][1];
					image[0][3][5] <= image[0][3][4];
					image[0][4][0] <= image[0][4][1];
					image[0][4][5] <= image[0][4][4];
					image[0][5][0] <= image[0][4][1];
					image[0][5][1] <= image[0][4][1];
					image[0][5][2] <= image[0][4][2];
					image[0][5][3] <= image[0][4][3];
					image[0][5][4] <= image[0][4][4];
					image[0][5][5] <= image[0][4][4];

					image[1][0][0] <= image[1][1][1];
					image[1][0][1] <= image[1][1][1];
					image[1][0][2] <= image[1][1][2];
					image[1][0][3] <= image[1][1][3];
					image[1][0][4] <= image[1][1][4];
					image[1][0][5] <= image[1][1][4];
					image[1][1][0] <= image[1][1][1];
					image[1][1][5] <= image[1][1][4];
					image[1][2][0] <= image[1][2][1];
					image[1][2][5] <= image[1][2][4];
					image[1][3][0] <= image[1][3][1];
					image[1][3][5] <= image[1][3][4];
					image[1][4][0] <= image[1][4][1];
					image[1][4][5] <= image[1][4][4];
					image[1][5][0] <= image[1][4][1];
					image[1][5][1] <= image[1][4][1];
					image[1][5][2] <= image[1][4][2];
					image[1][5][3] <= image[1][4][3];
					image[1][5][4] <= image[1][4][4];
					image[1][5][5] <= image[1][4][4];

					image[2][0][0] <= image[2][1][1];
					image[2][0][1] <= image[2][1][1];
					image[2][0][2] <= image[2][1][2];
					image[2][0][3] <= image[2][1][3];
					image[2][0][4] <= image[2][1][4];
					image[2][0][5] <= image[2][1][4];
					image[2][1][0] <= image[2][1][1];
					image[2][1][5] <= image[2][1][4];
					image[2][2][0] <= image[2][2][1];
					image[2][2][5] <= image[2][2][4];
					image[2][3][0] <= image[2][3][1];
					image[2][3][5] <= image[2][3][4];
					image[2][4][0] <= image[2][4][1];
					image[2][4][5] <= image[2][4][4];
					image[2][5][0] <= image[2][4][1];
					image[2][5][1] <= image[2][4][1];
					image[2][5][2] <= image[2][4][2];
					image[2][5][3] <= image[2][4][3];
					image[2][5][4] <= image[2][4][4];
					image[2][5][5] <= image[2][4][4];
				end
				2'b01: begin
					image[0][0][0] <= image[0][1][1];
					image[0][0][1] <= image[0][1][1];
					image[0][0][2] <= image[0][1][2];
					image[0][0][3] <= image[0][1][3];
					image[0][0][4] <= image[0][1][4];
					image[0][0][5] <= image[0][1][4];
					image[0][1][0] <= image[0][1][1];
					image[0][1][5] <= image[0][1][4];
					image[0][2][0] <= image[0][2][1];
					image[0][2][5] <= image[0][2][4];
					image[0][3][0] <= image[0][3][1];
					image[0][3][5] <= image[0][3][4];
					image[0][4][0] <= image[0][4][1];
					image[0][4][5] <= image[0][4][4];
					image[0][5][0] <= image[0][4][1];
					image[0][5][1] <= image[0][4][1];
					image[0][5][2] <= image[0][4][2];
					image[0][5][3] <= image[0][4][3];
					image[0][5][4] <= image[0][4][4];
					image[0][5][5] <= image[0][4][4];

					image[1][0][0] <= image[1][1][1];
					image[1][0][1] <= image[1][1][1];
					image[1][0][2] <= image[1][1][2];
					image[1][0][3] <= image[1][1][3];
					image[1][0][4] <= image[1][1][4];
					image[1][0][5] <= image[1][1][4];
					image[1][1][0] <= image[1][1][1];
					image[1][1][5] <= image[1][1][4];
					image[1][2][0] <= image[1][2][1];
					image[1][2][5] <= image[1][2][4];
					image[1][3][0] <= image[1][3][1];
					image[1][3][5] <= image[1][3][4];
					image[1][4][0] <= image[1][4][1];
					image[1][4][5] <= image[1][4][4];
					image[1][5][0] <= image[1][4][1];
					image[1][5][1] <= image[1][4][1];
					image[1][5][2] <= image[1][4][2];
					image[1][5][3] <= image[1][4][3];
					image[1][5][4] <= image[1][4][4];
					image[1][5][5] <= image[1][4][4];

					image[2][0][0] <= image[2][1][1];
					image[2][0][1] <= image[2][1][1];
					image[2][0][2] <= image[2][1][2];
					image[2][0][3] <= image[2][1][3];
					image[2][0][4] <= image[2][1][4];
					image[2][0][5] <= image[2][1][4];
					image[2][1][0] <= image[2][1][1];
					image[2][1][5] <= image[2][1][4];
					image[2][2][0] <= image[2][2][1];
					image[2][2][5] <= image[2][2][4];
					image[2][3][0] <= image[2][3][1];
					image[2][3][5] <= image[2][3][4];
					image[2][4][0] <= image[2][4][1];
					image[2][4][5] <= image[2][4][4];
					image[2][5][0] <= image[2][4][1];
					image[2][5][1] <= image[2][4][1];
					image[2][5][2] <= image[2][4][2];
					image[2][5][3] <= image[2][4][3];
					image[2][5][4] <= image[2][4][4];
					image[2][5][5] <= image[2][4][4];
				end
				2'b10: begin
					image[0][0][0] <= 0;
					image[0][0][1] <= 0;
					image[0][0][2] <= 0;
					image[0][0][3] <= 0;
					image[0][0][4] <= 0;
					image[0][0][5] <= 0;
					image[0][1][0] <= 0;
					image[0][1][5] <= 0;
					image[0][2][0] <= 0;
					image[0][2][5] <= 0;
					image[0][3][0] <= 0;
					image[0][3][5] <= 0;
					image[0][4][0] <= 0;
					image[0][4][5] <= 0;
					image[0][5][0] <= 0;
					image[0][5][1] <= 0;
					image[0][5][2] <= 0;
					image[0][5][3] <= 0;
					image[0][5][4] <= 0;
					image[0][5][5] <= 0;

					image[1][0][0] <= 0;
					image[1][0][1] <= 0;
					image[1][0][2] <= 0;
					image[1][0][3] <= 0;
					image[1][0][4] <= 0;
					image[1][0][5] <= 0;
					image[1][1][0] <= 0;
					image[1][1][5] <= 0;
					image[1][2][0] <= 0;
					image[1][2][5] <= 0;
					image[1][3][0] <= 0;
					image[1][3][5] <= 0;
					image[1][4][0] <= 0;
					image[1][4][5] <= 0;
					image[1][5][0] <= 0;
					image[1][5][1] <= 0;
					image[1][5][2] <= 0;
					image[1][5][3] <= 0;
					image[1][5][4] <= 0;
					image[1][5][5] <= 0;

					image[2][0][0] <= 0;
					image[2][0][1] <= 0;
					image[2][0][2] <= 0;
					image[2][0][3] <= 0;
					image[2][0][4] <= 0;
					image[2][0][5] <= 0;
					image[2][1][0] <= 0;
					image[2][1][5] <= 0;
					image[2][2][0] <= 0;
					image[2][2][5] <= 0;
					image[2][3][0] <= 0;
					image[2][3][5] <= 0;
					image[2][4][0] <= 0;
					image[2][4][5] <= 0;
					image[2][5][0] <= 0;
					image[2][5][1] <= 0;
					image[2][5][2] <= 0;
					image[2][5][3] <= 0;
					image[2][5][4] <= 0;
					image[2][5][5] <= 0;
				end
				2'b11: begin
					image[0][0][0] <= 0;
					image[0][0][1] <= 0;
					image[0][0][2] <= 0;
					image[0][0][3] <= 0;
					image[0][0][4] <= 0;
					image[0][0][5] <= 0;
					image[0][1][0] <= 0;
					image[0][1][5] <= 0;
					image[0][2][0] <= 0;
					image[0][2][5] <= 0;
					image[0][3][0] <= 0;
					image[0][3][5] <= 0;
					image[0][4][0] <= 0;
					image[0][4][5] <= 0;
					image[0][5][0] <= 0;
					image[0][5][1] <= 0;
					image[0][5][2] <= 0;
					image[0][5][3] <= 0;
					image[0][5][4] <= 0;
					image[0][5][5] <= 0;

					image[1][0][0] <= 0;
					image[1][0][1] <= 0;
					image[1][0][2] <= 0;
					image[1][0][3] <= 0;
					image[1][0][4] <= 0;
					image[1][0][5] <= 0;
					image[1][1][0] <= 0;
					image[1][1][5] <= 0;
					image[1][2][0] <= 0;
					image[1][2][5] <= 0;
					image[1][3][0] <= 0;
					image[1][3][5] <= 0;
					image[1][4][0] <= 0;
					image[1][4][5] <= 0;
					image[1][5][0] <= 0;
					image[1][5][1] <= 0;
					image[1][5][2] <= 0;
					image[1][5][3] <= 0;
					image[1][5][4] <= 0;
					image[1][5][5] <= 0;

					image[2][0][0] <= 0;
					image[2][0][1] <= 0;
					image[2][0][2] <= 0;
					image[2][0][3] <= 0;
					image[2][0][4] <= 0;
					image[2][0][5] <= 0;
					image[2][1][0] <= 0;
					image[2][1][5] <= 0;
					image[2][2][0] <= 0;
					image[2][2][5] <= 0;
					image[2][3][0] <= 0;
					image[2][3][5] <= 0;
					image[2][4][0] <= 0;
					image[2][4][5] <= 0;
					image[2][5][0] <= 0;
					image[2][5][1] <= 0;
					image[2][5][2] <= 0;
					image[2][5][3] <= 0;
					image[2][5][4] <= 0;
					image[2][5][5] <= 0;
				end
			endcase
			image_cnt1 <= 1;
		end
	end
end

// Input kernel
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ker_cnt1 <= 0;
		ker_cnt2 <= 0;
	end
    else begin
		if (in_valid_k) begin
			kernel1[ker_cnt1][ker_cnt2] <= Kernel1;
			kernel2[ker_cnt1][ker_cnt2] <= Kernel2;
			kernel3[ker_cnt1][ker_cnt2] <= Kernel3;

			if (ker_cnt2 == 8) begin
				ker_cnt2 <= 0;
				if (ker_cnt1 == 3) begin
					ker_cnt1 <= 0;
				end
				else begin
					ker_cnt1 <= ker_cnt1 + 1;
				end
			end
			else begin 
				ker_cnt2 <= ker_cnt2 + 1;
			end
		end
	end
end

// Start calculate
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		ker_start <= 0;
		ker_start_flag1 <= 0;
		ker_start_flag2 <= 0;
	end
	else begin
		ker_start_flag1 <= ker_start;
		ker_start_flag2 <= ker_start_flag1;
		ker_start_flag3 <= ker_start_flag2;
		ker_start_flag4 <= ker_start_flag3;
		if (ker_cnt1 == 3 && ker_cnt2 == 4) begin
			ker_start <= 1;
		end
		if (cal_cntr == 3 && cal_cntc == 3 && cal_ker == 3) begin
			ker_start <= 0;
		end
	end
end

// Do conv
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cal_cntr <= 0;
		cal_cntc <= 0;
		cal_ker <= 0;
	end
	else begin
		if (ker_start) begin
			for (i = 0; i < 3; i = i + 1) begin
				for (j = 0; j < 3; j = j + 1) begin
					kernel11[i][j] <= kernel1[cal_ker][i+i+i+j];
					kernel22[i][j] <= kernel2[cal_ker][i+i+i+j];
					kernel33[i][j] <= kernel3[cal_ker][i+i+i+j];
				end
			end
			for (i = 0; i < 3; i = i + 1) begin
				for (j = 0; j < 3; j = j + 1) begin
					image11[i][j] <= image[0][i+cal_cntr][j+cal_cntc];
					image22[i][j] <= image[1][i+cal_cntr][j+cal_cntc];
					image33[i][j] <= image[2][i+cal_cntr][j+cal_cntc];
				end
			end

			if (cal_ker == 1) begin
				if (cal_cntc == 3) begin
					cal_ker <= 2;
				end
				else begin
					cal_ker <= 0;
				end

				if (cal_cntc == 3) begin
					cal_cntc <= 0;
				end
				else begin
					cal_cntc <= cal_cntc + 1;
				end
			end
			else if (cal_ker == 3) begin
				if (cal_cntc == 3) begin
					cal_ker <= 0;
					cal_cntc <= 0;
					if (cal_cntr == 3) begin
						cal_cntr <= 0;
					end
					else begin
						cal_cntr <= cal_cntr + 1;
					end
				end
				else begin
					cal_ker <= 2;
					cal_cntc <= cal_cntc + 1;
				end
			end
			else begin
				cal_ker <= cal_ker + 1;
			end

		end
	end
end

// Sum 27
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in11[0][0] <= 0;
	end
	else begin
		if (ker_start_flag1) begin
			for (i = 0; i < 3; i = i + 1) begin
				for (j = 0; j < 3; j = j + 1) begin
					in11[i][j] <= out11[i][j];
					in22[i][j] <= out22[i][j];
					in33[i][j] <= out33[i][j];
				end
			end
		end
	end
end

Relu Relu1( .in_data(input_data1), .out_data(output_data1));
L_Relu LRelu1( .in_data(input_data2), .out_data(output_data2));

Sig Sig1( .in_data(input_data3), .out_data(output_data3));
Tanh Tanh1( .in_data(input_data4), .out_data1(output_data41), .out_data2(output_data42));

DW_fp_recip #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Recip10 ( .a(input_data33), .rnd(3'b000), .z(output_data33));

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Div10 ( .a(input_data441), .b(input_data442), .rnd(3'b000), .z(output_data44));

// Save out
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
	end
	else begin
		if (ker_start_flag2) begin
			case (opt_data)
				0: begin
					input_data1 <= out_sum27;
				end
				1: begin
					input_data2 <= out_sum27;
				end
				2: begin
					input_data3 <= out_sum27;
				end
				3: begin
					input_data4 <= out_sum27;
				end
			endcase

		end
	end
end

// Operation 2
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
	end
	else begin
		if (ker_start_flag3) begin
			case (opt_data)
				2'b00: begin
					output_data11 <= output_data1;
				end
				2'b01: begin
					output_data22 <= output_data2;
				end
				2'b10: begin
					input_data33 <= output_data3;
				end
				2'b11: begin
					input_data441 <= output_data41;
					input_data442 <= output_data42;
				end
			endcase
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		out <= 0;
		out_valid <= 0;
	end
	else begin
		if (ker_start_flag4) begin
			out_valid <= 1;
			
			case (opt_data)
				2'b00: begin
					out <= output_data11;
				end
				2'b01: begin
					out <= output_data22;
				end
				2'b10: begin
					out <= output_data33;
				end
				2'b11: begin
					out <= output_data44;
				end
			endcase
		end
		else begin
			out <= 0;
			out_valid <= 0;
		end
	end
end

endmodule

// Convolution
module DW_fp_conv9(
	kernel00, kernel01, kernel02, kernel10, kernel11, kernel12, kernel20, kernel21, kernel22,
	ima00, ima01, ima02, ima10, ima11, ima12, ima20, ima21, ima22,
	out1, out2, out3
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

input [inst_sig_width+inst_exp_width : 0] kernel00, kernel01, kernel02, kernel10, kernel11, kernel12, kernel20, kernel21, kernel22;
input [inst_sig_width+inst_exp_width : 0] ima00, ima01, ima02, ima10, ima11, ima12, ima20, ima21, ima22;
output [inst_sig_width+inst_exp_width : 0] out1, out2, out3;

DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
DP1 ( .a(kernel00), .b(ima00), .c(kernel01), .d(ima01), .e(kernel02), .f(ima02), .rnd(3'b000), .z(out1));

DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
DP2 ( .a(kernel10), .b(ima10), .c(kernel11), .d(ima11), .e(kernel12), .f(ima12), .rnd(3'b000), .z(out2));

DW_fp_dp3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
DP3 ( .a(kernel20), .b(ima20), .c(kernel21), .d(ima21), .e(kernel22), .f(ima22), .rnd(3'b000), .z(out3));

endmodule

module DW_fp_sum27(
	in000, in001, in002, in010, in011, in012, in020, in021, in022,
	in100, in101, in102, in110, in111, in112, in120, in121, in122,
	in200, in201, in202, in210, in211, in212, in220, in221, in222,
	out_sum
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

input [inst_sig_width+inst_exp_width : 0] in000, in001, in002, in010, in011, in012, in020, in021, in022;
input [inst_sig_width+inst_exp_width : 0] in100, in101, in102, in110, in111, in112, in120, in121, in122;
input [inst_sig_width+inst_exp_width : 0] in200, in201, in202, in210, in211, in212, in220, in221, in222;
output [inst_sig_width+inst_exp_width : 0] out_sum;

wire [inst_sig_width+inst_exp_width : 0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12;

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su1 ( .a(in000), .b(in001), .c(in002), .rnd(3'b000), .z(s1));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su2 ( .a(in010), .b(in011), .c(in012), .rnd(3'b000), .z(s2));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su3 ( .a(in020), .b(in021), .c(in022), .rnd(3'b000), .z(s3));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su4 ( .a(in100), .b(in101), .c(in102), .rnd(3'b000), .z(s4));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su5 ( .a(in110), .b(in111), .c(in112), .rnd(3'b000), .z(s5));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su6 ( .a(in120), .b(in121), .c(in122), .rnd(3'b000), .z(s6));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su7 ( .a(in200), .b(in201), .c(in202), .rnd(3'b000), .z(s7));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su8 ( .a(in210), .b(in211), .c(in212), .rnd(3'b000), .z(s8));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su9 ( .a(in220), .b(in221), .c(in222), .rnd(3'b000), .z(s9));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su10 ( .a(s1), .b(s2), .c(s3), .rnd(3'b000), .z(s10));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su11 ( .a(s4), .b(s5), .c(s6), .rnd(3'b000), .z(s11));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su12 ( .a(s7), .b(s8), .c(s9), .rnd(3'b000), .z(s12));

DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Su13 ( .a(s10), .b(s11), .c(s12), .rnd(3'b000), .z(out_sum));

endmodule

module DW_fp_conv27(
	kernel000, kernel001, kernel002, kernel010, kernel011, kernel012, kernel020, kernel021, kernel022,
	kernel100, kernel101, kernel102, kernel110, kernel111, kernel112, kernel120, kernel121, kernel122,
	kernel200, kernel201, kernel202, kernel210, kernel211, kernel212, kernel220, kernel221, kernel222,
	ima000, ima001, ima002, ima010, ima011, ima012, ima020, ima021, ima022,
	ima100, ima101, ima102, ima110, ima111, ima112, ima120, ima121, ima122,
	ima200, ima201, ima202, ima210, ima211, ima212, ima220, ima221, ima222,
	out000, out001, out002, out010, out011, out012, out020, out021, out022,
	out100, out101, out102, out110, out111, out112, out120, out121, out122,
	out200, out201, out202, out210, out211, out212, out220, out221, out222
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

input [inst_sig_width+inst_exp_width : 0] kernel000, kernel001, kernel002, kernel010, kernel011, kernel012, kernel020, kernel021, kernel022;
input [inst_sig_width+inst_exp_width : 0] kernel100, kernel101, kernel102, kernel110, kernel111, kernel112, kernel120, kernel121, kernel122;
input [inst_sig_width+inst_exp_width : 0] kernel200, kernel201, kernel202, kernel210, kernel211, kernel212, kernel220, kernel221, kernel222;
input [inst_sig_width+inst_exp_width : 0] ima000, ima001, ima002, ima010, ima011, ima012, ima020, ima021, ima022;
input [inst_sig_width+inst_exp_width : 0] ima100, ima101, ima102, ima110, ima111, ima112, ima120, ima121, ima122;
input [inst_sig_width+inst_exp_width : 0] ima200, ima201, ima202, ima210, ima211, ima212, ima220, ima221, ima222;
output [inst_sig_width+inst_exp_width : 0] out000, out001, out002, out010, out011, out012, out020, out021, out022;
output [inst_sig_width+inst_exp_width : 0] out100, out101, out102, out110, out111, out112, out120, out121, out122;
output [inst_sig_width+inst_exp_width : 0] out200, out201, out202, out210, out211, out212, out220, out221, out222;

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul1 ( .a(kernel000), .b(ima000), .rnd(3'b000), .z(out000));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul2 ( .a(kernel001), .b(ima001), .rnd(3'b000), .z(out001));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul3 ( .a(kernel002), .b(ima002), .rnd(3'b000), .z(out002));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul4 ( .a(kernel010), .b(ima010), .rnd(3'b000), .z(out010));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul5 ( .a(kernel011), .b(ima011), .rnd(3'b000), .z(out011));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul6 ( .a(kernel012), .b(ima012), .rnd(3'b000), .z(out012));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul7 ( .a(kernel020), .b(ima020), .rnd(3'b000), .z(out020));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul8 ( .a(kernel021), .b(ima021), .rnd(3'b000), .z(out021));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul9 ( .a(kernel022), .b(ima022), .rnd(3'b000), .z(out022));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul10 ( .a(kernel100), .b(ima100), .rnd(3'b000), .z(out100));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul11 ( .a(kernel101), .b(ima101), .rnd(3'b000), .z(out101));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul12 ( .a(kernel102), .b(ima102), .rnd(3'b000), .z(out102));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul13 ( .a(kernel110), .b(ima110), .rnd(3'b000), .z(out110));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul14 ( .a(kernel111), .b(ima111), .rnd(3'b000), .z(out111));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul15 ( .a(kernel112), .b(ima112), .rnd(3'b000), .z(out112));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul16 ( .a(kernel120), .b(ima120), .rnd(3'b000), .z(out120));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul17 ( .a(kernel121), .b(ima121), .rnd(3'b000), .z(out121));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul18 ( .a(kernel122), .b(ima122), .rnd(3'b000), .z(out122));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul19 ( .a(kernel200), .b(ima200), .rnd(3'b000), .z(out200));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul20 ( .a(kernel201), .b(ima201), .rnd(3'b000), .z(out201));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul21 ( .a(kernel202), .b(ima202), .rnd(3'b000), .z(out202));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul22 ( .a(kernel210), .b(ima210), .rnd(3'b000), .z(out210));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul23 ( .a(kernel211), .b(ima211), .rnd(3'b000), .z(out211));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul24 ( .a(kernel212), .b(ima212), .rnd(3'b000), .z(out212));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul25 ( .a(kernel220), .b(ima220), .rnd(3'b000), .z(out220));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul26 ( .a(kernel221), .b(ima221), .rnd(3'b000), .z(out221));

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mul27 ( .a(kernel222), .b(ima222), .rnd(3'b000), .z(out222));

endmodule

// Activation function
module Relu(
	in_data, out_data
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

parameter zero = 32'b0_0000_0000_00000000000000000000000;

input [inst_sig_width+inst_exp_width : 0] in_data;
output [inst_sig_width+inst_exp_width : 0] out_data;

// Comparator
DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Cmp1 ( .a(in_data), .b(zero), .z1(out_data), .zctr(1'b0));

endmodule

module L_Relu(
	in_data, out_data
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

parameter zero = 32'b0_00000000_00000000000000000000000;
parameter re01 = 32'b0_01111011_10011001100110011001101;

input [inst_sig_width+inst_exp_width : 0] in_data;
output [inst_sig_width+inst_exp_width : 0] out_data;

wire [inst_sig_width+inst_exp_width : 0] s1, s2, s3;

// Comparator

DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Mult1 ( .a(in_data), .b(re01), .rnd(3'b000), .z(s1));

DW_fp_cmp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Cmp2 ( .a(in_data), .b(s1), .z1(out_data), .zctr(1'b0));

endmodule

module Sig(
	in_data, out_data
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

parameter one  = 32'b0_01111111_00000000000000000000000;

input [inst_sig_width+inst_exp_width : 0] in_data;
output [inst_sig_width+inst_exp_width : 0] out_data;

wire [inst_sig_width+inst_exp_width : 0] s1, s2;

assign s1 = {!in_data[31], in_data[30:0]};

// Sigmoid
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Exp1 ( .a(s1), .z(s2));

DW_fp_add  #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Add1 ( .a(s2), .b(one), .rnd(3'b000), .z(out_data));

endmodule

module Tanh(
	in_data, out_data1, out_data2
);

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;

input [inst_sig_width+inst_exp_width : 0] in_data;
output [inst_sig_width+inst_exp_width : 0] out_data1, out_data2;

wire [inst_sig_width+inst_exp_width : 0] s1, s2, s3;

assign s2 = {!in_data[31], in_data[30:0]};

// Tanh
DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Exp2 ( .a(in_data), .z(s1));

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Exp3 ( .a(s2), .z(s3));

DW_fp_sub #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Sub1 ( .a(s1), .b(s3), .rnd(3'b000), .z(out_data1));

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
Add2 ( .a(s1), .b(s3), .rnd(3'b000), .z(out_data2));

endmodule
