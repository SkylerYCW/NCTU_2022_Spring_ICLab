//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : WD.v
//   Module Name : WD
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module WD(
    // Input signals
    clk,
    rst_n,
    in_valid,
    keyboard,
    answer,
    weight,
    match_target,
    // Output signals
    out_valid,
    result,
    out_value
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [4:0] keyboard, answer;
input [3:0] weight;
input [2:0] match_target;
output reg out_valid;
output reg [4:0]  result;
output reg [10:0] out_value;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================

parameter IDLE    = 2'd0;
parameter INPUT   = 2'd1;
parameter CAL     = 2'd2;
parameter OUT     = 2'd3;


// ===============================================================
// Wire & Reg Declaration
// ===============================================================


integer i, j, k, l, m, n, r;
reg [1:0] current_state, next_state;

reg [4:0] key [0:7];
reg [4:0] ans [0:4];
reg [3:0] wei [0:4];
reg [2:0] mat_a, mat_b;
reg [4:0] nans [0:2];

reg [2:0] cnt0;
reg [2:0] cnt1;
reg [2:0] cnt2;
reg [2:0] cnt3;
reg [2:0] cnt4;
reg [2:0] cnt_a, cnt_b;
reg [5:0] cnt_56;
reg [6:0] cnt_120;
reg [2:0] cnt_out;

reg [2:0] cnt_reg [0:55][0:4];
reg [2:0] cnt_pos [0:119][0:4];

reg [4:0] temp;

reg [4:0] resultsss [0:4];

reg finish;
reg [3:0] cnt;
reg [6:0] cnt_cal;

reg [10:0] out_val;
reg [10:0] outs;


// ===============================================================
// DESIGN
// ===============================================================

// Current State
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		current_state <= IDLE;
    else
		current_state <= next_state;
end


// Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
			IDLE: begin
				if (in_valid)	next_state = INPUT;
				else 			next_state = current_state;
			end
            INPUT: begin
                if (cnt == 7)   next_state = CAL;
                else            next_state = current_state;
            end
			CAL: begin
				if (cnt_120 == 120 && cnt_56 == 1)		next_state = OUT;
				else 			next_state = current_state;
			end
			OUT: begin
				if (cnt_out == 5)	next_state = IDLE;
				else 			next_state = current_state;
			end
            default: 			next_state = current_state;
        endcase
    end
end

always @(*) begin
    if (!rst_n) begin
		r = 0;
		for(i = 0; i < 4; i = i + 1) begin
			for(j = i + 1; j < 5; j = j + 1) begin
				for(k = j + 1; k < 6; k = k + 1) begin
					for(l = k + 1; l < 7; l = l + 1) begin
						for(m = l + 1; m < 8; m = m + 1) begin
							cnt_reg[r][0] = i;
							cnt_reg[r][1] = j;
							cnt_reg[r][2] = k;
							cnt_reg[r][3] = l;
							cnt_reg[r][4] = m;
							r = r + 1;
						end
					end
				end
				
			end
		end
		cnt_pos[0][0] = 0; cnt_pos[0][1] = 1; cnt_pos[0][2] = 2; cnt_pos[0][3] = 3; cnt_pos[0][4] = 4;
		cnt_pos[1][0] = 0; cnt_pos[1][1] = 1; cnt_pos[1][2] = 2; cnt_pos[1][3] = 4; cnt_pos[1][4] = 3;
		cnt_pos[2][0] = 0; cnt_pos[2][1] = 1; cnt_pos[2][2] = 3; cnt_pos[2][3] = 2; cnt_pos[2][4] = 4;
		cnt_pos[3][0] = 0; cnt_pos[3][1] = 1; cnt_pos[3][2] = 3; cnt_pos[3][3] = 4; cnt_pos[3][4] = 2;
		cnt_pos[4][0] = 0; cnt_pos[4][1] = 1; cnt_pos[4][2] = 4; cnt_pos[4][3] = 3; cnt_pos[4][4] = 2;
		cnt_pos[5][0] = 0; cnt_pos[5][1] = 1; cnt_pos[5][2] = 4; cnt_pos[5][3] = 2; cnt_pos[5][4] = 3;
		cnt_pos[6][0] = 0; cnt_pos[6][1] = 2; cnt_pos[6][2] = 1; cnt_pos[6][3] = 3; cnt_pos[6][4] = 4;
		cnt_pos[7][0] = 0; cnt_pos[7][1] = 2; cnt_pos[7][2] = 1; cnt_pos[7][3] = 4; cnt_pos[7][4] = 3;
		cnt_pos[8][0] = 0; cnt_pos[8][1] = 2; cnt_pos[8][2] = 3; cnt_pos[8][3] = 1; cnt_pos[8][4] = 4;
		cnt_pos[9][0] = 0; cnt_pos[9][1] = 2; cnt_pos[9][2] = 3; cnt_pos[9][3] = 4; cnt_pos[9][4] = 1;
		cnt_pos[10][0] = 0; cnt_pos[10][1] = 2; cnt_pos[10][2] = 4; cnt_pos[10][3] = 3; cnt_pos[10][4] = 1;
		cnt_pos[11][0] = 0; cnt_pos[11][1] = 2; cnt_pos[11][2] = 4; cnt_pos[11][3] = 1; cnt_pos[11][4] = 3;
		cnt_pos[12][0] = 0; cnt_pos[12][1] = 3; cnt_pos[12][2] = 1; cnt_pos[12][3] = 2; cnt_pos[12][4] = 4;
		cnt_pos[13][0] = 0; cnt_pos[13][1] = 3; cnt_pos[13][2] = 1; cnt_pos[13][3] = 4; cnt_pos[13][4] = 2;
		cnt_pos[14][0] = 0; cnt_pos[14][1] = 3; cnt_pos[14][2] = 2; cnt_pos[14][3] = 1; cnt_pos[14][4] = 4;
		cnt_pos[15][0] = 0; cnt_pos[15][1] = 3; cnt_pos[15][2] = 2; cnt_pos[15][3] = 4; cnt_pos[15][4] = 1;
		cnt_pos[16][0] = 0; cnt_pos[16][1] = 3; cnt_pos[16][2] = 4; cnt_pos[16][3] = 1; cnt_pos[16][4] = 2;
		cnt_pos[17][0] = 0; cnt_pos[17][1] = 3; cnt_pos[17][2] = 4; cnt_pos[17][3] = 2; cnt_pos[17][4] = 1;
		cnt_pos[18][0] = 0; cnt_pos[18][1] = 4; cnt_pos[18][2] = 2; cnt_pos[18][3] = 3; cnt_pos[18][4] = 1;
		cnt_pos[19][0] = 0; cnt_pos[19][1] = 4; cnt_pos[19][2] = 2; cnt_pos[19][3] = 1; cnt_pos[19][4] = 3;
		cnt_pos[20][0] = 0; cnt_pos[20][1] = 4; cnt_pos[20][2] = 3; cnt_pos[20][3] = 1; cnt_pos[20][4] = 2;
		cnt_pos[21][0] = 0; cnt_pos[21][1] = 4; cnt_pos[21][2] = 3; cnt_pos[21][3] = 2; cnt_pos[21][4] = 1;
		cnt_pos[22][0] = 0; cnt_pos[22][1] = 4; cnt_pos[22][2] = 1; cnt_pos[22][3] = 3; cnt_pos[22][4] = 2;
		cnt_pos[23][0] = 0; cnt_pos[23][1] = 4; cnt_pos[23][2] = 1; cnt_pos[23][3] = 2; cnt_pos[23][4] = 3;
		
		cnt_pos[24][0] = 1; cnt_pos[24][1] = 0; cnt_pos[24][2] = 2; cnt_pos[24][3] = 3; cnt_pos[24][4] = 4;
		cnt_pos[25][0] = 1; cnt_pos[25][1] = 0; cnt_pos[25][2] = 2; cnt_pos[25][3] = 4; cnt_pos[25][4] = 3;
		cnt_pos[26][0] = 1; cnt_pos[26][1] = 0; cnt_pos[26][2] = 3; cnt_pos[26][3] = 2; cnt_pos[26][4] = 4;
		cnt_pos[27][0] = 1; cnt_pos[27][1] = 0; cnt_pos[27][2] = 3; cnt_pos[27][3] = 4; cnt_pos[27][4] = 2;
		cnt_pos[28][0] = 1; cnt_pos[28][1] = 0; cnt_pos[28][2] = 4; cnt_pos[28][3] = 2; cnt_pos[28][4] = 3;
		cnt_pos[29][0] = 1; cnt_pos[29][1] = 0; cnt_pos[29][2] = 4; cnt_pos[29][3] = 3; cnt_pos[29][4] = 2;
		cnt_pos[30][0] = 1; cnt_pos[30][1] = 2; cnt_pos[30][2] = 0; cnt_pos[30][3] = 3; cnt_pos[30][4] = 4;
		cnt_pos[31][0] = 1; cnt_pos[31][1] = 2; cnt_pos[31][2] = 0; cnt_pos[31][3] = 4; cnt_pos[31][4] = 3;
		cnt_pos[32][0] = 1; cnt_pos[32][1] = 2; cnt_pos[32][2] = 3; cnt_pos[32][3] = 0; cnt_pos[32][4] = 4;
		cnt_pos[33][0] = 1; cnt_pos[33][1] = 2; cnt_pos[33][2] = 3; cnt_pos[33][3] = 4; cnt_pos[33][4] = 0;
		cnt_pos[34][0] = 1; cnt_pos[34][1] = 2; cnt_pos[34][2] = 4; cnt_pos[34][3] = 3; cnt_pos[34][4] = 0;
		cnt_pos[35][0] = 1; cnt_pos[35][1] = 2; cnt_pos[35][2] = 4; cnt_pos[35][3] = 0; cnt_pos[35][4] = 3;
		cnt_pos[36][0] = 1; cnt_pos[36][1] = 3; cnt_pos[36][2] = 0; cnt_pos[36][3] = 2; cnt_pos[36][4] = 4;
		cnt_pos[37][0] = 1; cnt_pos[37][1] = 3; cnt_pos[37][2] = 0; cnt_pos[37][3] = 4; cnt_pos[37][4] = 2;
		cnt_pos[38][0] = 1; cnt_pos[38][1] = 3; cnt_pos[38][2] = 2; cnt_pos[38][3] = 0; cnt_pos[38][4] = 4;
		cnt_pos[39][0] = 1; cnt_pos[39][1] = 3; cnt_pos[39][2] = 2; cnt_pos[39][3] = 4; cnt_pos[39][4] = 0;
		cnt_pos[40][0] = 1; cnt_pos[40][1] = 3; cnt_pos[40][2] = 4; cnt_pos[40][3] = 0; cnt_pos[40][4] = 2;
		cnt_pos[41][0] = 1; cnt_pos[41][1] = 3; cnt_pos[41][2] = 4; cnt_pos[41][3] = 2; cnt_pos[41][4] = 0;
		cnt_pos[42][0] = 1; cnt_pos[42][1] = 4; cnt_pos[42][2] = 0; cnt_pos[42][3] = 2; cnt_pos[42][4] = 3;
		cnt_pos[43][0] = 1; cnt_pos[43][1] = 4; cnt_pos[43][2] = 0; cnt_pos[43][3] = 3; cnt_pos[43][4] = 2;
		cnt_pos[44][0] = 1; cnt_pos[44][1] = 4; cnt_pos[44][2] = 3; cnt_pos[44][3] = 0; cnt_pos[44][4] = 2;
		cnt_pos[45][0] = 1; cnt_pos[45][1] = 4; cnt_pos[45][2] = 3; cnt_pos[45][3] = 2; cnt_pos[45][4] = 0;
		cnt_pos[46][0] = 1; cnt_pos[46][1] = 4; cnt_pos[46][2] = 2; cnt_pos[46][3] = 3; cnt_pos[46][4] = 0;
		cnt_pos[47][0] = 1; cnt_pos[47][1] = 4; cnt_pos[47][2] = 2; cnt_pos[47][3] = 0; cnt_pos[47][4] = 3;
		
		cnt_pos[48][0] = 2; cnt_pos[48][1] = 0; cnt_pos[48][2] = 1; cnt_pos[48][3] = 3; cnt_pos[48][4] = 4;
		cnt_pos[49][0] = 2; cnt_pos[49][1] = 0; cnt_pos[49][2] = 1; cnt_pos[49][3] = 4; cnt_pos[49][4] = 3;
		cnt_pos[50][0] = 2; cnt_pos[50][1] = 0; cnt_pos[50][2] = 3; cnt_pos[50][3] = 1; cnt_pos[50][4] = 4;
		cnt_pos[51][0] = 2; cnt_pos[51][1] = 0; cnt_pos[51][2] = 3; cnt_pos[51][3] = 4; cnt_pos[51][4] = 1;
		cnt_pos[52][0] = 2; cnt_pos[52][1] = 0; cnt_pos[52][2] = 4; cnt_pos[52][3] = 3; cnt_pos[52][4] = 1;
		cnt_pos[53][0] = 2; cnt_pos[53][1] = 0; cnt_pos[53][2] = 4; cnt_pos[53][3] = 1; cnt_pos[53][4] = 3;
		cnt_pos[54][0] = 2; cnt_pos[54][1] = 1; cnt_pos[54][2] = 0; cnt_pos[54][3] = 3; cnt_pos[54][4] = 4;
		cnt_pos[55][0] = 2; cnt_pos[55][1] = 1; cnt_pos[55][2] = 0; cnt_pos[55][3] = 4; cnt_pos[55][4] = 3;
		cnt_pos[56][0] = 2; cnt_pos[56][1] = 1; cnt_pos[56][2] = 3; cnt_pos[56][3] = 0; cnt_pos[56][4] = 4;
		cnt_pos[57][0] = 2; cnt_pos[57][1] = 1; cnt_pos[57][2] = 3; cnt_pos[57][3] = 4; cnt_pos[57][4] = 0;
		cnt_pos[58][0] = 2; cnt_pos[58][1] = 1; cnt_pos[58][2] = 4; cnt_pos[58][3] = 0; cnt_pos[58][4] = 3;
		cnt_pos[59][0] = 2; cnt_pos[59][1] = 1; cnt_pos[59][2] = 4; cnt_pos[59][3] = 3; cnt_pos[59][4] = 0;
		cnt_pos[60][0] = 2; cnt_pos[60][1] = 3; cnt_pos[60][2] = 0; cnt_pos[60][3] = 4; cnt_pos[60][4] = 1;
		cnt_pos[61][0] = 2; cnt_pos[61][1] = 3; cnt_pos[61][2] = 0; cnt_pos[61][3] = 1; cnt_pos[61][4] = 4;
		cnt_pos[62][0] = 2; cnt_pos[62][1] = 3; cnt_pos[62][2] = 4; cnt_pos[62][3] = 0; cnt_pos[62][4] = 1;
		cnt_pos[63][0] = 2; cnt_pos[63][1] = 3; cnt_pos[63][2] = 4; cnt_pos[63][3] = 1; cnt_pos[63][4] = 0;
		cnt_pos[64][0] = 2; cnt_pos[64][1] = 3; cnt_pos[64][2] = 1; cnt_pos[64][3] = 0; cnt_pos[64][4] = 4;
		cnt_pos[65][0] = 2; cnt_pos[65][1] = 3; cnt_pos[65][2] = 1; cnt_pos[65][3] = 4; cnt_pos[65][4] = 0;
		cnt_pos[66][0] = 2; cnt_pos[66][1] = 4; cnt_pos[66][2] = 3; cnt_pos[66][3] = 0; cnt_pos[66][4] = 1;
		cnt_pos[67][0] = 2; cnt_pos[67][1] = 4; cnt_pos[67][2] = 3; cnt_pos[67][3] = 1; cnt_pos[67][4] = 0;
		cnt_pos[68][0] = 2; cnt_pos[68][1] = 4; cnt_pos[68][2] = 1; cnt_pos[68][3] = 0; cnt_pos[68][4] = 3;
		cnt_pos[69][0] = 2; cnt_pos[69][1] = 4; cnt_pos[69][2] = 1; cnt_pos[69][3] = 3; cnt_pos[69][4] = 0;
		cnt_pos[70][0] = 2; cnt_pos[70][1] = 4; cnt_pos[70][2] = 0; cnt_pos[70][3] = 3; cnt_pos[70][4] = 1;
		cnt_pos[71][0] = 2; cnt_pos[71][1] = 4; cnt_pos[71][2] = 0; cnt_pos[71][3] = 1; cnt_pos[71][4] = 3;
		
		cnt_pos[72][0] = 3; cnt_pos[72][1] = 1; cnt_pos[72][2] = 2; cnt_pos[72][3] = 4; cnt_pos[72][4] = 0;
		cnt_pos[73][0] = 3; cnt_pos[73][1] = 1; cnt_pos[73][2] = 2; cnt_pos[73][3] = 0; cnt_pos[73][4] = 4;
		cnt_pos[74][0] = 3; cnt_pos[74][1] = 1; cnt_pos[74][2] = 0; cnt_pos[74][3] = 4; cnt_pos[74][4] = 2;
		cnt_pos[75][0] = 3; cnt_pos[75][1] = 1; cnt_pos[75][2] = 0; cnt_pos[75][3] = 2; cnt_pos[75][4] = 4;
		cnt_pos[76][0] = 3; cnt_pos[76][1] = 1; cnt_pos[76][2] = 4; cnt_pos[76][3] = 0; cnt_pos[76][4] = 2;
		cnt_pos[77][0] = 3; cnt_pos[77][1] = 1; cnt_pos[77][2] = 4; cnt_pos[77][3] = 2; cnt_pos[77][4] = 0;
		cnt_pos[78][0] = 3; cnt_pos[78][1] = 2; cnt_pos[78][2] = 0; cnt_pos[78][3] = 4; cnt_pos[78][4] = 1;
		cnt_pos[79][0] = 3; cnt_pos[79][1] = 2; cnt_pos[79][2] = 0; cnt_pos[79][3] = 1; cnt_pos[79][4] = 4;
		cnt_pos[80][0] = 3; cnt_pos[80][1] = 2; cnt_pos[80][2] = 1; cnt_pos[80][3] = 0; cnt_pos[80][4] = 4;
		cnt_pos[81][0] = 3; cnt_pos[81][1] = 2; cnt_pos[81][2] = 1; cnt_pos[81][3] = 4; cnt_pos[81][4] = 0;
		cnt_pos[82][0] = 3; cnt_pos[82][1] = 2; cnt_pos[82][2] = 4; cnt_pos[82][3] = 0; cnt_pos[82][4] = 1;
		cnt_pos[83][0] = 3; cnt_pos[83][1] = 2; cnt_pos[83][2] = 4; cnt_pos[83][3] = 1; cnt_pos[83][4] = 0;
		cnt_pos[84][0] = 3; cnt_pos[84][1] = 4; cnt_pos[84][2] = 2; cnt_pos[84][3] = 0; cnt_pos[84][4] = 1;
		cnt_pos[85][0] = 3; cnt_pos[85][1] = 4; cnt_pos[85][2] = 2; cnt_pos[85][3] = 1; cnt_pos[85][4] = 0;
		cnt_pos[86][0] = 3; cnt_pos[86][1] = 4; cnt_pos[86][2] = 0; cnt_pos[86][3] = 1; cnt_pos[86][4] = 2;
		cnt_pos[87][0] = 3; cnt_pos[87][1] = 4; cnt_pos[87][2] = 0; cnt_pos[87][3] = 2; cnt_pos[87][4] = 1;
		cnt_pos[88][0] = 3; cnt_pos[88][1] = 4; cnt_pos[88][2] = 1; cnt_pos[88][3] = 0; cnt_pos[88][4] = 2;
		cnt_pos[89][0] = 3; cnt_pos[89][1] = 4; cnt_pos[89][2] = 1; cnt_pos[89][3] = 2; cnt_pos[89][4] = 0;
		cnt_pos[90][0] = 3; cnt_pos[90][1] = 0; cnt_pos[90][2] = 2; cnt_pos[90][3] = 4; cnt_pos[90][4] = 1;
		cnt_pos[91][0] = 3; cnt_pos[91][1] = 0; cnt_pos[91][2] = 2; cnt_pos[91][3] = 1; cnt_pos[91][4] = 4;
		cnt_pos[92][0] = 3; cnt_pos[92][1] = 0; cnt_pos[92][2] = 1; cnt_pos[92][3] = 4; cnt_pos[92][4] = 2;
		cnt_pos[93][0] = 3; cnt_pos[93][1] = 0; cnt_pos[93][2] = 1; cnt_pos[93][3] = 2; cnt_pos[93][4] = 4;
		cnt_pos[94][0] = 3; cnt_pos[94][1] = 0; cnt_pos[94][2] = 4; cnt_pos[94][3] = 1; cnt_pos[94][4] = 2;
		cnt_pos[95][0] = 3; cnt_pos[95][1] = 0; cnt_pos[95][2] = 4; cnt_pos[95][3] = 2; cnt_pos[95][4] = 1;
		
		cnt_pos[96][0] = 4; cnt_pos[96][1] = 1; cnt_pos[96][2] = 2; cnt_pos[96][3] = 3; cnt_pos[96][4] = 0;
		cnt_pos[97][0] = 4; cnt_pos[97][1] = 1; cnt_pos[97][2] = 2; cnt_pos[97][3] = 0; cnt_pos[97][4] = 3;
		cnt_pos[98][0] = 4; cnt_pos[98][1] = 1; cnt_pos[98][2] = 3; cnt_pos[98][3] = 0; cnt_pos[98][4] = 2;
		cnt_pos[99][0] = 4; cnt_pos[99][1] = 1; cnt_pos[99][2] = 3; cnt_pos[99][3] = 2; cnt_pos[99][4] = 0;
		cnt_pos[100][0] = 4; cnt_pos[100][1] = 1; cnt_pos[100][2] = 0; cnt_pos[100][3] = 3; cnt_pos[100][4] = 2;
		cnt_pos[101][0] = 4; cnt_pos[101][1] = 1; cnt_pos[101][2] = 0; cnt_pos[101][3] = 2; cnt_pos[101][4] = 3;
		cnt_pos[102][0] = 4; cnt_pos[102][1] = 2; cnt_pos[102][2] = 1; cnt_pos[102][3] = 0; cnt_pos[102][4] = 3;
		cnt_pos[103][0] = 4; cnt_pos[103][1] = 2; cnt_pos[103][2] = 1; cnt_pos[103][3] = 3; cnt_pos[103][4] = 0;
		cnt_pos[104][0] = 4; cnt_pos[104][1] = 2; cnt_pos[104][2] = 3; cnt_pos[104][3] = 0; cnt_pos[104][4] = 1;
		cnt_pos[105][0] = 4; cnt_pos[105][1] = 2; cnt_pos[105][2] = 3; cnt_pos[105][3] = 1; cnt_pos[105][4] = 0;
		cnt_pos[106][0] = 4; cnt_pos[106][1] = 2; cnt_pos[106][2] = 0; cnt_pos[106][3] = 3; cnt_pos[106][4] = 1;
		cnt_pos[107][0] = 4; cnt_pos[107][1] = 2; cnt_pos[107][2] = 0; cnt_pos[107][3] = 1; cnt_pos[107][4] = 3;
		cnt_pos[108][0] = 4; cnt_pos[108][1] = 3; cnt_pos[108][2] = 2; cnt_pos[108][3] = 0; cnt_pos[108][4] = 1;
		cnt_pos[109][0] = 4; cnt_pos[109][1] = 3; cnt_pos[109][2] = 2; cnt_pos[109][3] = 1; cnt_pos[109][4] = 0;
		cnt_pos[110][0] = 4; cnt_pos[110][1] = 3; cnt_pos[110][2] = 1; cnt_pos[110][3] = 0; cnt_pos[110][4] = 2;
		cnt_pos[111][0] = 4; cnt_pos[111][1] = 3; cnt_pos[111][2] = 1; cnt_pos[111][3] = 2; cnt_pos[111][4] = 0;
		cnt_pos[112][0] = 4; cnt_pos[112][1] = 3; cnt_pos[112][2] = 0; cnt_pos[112][3] = 1; cnt_pos[112][4] = 2;
		cnt_pos[113][0] = 4; cnt_pos[113][1] = 3; cnt_pos[113][2] = 0; cnt_pos[113][3] = 2; cnt_pos[113][4] = 1;
		cnt_pos[114][0] = 4; cnt_pos[114][1] = 0; cnt_pos[114][2] = 2; cnt_pos[114][3] = 3; cnt_pos[114][4] = 1;
		cnt_pos[115][0] = 4; cnt_pos[115][1] = 0; cnt_pos[115][2] = 2; cnt_pos[115][3] = 1; cnt_pos[115][4] = 3;
		cnt_pos[116][0] = 4; cnt_pos[116][1] = 0; cnt_pos[116][2] = 3; cnt_pos[116][3] = 2; cnt_pos[116][4] = 1;
		cnt_pos[117][0] = 4; cnt_pos[117][1] = 0; cnt_pos[117][2] = 3; cnt_pos[117][3] = 1; cnt_pos[117][4] = 2;
		cnt_pos[118][0] = 4; cnt_pos[118][1] = 0; cnt_pos[118][2] = 1; cnt_pos[118][3] = 3; cnt_pos[118][4] = 2;
		cnt_pos[119][0] = 4; cnt_pos[119][1] = 0; cnt_pos[119][2] = 1; cnt_pos[119][3] = 2; cnt_pos[119][4] = 3;
		for(i = 0; i < 56; i = i + 1) begin
			//$display ("   ---%03d, %03d, %03d, %03d, %03d---                        ",cnt_reg[i][0], cnt_reg[i][1], cnt_reg[i][2], cnt_reg[i][3], cnt_reg[i][4]);
		end
		
	
	end
    else begin
        r = 0;
		for(i = 0; i < 4; i = i + 1) begin
			for(j = i + 1; j < 5; j = j + 1) begin
				for(k = j + 1; k < 6; k = k + 1) begin
					for(l = k + 1; l < 7; l = l + 1) begin
						for(m = l + 1; m < 8; m = m + 1) begin
							cnt_reg[r][0] = i;
							cnt_reg[r][1] = j;
							cnt_reg[r][2] = k;
							cnt_reg[r][3] = l;
							cnt_reg[r][4] = m;
							r = r + 1;
						end
					end
				end
				
			end
		end
		cnt_pos[0][0] = 0; cnt_pos[0][1] = 1; cnt_pos[0][2] = 2; cnt_pos[0][3] = 3; cnt_pos[0][4] = 4;
		cnt_pos[1][0] = 0; cnt_pos[1][1] = 1; cnt_pos[1][2] = 2; cnt_pos[1][3] = 4; cnt_pos[1][4] = 3;
		cnt_pos[2][0] = 0; cnt_pos[2][1] = 1; cnt_pos[2][2] = 3; cnt_pos[2][3] = 2; cnt_pos[2][4] = 4;
		cnt_pos[3][0] = 0; cnt_pos[3][1] = 1; cnt_pos[3][2] = 3; cnt_pos[3][3] = 4; cnt_pos[3][4] = 2;
		cnt_pos[4][0] = 0; cnt_pos[4][1] = 1; cnt_pos[4][2] = 4; cnt_pos[4][3] = 3; cnt_pos[4][4] = 2;
		cnt_pos[5][0] = 0; cnt_pos[5][1] = 1; cnt_pos[5][2] = 4; cnt_pos[5][3] = 2; cnt_pos[5][4] = 3;
		cnt_pos[6][0] = 0; cnt_pos[6][1] = 2; cnt_pos[6][2] = 1; cnt_pos[6][3] = 3; cnt_pos[6][4] = 4;
		cnt_pos[7][0] = 0; cnt_pos[7][1] = 2; cnt_pos[7][2] = 1; cnt_pos[7][3] = 4; cnt_pos[7][4] = 3;
		cnt_pos[8][0] = 0; cnt_pos[8][1] = 2; cnt_pos[8][2] = 3; cnt_pos[8][3] = 1; cnt_pos[8][4] = 4;
		cnt_pos[9][0] = 0; cnt_pos[9][1] = 2; cnt_pos[9][2] = 3; cnt_pos[9][3] = 4; cnt_pos[9][4] = 1;
		cnt_pos[10][0] = 0; cnt_pos[10][1] = 2; cnt_pos[10][2] = 4; cnt_pos[10][3] = 3; cnt_pos[10][4] = 1;
		cnt_pos[11][0] = 0; cnt_pos[11][1] = 2; cnt_pos[11][2] = 4; cnt_pos[11][3] = 1; cnt_pos[11][4] = 3;
		cnt_pos[12][0] = 0; cnt_pos[12][1] = 3; cnt_pos[12][2] = 1; cnt_pos[12][3] = 2; cnt_pos[12][4] = 4;
		cnt_pos[13][0] = 0; cnt_pos[13][1] = 3; cnt_pos[13][2] = 1; cnt_pos[13][3] = 4; cnt_pos[13][4] = 2;
		cnt_pos[14][0] = 0; cnt_pos[14][1] = 3; cnt_pos[14][2] = 2; cnt_pos[14][3] = 1; cnt_pos[14][4] = 4;
		cnt_pos[15][0] = 0; cnt_pos[15][1] = 3; cnt_pos[15][2] = 2; cnt_pos[15][3] = 4; cnt_pos[15][4] = 1;
		cnt_pos[16][0] = 0; cnt_pos[16][1] = 3; cnt_pos[16][2] = 4; cnt_pos[16][3] = 1; cnt_pos[16][4] = 2;
		cnt_pos[17][0] = 0; cnt_pos[17][1] = 3; cnt_pos[17][2] = 4; cnt_pos[17][3] = 2; cnt_pos[17][4] = 1;
		cnt_pos[18][0] = 0; cnt_pos[18][1] = 4; cnt_pos[18][2] = 2; cnt_pos[18][3] = 3; cnt_pos[18][4] = 1;
		cnt_pos[19][0] = 0; cnt_pos[19][1] = 4; cnt_pos[19][2] = 2; cnt_pos[19][3] = 1; cnt_pos[19][4] = 3;
		cnt_pos[20][0] = 0; cnt_pos[20][1] = 4; cnt_pos[20][2] = 3; cnt_pos[20][3] = 1; cnt_pos[20][4] = 2;
		cnt_pos[21][0] = 0; cnt_pos[21][1] = 4; cnt_pos[21][2] = 3; cnt_pos[21][3] = 2; cnt_pos[21][4] = 1;
		cnt_pos[22][0] = 0; cnt_pos[22][1] = 4; cnt_pos[22][2] = 1; cnt_pos[22][3] = 3; cnt_pos[22][4] = 2;
		cnt_pos[23][0] = 0; cnt_pos[23][1] = 4; cnt_pos[23][2] = 1; cnt_pos[23][3] = 2; cnt_pos[23][4] = 3;
		
		cnt_pos[24][0] = 1; cnt_pos[24][1] = 0; cnt_pos[24][2] = 2; cnt_pos[24][3] = 3; cnt_pos[24][4] = 4;
		cnt_pos[25][0] = 1; cnt_pos[25][1] = 0; cnt_pos[25][2] = 2; cnt_pos[25][3] = 4; cnt_pos[25][4] = 3;
		cnt_pos[26][0] = 1; cnt_pos[26][1] = 0; cnt_pos[26][2] = 3; cnt_pos[26][3] = 2; cnt_pos[26][4] = 4;
		cnt_pos[27][0] = 1; cnt_pos[27][1] = 0; cnt_pos[27][2] = 3; cnt_pos[27][3] = 4; cnt_pos[27][4] = 2;
		cnt_pos[28][0] = 1; cnt_pos[28][1] = 0; cnt_pos[28][2] = 4; cnt_pos[28][3] = 2; cnt_pos[28][4] = 3;
		cnt_pos[29][0] = 1; cnt_pos[29][1] = 0; cnt_pos[29][2] = 4; cnt_pos[29][3] = 3; cnt_pos[29][4] = 2;
		cnt_pos[30][0] = 1; cnt_pos[30][1] = 2; cnt_pos[30][2] = 0; cnt_pos[30][3] = 3; cnt_pos[30][4] = 4;
		cnt_pos[31][0] = 1; cnt_pos[31][1] = 2; cnt_pos[31][2] = 0; cnt_pos[31][3] = 4; cnt_pos[31][4] = 3;
		cnt_pos[32][0] = 1; cnt_pos[32][1] = 2; cnt_pos[32][2] = 3; cnt_pos[32][3] = 0; cnt_pos[32][4] = 4;
		cnt_pos[33][0] = 1; cnt_pos[33][1] = 2; cnt_pos[33][2] = 3; cnt_pos[33][3] = 4; cnt_pos[33][4] = 0;
		cnt_pos[34][0] = 1; cnt_pos[34][1] = 2; cnt_pos[34][2] = 4; cnt_pos[34][3] = 3; cnt_pos[34][4] = 0;
		cnt_pos[35][0] = 1; cnt_pos[35][1] = 2; cnt_pos[35][2] = 4; cnt_pos[35][3] = 0; cnt_pos[35][4] = 3;
		cnt_pos[36][0] = 1; cnt_pos[36][1] = 3; cnt_pos[36][2] = 0; cnt_pos[36][3] = 2; cnt_pos[36][4] = 4;
		cnt_pos[37][0] = 1; cnt_pos[37][1] = 3; cnt_pos[37][2] = 0; cnt_pos[37][3] = 4; cnt_pos[37][4] = 2;
		cnt_pos[38][0] = 1; cnt_pos[38][1] = 3; cnt_pos[38][2] = 2; cnt_pos[38][3] = 0; cnt_pos[38][4] = 4;
		cnt_pos[39][0] = 1; cnt_pos[39][1] = 3; cnt_pos[39][2] = 2; cnt_pos[39][3] = 4; cnt_pos[39][4] = 0;
		cnt_pos[40][0] = 1; cnt_pos[40][1] = 3; cnt_pos[40][2] = 4; cnt_pos[40][3] = 0; cnt_pos[40][4] = 2;
		cnt_pos[41][0] = 1; cnt_pos[41][1] = 3; cnt_pos[41][2] = 4; cnt_pos[41][3] = 2; cnt_pos[41][4] = 0;
		cnt_pos[42][0] = 1; cnt_pos[42][1] = 4; cnt_pos[42][2] = 0; cnt_pos[42][3] = 2; cnt_pos[42][4] = 3;
		cnt_pos[43][0] = 1; cnt_pos[43][1] = 4; cnt_pos[43][2] = 0; cnt_pos[43][3] = 3; cnt_pos[43][4] = 2;
		cnt_pos[44][0] = 1; cnt_pos[44][1] = 4; cnt_pos[44][2] = 3; cnt_pos[44][3] = 0; cnt_pos[44][4] = 2;
		cnt_pos[45][0] = 1; cnt_pos[45][1] = 4; cnt_pos[45][2] = 3; cnt_pos[45][3] = 2; cnt_pos[45][4] = 0;
		cnt_pos[46][0] = 1; cnt_pos[46][1] = 4; cnt_pos[46][2] = 2; cnt_pos[46][3] = 3; cnt_pos[46][4] = 0;
		cnt_pos[47][0] = 1; cnt_pos[47][1] = 4; cnt_pos[47][2] = 2; cnt_pos[47][3] = 0; cnt_pos[47][4] = 3;
		
		cnt_pos[48][0] = 2; cnt_pos[48][1] = 0; cnt_pos[48][2] = 1; cnt_pos[48][3] = 3; cnt_pos[48][4] = 4;
		cnt_pos[49][0] = 2; cnt_pos[49][1] = 0; cnt_pos[49][2] = 1; cnt_pos[49][3] = 4; cnt_pos[49][4] = 3;
		cnt_pos[50][0] = 2; cnt_pos[50][1] = 0; cnt_pos[50][2] = 3; cnt_pos[50][3] = 1; cnt_pos[50][4] = 4;
		cnt_pos[51][0] = 2; cnt_pos[51][1] = 0; cnt_pos[51][2] = 3; cnt_pos[51][3] = 4; cnt_pos[51][4] = 1;
		cnt_pos[52][0] = 2; cnt_pos[52][1] = 0; cnt_pos[52][2] = 4; cnt_pos[52][3] = 3; cnt_pos[52][4] = 1;
		cnt_pos[53][0] = 2; cnt_pos[53][1] = 0; cnt_pos[53][2] = 4; cnt_pos[53][3] = 1; cnt_pos[53][4] = 3;
		cnt_pos[54][0] = 2; cnt_pos[54][1] = 1; cnt_pos[54][2] = 0; cnt_pos[54][3] = 3; cnt_pos[54][4] = 4;
		cnt_pos[55][0] = 2; cnt_pos[55][1] = 1; cnt_pos[55][2] = 0; cnt_pos[55][3] = 4; cnt_pos[55][4] = 3;
		cnt_pos[56][0] = 2; cnt_pos[56][1] = 1; cnt_pos[56][2] = 3; cnt_pos[56][3] = 0; cnt_pos[56][4] = 4;
		cnt_pos[57][0] = 2; cnt_pos[57][1] = 1; cnt_pos[57][2] = 3; cnt_pos[57][3] = 4; cnt_pos[57][4] = 0;
		cnt_pos[58][0] = 2; cnt_pos[58][1] = 1; cnt_pos[58][2] = 4; cnt_pos[58][3] = 0; cnt_pos[58][4] = 3;
		cnt_pos[59][0] = 2; cnt_pos[59][1] = 1; cnt_pos[59][2] = 4; cnt_pos[59][3] = 3; cnt_pos[59][4] = 0;
		cnt_pos[60][0] = 2; cnt_pos[60][1] = 3; cnt_pos[60][2] = 0; cnt_pos[60][3] = 4; cnt_pos[60][4] = 1;
		cnt_pos[61][0] = 2; cnt_pos[61][1] = 3; cnt_pos[61][2] = 0; cnt_pos[61][3] = 1; cnt_pos[61][4] = 4;
		cnt_pos[62][0] = 2; cnt_pos[62][1] = 3; cnt_pos[62][2] = 4; cnt_pos[62][3] = 0; cnt_pos[62][4] = 1;
		cnt_pos[63][0] = 2; cnt_pos[63][1] = 3; cnt_pos[63][2] = 4; cnt_pos[63][3] = 1; cnt_pos[63][4] = 0;
		cnt_pos[64][0] = 2; cnt_pos[64][1] = 3; cnt_pos[64][2] = 1; cnt_pos[64][3] = 0; cnt_pos[64][4] = 4;
		cnt_pos[65][0] = 2; cnt_pos[65][1] = 3; cnt_pos[65][2] = 1; cnt_pos[65][3] = 4; cnt_pos[65][4] = 0;
		cnt_pos[66][0] = 2; cnt_pos[66][1] = 4; cnt_pos[66][2] = 3; cnt_pos[66][3] = 0; cnt_pos[66][4] = 1;
		cnt_pos[67][0] = 2; cnt_pos[67][1] = 4; cnt_pos[67][2] = 3; cnt_pos[67][3] = 1; cnt_pos[67][4] = 0;
		cnt_pos[68][0] = 2; cnt_pos[68][1] = 4; cnt_pos[68][2] = 1; cnt_pos[68][3] = 0; cnt_pos[68][4] = 3;
		cnt_pos[69][0] = 2; cnt_pos[69][1] = 4; cnt_pos[69][2] = 1; cnt_pos[69][3] = 3; cnt_pos[69][4] = 0;
		cnt_pos[70][0] = 2; cnt_pos[70][1] = 4; cnt_pos[70][2] = 0; cnt_pos[70][3] = 3; cnt_pos[70][4] = 1;
		cnt_pos[71][0] = 2; cnt_pos[71][1] = 4; cnt_pos[71][2] = 0; cnt_pos[71][3] = 1; cnt_pos[71][4] = 3;
		
		cnt_pos[72][0] = 3; cnt_pos[72][1] = 1; cnt_pos[72][2] = 2; cnt_pos[72][3] = 4; cnt_pos[72][4] = 0;
		cnt_pos[73][0] = 3; cnt_pos[73][1] = 1; cnt_pos[73][2] = 2; cnt_pos[73][3] = 0; cnt_pos[73][4] = 4;
		cnt_pos[74][0] = 3; cnt_pos[74][1] = 1; cnt_pos[74][2] = 0; cnt_pos[74][3] = 4; cnt_pos[74][4] = 2;
		cnt_pos[75][0] = 3; cnt_pos[75][1] = 1; cnt_pos[75][2] = 0; cnt_pos[75][3] = 2; cnt_pos[75][4] = 4;
		cnt_pos[76][0] = 3; cnt_pos[76][1] = 1; cnt_pos[76][2] = 4; cnt_pos[76][3] = 0; cnt_pos[76][4] = 2;
		cnt_pos[77][0] = 3; cnt_pos[77][1] = 1; cnt_pos[77][2] = 4; cnt_pos[77][3] = 2; cnt_pos[77][4] = 0;
		cnt_pos[78][0] = 3; cnt_pos[78][1] = 2; cnt_pos[78][2] = 0; cnt_pos[78][3] = 4; cnt_pos[78][4] = 1;
		cnt_pos[79][0] = 3; cnt_pos[79][1] = 2; cnt_pos[79][2] = 0; cnt_pos[79][3] = 1; cnt_pos[79][4] = 4;
		cnt_pos[80][0] = 3; cnt_pos[80][1] = 2; cnt_pos[80][2] = 1; cnt_pos[80][3] = 0; cnt_pos[80][4] = 4;
		cnt_pos[81][0] = 3; cnt_pos[81][1] = 2; cnt_pos[81][2] = 1; cnt_pos[81][3] = 4; cnt_pos[81][4] = 0;
		cnt_pos[82][0] = 3; cnt_pos[82][1] = 2; cnt_pos[82][2] = 4; cnt_pos[82][3] = 0; cnt_pos[82][4] = 1;
		cnt_pos[83][0] = 3; cnt_pos[83][1] = 2; cnt_pos[83][2] = 4; cnt_pos[83][3] = 1; cnt_pos[83][4] = 0;
		cnt_pos[84][0] = 3; cnt_pos[84][1] = 4; cnt_pos[84][2] = 2; cnt_pos[84][3] = 0; cnt_pos[84][4] = 1;
		cnt_pos[85][0] = 3; cnt_pos[85][1] = 4; cnt_pos[85][2] = 2; cnt_pos[85][3] = 1; cnt_pos[85][4] = 0;
		cnt_pos[86][0] = 3; cnt_pos[86][1] = 4; cnt_pos[86][2] = 0; cnt_pos[86][3] = 1; cnt_pos[86][4] = 2;
		cnt_pos[87][0] = 3; cnt_pos[87][1] = 4; cnt_pos[87][2] = 0; cnt_pos[87][3] = 2; cnt_pos[87][4] = 1;
		cnt_pos[88][0] = 3; cnt_pos[88][1] = 4; cnt_pos[88][2] = 1; cnt_pos[88][3] = 0; cnt_pos[88][4] = 2;
		cnt_pos[89][0] = 3; cnt_pos[89][1] = 4; cnt_pos[89][2] = 1; cnt_pos[89][3] = 2; cnt_pos[89][4] = 0;
		cnt_pos[90][0] = 3; cnt_pos[90][1] = 0; cnt_pos[90][2] = 2; cnt_pos[90][3] = 4; cnt_pos[90][4] = 1;
		cnt_pos[91][0] = 3; cnt_pos[91][1] = 0; cnt_pos[91][2] = 2; cnt_pos[91][3] = 1; cnt_pos[91][4] = 4;
		cnt_pos[92][0] = 3; cnt_pos[92][1] = 0; cnt_pos[92][2] = 1; cnt_pos[92][3] = 4; cnt_pos[92][4] = 2;
		cnt_pos[93][0] = 3; cnt_pos[93][1] = 0; cnt_pos[93][2] = 1; cnt_pos[93][3] = 2; cnt_pos[93][4] = 4;
		cnt_pos[94][0] = 3; cnt_pos[94][1] = 0; cnt_pos[94][2] = 4; cnt_pos[94][3] = 1; cnt_pos[94][4] = 2;
		cnt_pos[95][0] = 3; cnt_pos[95][1] = 0; cnt_pos[95][2] = 4; cnt_pos[95][3] = 2; cnt_pos[95][4] = 1;
		
		cnt_pos[96][0] = 4; cnt_pos[96][1] = 1; cnt_pos[96][2] = 2; cnt_pos[96][3] = 3; cnt_pos[96][4] = 0;
		cnt_pos[97][0] = 4; cnt_pos[97][1] = 1; cnt_pos[97][2] = 2; cnt_pos[97][3] = 0; cnt_pos[97][4] = 3;
		cnt_pos[98][0] = 4; cnt_pos[98][1] = 1; cnt_pos[98][2] = 3; cnt_pos[98][3] = 0; cnt_pos[98][4] = 2;
		cnt_pos[99][0] = 4; cnt_pos[99][1] = 1; cnt_pos[99][2] = 3; cnt_pos[99][3] = 2; cnt_pos[99][4] = 0;
		cnt_pos[100][0] = 4; cnt_pos[100][1] = 1; cnt_pos[100][2] = 0; cnt_pos[100][3] = 3; cnt_pos[100][4] = 2;
		cnt_pos[101][0] = 4; cnt_pos[101][1] = 1; cnt_pos[101][2] = 0; cnt_pos[101][3] = 2; cnt_pos[101][4] = 3;
		cnt_pos[102][0] = 4; cnt_pos[102][1] = 2; cnt_pos[102][2] = 1; cnt_pos[102][3] = 0; cnt_pos[102][4] = 3;
		cnt_pos[103][0] = 4; cnt_pos[103][1] = 2; cnt_pos[103][2] = 1; cnt_pos[103][3] = 3; cnt_pos[103][4] = 0;
		cnt_pos[104][0] = 4; cnt_pos[104][1] = 2; cnt_pos[104][2] = 3; cnt_pos[104][3] = 0; cnt_pos[104][4] = 1;
		cnt_pos[105][0] = 4; cnt_pos[105][1] = 2; cnt_pos[105][2] = 3; cnt_pos[105][3] = 1; cnt_pos[105][4] = 0;
		cnt_pos[106][0] = 4; cnt_pos[106][1] = 2; cnt_pos[106][2] = 0; cnt_pos[106][3] = 3; cnt_pos[106][4] = 1;
		cnt_pos[107][0] = 4; cnt_pos[107][1] = 2; cnt_pos[107][2] = 0; cnt_pos[107][3] = 1; cnt_pos[107][4] = 3;
		cnt_pos[108][0] = 4; cnt_pos[108][1] = 3; cnt_pos[108][2] = 2; cnt_pos[108][3] = 0; cnt_pos[108][4] = 1;
		cnt_pos[109][0] = 4; cnt_pos[109][1] = 3; cnt_pos[109][2] = 2; cnt_pos[109][3] = 1; cnt_pos[109][4] = 0;
		cnt_pos[110][0] = 4; cnt_pos[110][1] = 3; cnt_pos[110][2] = 1; cnt_pos[110][3] = 0; cnt_pos[110][4] = 2;
		cnt_pos[111][0] = 4; cnt_pos[111][1] = 3; cnt_pos[111][2] = 1; cnt_pos[111][3] = 2; cnt_pos[111][4] = 0;
		cnt_pos[112][0] = 4; cnt_pos[112][1] = 3; cnt_pos[112][2] = 0; cnt_pos[112][3] = 1; cnt_pos[112][4] = 2;
		cnt_pos[113][0] = 4; cnt_pos[113][1] = 3; cnt_pos[113][2] = 0; cnt_pos[113][3] = 2; cnt_pos[113][4] = 1;
		cnt_pos[114][0] = 4; cnt_pos[114][1] = 0; cnt_pos[114][2] = 2; cnt_pos[114][3] = 3; cnt_pos[114][4] = 1;
		cnt_pos[115][0] = 4; cnt_pos[115][1] = 0; cnt_pos[115][2] = 2; cnt_pos[115][3] = 1; cnt_pos[115][4] = 3;
		cnt_pos[116][0] = 4; cnt_pos[116][1] = 0; cnt_pos[116][2] = 3; cnt_pos[116][3] = 2; cnt_pos[116][4] = 1;
		cnt_pos[117][0] = 4; cnt_pos[117][1] = 0; cnt_pos[117][2] = 3; cnt_pos[117][3] = 1; cnt_pos[117][4] = 2;
		cnt_pos[118][0] = 4; cnt_pos[118][1] = 0; cnt_pos[118][2] = 1; cnt_pos[118][3] = 3; cnt_pos[118][4] = 2;
		cnt_pos[119][0] = 4; cnt_pos[119][1] = 0; cnt_pos[119][2] = 1; cnt_pos[119][3] = 2; cnt_pos[119][4] = 3;
    end
end

always @(*) begin
	if(key[cnt0] == ans[0]) begin					//1A
		if(key[cnt1] == ans[1]) begin				//2A
			if(key[cnt2] == ans[2]) begin			//3A
				if(key[cnt3] == ans[3]) begin		//4A
					if(key[cnt4] == ans[4]) begin	//5A
						cnt_a = 5;
						cnt_b = 0;
					end
					else begin								//4A
						cnt_a = 4;
						cnt_b = 0;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//4A1B
						cnt_a = 4;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else begin
						cnt_a = 3;
						cnt_b = 1;
					end
				end
				else begin
					if(key[cnt4] == ans[4]) begin	//4A
						cnt_a = 4;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else begin
						cnt_a = 3;
						cnt_b = 0;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//3A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 4;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else begin
						cnt_a = 3;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else begin									//2A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
			end
			else begin										//2A
				if(key[cnt3] == ans[3]) begin		//3A
					if(key[cnt4] == ans[4]) begin
						cnt_a = 4;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else begin
						cnt_a = 3;
						cnt_b = 0;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else begin									//2A
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else begin
						cnt_a = 2;
						cnt_b = 0;
					end
				end
			end
		end
		else if(key[cnt1] == ans[2] || key[cnt1] == ans[3] || key[cnt1] == ans[4] || key[cnt1] == ans[0]) begin
			if(key[cnt2] == ans[2]) begin			//2A1B
				if(key[cnt3] == ans[3]) begin		//3A1B
					if(key[cnt4] == ans[4]) begin	//4A1B
						cnt_a = 4;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else begin								//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//3A2B
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else begin									//2A1B
					if(key[cnt4] == ans[4]) begin	//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//2A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 4;
					end
					else begin
						cnt_a = 1;
						cnt_b = 3;
					end
				end
				else begin									//1A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
			end
			else begin										//1A1B
				if(key[cnt3] == ans[3]) begin		//2A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else begin									//1A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
			end
		end
		else begin											//1A				
			if(key[cnt2] == ans[2]) begin			//2A
				if(key[cnt3] == ans[3]) begin		//3A
					if(key[cnt4] == ans[4]) begin	//4A
						cnt_a = 4;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else begin								//3A
						cnt_a = 3;
						cnt_b = 0;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else begin									//2A
					if(key[cnt4] == ans[4]) begin	//3A
						cnt_a = 3;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else begin
						cnt_a = 2;
						cnt_b = 0;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//2A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else begin									//1A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
			end
			else begin										//1A
				if(key[cnt3] == ans[3]) begin		//2A
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 0;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else begin
						cnt_a = 2;
						cnt_b = 0;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
				else begin									//1A
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 0;
					end
					else begin
						//can use else
						cnt_a = 1;
						cnt_b = 1;
					end
				end
			end
		end
	end
	else if(key[cnt0] == ans[1] || key[cnt0] == ans[2] || key[cnt0] == ans[3] || key[cnt0] == ans[4]) begin
		if(key[cnt1] == ans[1]) begin				//1A1B
			if(key[cnt2] == ans[2]) begin			//2A1B
				if(key[cnt3] == ans[3]) begin		//3A1B
					if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else begin								//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//3A2B
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else begin
					if(key[cnt4] == ans[4]) begin	//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//2A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 4;
					end
					else begin
						cnt_a = 1;
						cnt_b = 3;
					end
				end
				else begin									//1A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
			end
			else begin										//1A1B
				if(key[cnt3] == ans[3]) begin		//2A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else begin									//1A1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
			end
		end
		else if(key[cnt1] == ans[2] || key[cnt1] == ans[3] || key[cnt1] == ans[4] || key[cnt1] == ans[0]) begin
			if(key[cnt2] == ans[2]) begin			//1A2B
				if(key[cnt3] == ans[3]) begin		//2A2B
					if(key[cnt4] == ans[4]) begin	//3A2B
						cnt_a = 3;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else begin								//2A2B
						cnt_a = 2;
						cnt_b = 2;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//2A3B
						cnt_a = 2;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 4;
					end
					else begin
						cnt_a = 1;
						cnt_b = 3;
					end
				end
				else begin									//1A2B
					if(key[cnt4] == ans[4]) begin	//2A2B
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//1A3B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 4;
					end
					else begin
						cnt_a = 1;
						cnt_b = 3;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 4;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 5;
					end
					else begin
						cnt_a = 0;
						cnt_b = 4;
					end
				end
				else begin									//0A3B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 4;
					end
					else begin
						cnt_a = 0;
						cnt_b = 3;
					end
				end
			end
			else begin										//0A2B
				if(key[cnt3] == ans[3]) begin		//1A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 4;
					end
					else begin
						cnt_a = 0;
						cnt_b = 3;
					end
				end
				else begin									//0A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 3;
					end
					else begin
						cnt_a = 0;
						cnt_b = 2;
					end
				end
			end
		end
		else begin											//1B
			if(key[cnt2] == ans[2]) begin			//1A1B
				if(key[cnt3] == ans[3]) begin		//2A1B
					if(key[cnt4] == ans[4]) begin	//3A1B
						cnt_a = 3;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else begin								//2A1B
						cnt_a = 2;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//2A2B
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else begin									//1A1B
					if(key[cnt4] == ans[4]) begin	//2A1B
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
			end
			else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
				if(key[cnt3] == ans[3]) begin		//1A2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 2;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else begin
						cnt_a = 1;
						cnt_b = 2;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 3;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 4;
					end
					else begin
						cnt_a = 0;
						cnt_b = 3;
					end
				end
				else begin									//2B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 3;
					end
					else begin
						cnt_a = 0;
						cnt_b = 2;
					end
				end
			end
			else begin										//1B
				if(key[cnt3] == ans[3]) begin		//1A1B
					if(key[cnt4] == ans[4]) begin	//2A1B
						cnt_a = 2;
						cnt_b = 1;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 1;
						cnt_b = 2;
					end
					else begin
						cnt_a = 1;
						cnt_b = 1;
					end
				end
				else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
					if(key[cnt4] == ans[4]) begin	//1A2B
						cnt_a = 1;
						cnt_b = 2;
					end
					else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
						cnt_a = 0;
						cnt_b = 3;
					end
					else begin
						cnt_a = 0;
						cnt_b = 2;
					end
				end
				else begin									//1B
					if(key[cnt4] == ans[4]) begin
						cnt_a = 1;
						cnt_b = 1;
					end
					else begin
						//can use else
						cnt_a = 0;
						cnt_b = 2;
					end
				end
			end
		end
	end
	else begin
			if(key[cnt1] == ans[1]) begin				//1A
				if(key[cnt2] == ans[2]) begin			//2A
					if(key[cnt3] == ans[3]) begin		//3A
						if(key[cnt4] == ans[4]) begin	//4A
							cnt_a = 4;
							cnt_b = 0;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 3;
							cnt_b = 1;
						end
						else begin								//3A
							cnt_a = 3;
							cnt_b = 0;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin	//3A1B
							cnt_a = 3;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 2;
						end
						else begin
							cnt_a = 2;
							cnt_b = 1;
						end
					end
					else begin									//2A
						if(key[cnt4] == ans[4]) begin	//3A
							cnt_a = 3;
							cnt_b = 0;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else begin
							cnt_a = 2;
							cnt_b = 0;
						end
					end
				end
				else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
					if(key[cnt3] == ans[3]) begin		//2A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 3;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 2;
						end
						else begin
							cnt_a = 2;
							cnt_b = 1;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 3;
						end
						else begin
							cnt_a = 1;
							cnt_b = 2;
						end
					end
					else begin									//1A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
				end
				else begin										//1A
					if(key[cnt3] == ans[3]) begin		//2A
						if(key[cnt4] == ans[4]) begin
							cnt_a = 3;
							cnt_b = 0;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else begin
							cnt_a = 2;
							cnt_b = 0;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
					else begin									//1A
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 0;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 1;
						end
						else begin
							cnt_a = 1;
							cnt_b = 0;
						end
					end
				end
			end
			else if(key[cnt1] == ans[2] || key[cnt1] == ans[3] || key[cnt1] == ans[4] || key[cnt1] == ans[0]) begin
				if(key[cnt2] == ans[2]) begin			//1A1B
					if(key[cnt3] == ans[3]) begin		//2A1B
						if(key[cnt4] == ans[4]) begin	//3A1B
							cnt_a = 3;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 2;
						end
						else begin								//2A1B
							cnt_a = 2;
							cnt_b = 1;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin	//2A2B
							cnt_a = 2;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 3;
						end
						else begin
							cnt_a = 1;
							cnt_b = 2;
						end
					end
					else begin									//1A1B
						if(key[cnt4] == ans[4]) begin	//2A1B
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
				end
				else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
					if(key[cnt3] == ans[3]) begin		//1A2B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 3;
						end
						else begin
							cnt_a = 1;
							cnt_b = 2;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 3;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 0;
							cnt_b = 4;
						end
						else begin
							cnt_a = 0;
							cnt_b = 3;
						end
					end
					else begin									//0A2B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 0;
							cnt_b = 3;
						end
						else begin
							cnt_a = 0;
							cnt_b = 2;
						end
					end
				end
				else begin										//0A1B
					if(key[cnt3] == ans[3]) begin		//1A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 0;
							cnt_b = 3;
						end
						else begin
							cnt_a = 0;
							cnt_b = 2;
						end
					end
					else begin									//0A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 1;
						end
						else begin
							//can use else
							cnt_a = 0;
							cnt_b = 2;
						end
					end
				end
			end
			else begin											//0				
				if(key[cnt2] == ans[2]) begin			//1A
					if(key[cnt3] == ans[3]) begin		//2A
						if(key[cnt4] == ans[4]) begin	//3A
							cnt_a = 3;
							cnt_b = 0;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else begin								//3A
							cnt_a = 2;
							cnt_b = 0;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin	//1A1B
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
					else begin									//1A
						if(key[cnt4] == ans[4]) begin	//2A
							cnt_a = 2;
							cnt_b = 0;
						end
						else begin
							//can use else
							cnt_a = 1;
							cnt_b = 1;
						end
					end
				end
				else if(key[cnt2] == ans[3] || key[cnt2] == ans[4] || key[cnt2] == ans[0] || key[cnt2] == ans[1]) begin
					if(key[cnt3] == ans[3]) begin		//1A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 1;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else begin
							cnt_a = 1;
							cnt_b = 1;
						end
					end
					else if(key[cnt3] == ans[4] || key[cnt3] == ans[0] || key[cnt3] == ans[1] || key[cnt3] == ans[2]) begin
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 2;
						end
						else if(key[cnt4] == ans[0] || key[cnt4] == ans[1] || key[cnt4] == ans[2] || key[cnt4] == ans[3]) begin
							cnt_a = 0;
							cnt_b = 3;
						end
						else begin
							cnt_a = 0;
							cnt_b = 2;
						end
					end
					else begin									//0A1B
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 1;
						end
						else begin
							//can use else
							cnt_a = 0;
							cnt_b = 2;
						end
					end
				end
				else begin										//0
					if(key[cnt3] == ans[3]) begin		//1A
						if(key[cnt4] == ans[4]) begin
							cnt_a = 2;
							cnt_b = 0;
						end
						else begin
							//can use else
							cnt_a = 1;
							cnt_b = 1;
						end
					end
					else begin
						//can use else
						if(key[cnt4] == ans[4]) begin
							cnt_a = 1;
							cnt_b = 1;
						end
						else begin
							//can use else
							cnt_a = 0;
							cnt_b = 2;
						end
					end
				end
			end
		end
	
	
end

// Output Logic
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
		out_valid <= 0;
		result <= 0;
		out_value <= 0;
		cnt <= 0;
		cnt0 <= cnt_reg[0][0];
		cnt1 <= cnt_reg[0][1];
		cnt2 <= cnt_reg[0][2];
		cnt3 <= cnt_reg[0][3];
		cnt4 <= cnt_reg[0][4];

		cnt_56 <= 0;
		cnt_120 <= 0;
		cnt_out <= 0;
		resultsss[0] <= 0;
		resultsss[1] <= 0;
		resultsss[2] <= 0;
		resultsss[3] <= 0;
		resultsss[4] <= 0 ;
		
		cnt_cal <= 0;
		out_val <= 0;
		
		outs <= 0;
		finish <= 0;
	end
	else begin
		case (current_state)
			IDLE: begin
				cnt0 <= cnt_reg[0][0];
				cnt1 <= cnt_reg[0][1];
				cnt2 <= cnt_reg[0][2];
				cnt3 <= cnt_reg[0][3];
				cnt4 <= cnt_reg[0][4];
				
				resultsss[0] <= 0;
				resultsss[1] <= 0;
				resultsss[2] <= 0;
				resultsss[3] <= 0;
				resultsss[4] <= 0;
				outs <= 0;
				
				cnt_56 <= 1;
				cnt_120 <= 0;
				
				if(in_valid) begin
					key[cnt] <= keyboard;
					ans[cnt] <= answer;
					wei[cnt] <= weight;
					mat_a <= match_target;
					cnt <= cnt + 1;
				end
				else begin
					cnt <= 0;
					cnt_cal <= 0;
				end
			end
            INPUT: begin
				if(cnt < 2) begin
					key[cnt] <= keyboard;
					ans[cnt] <= answer;
					wei[cnt] <= weight;
					mat_b <= match_target;
				end
				else if(cnt < 6) begin
					key[cnt] <= keyboard;
					ans[cnt] <= answer;
					wei[cnt] <= weight;
				end
				else begin
					key[cnt] <= keyboard;
				end
				cnt <= cnt + 1;
			end
            CAL: begin
				cnt0 <= cnt_reg[cnt_56][cnt_pos[cnt_120][0]];
				cnt1 <= cnt_reg[cnt_56][cnt_pos[cnt_120][1]];
				cnt2 <= cnt_reg[cnt_56][cnt_pos[cnt_120][2]];
				cnt3 <= cnt_reg[cnt_56][cnt_pos[cnt_120][3]];
				cnt4 <= cnt_reg[cnt_56][cnt_pos[cnt_120][4]];
				
				if(cnt_56 == 55) begin
					cnt_56 <= 0;
					cnt_120 <= cnt_120 + 1;
				end
				else begin
					cnt_56 <= cnt_56 + 1;
				end
				if(cnt_120 == 120 && cnt_56 == 1) begin
					out_valid <= 1;
					cnt_out <= cnt_out + 1;
					out_value <= outs;
					result <= resultsss[cnt_out];
					
				end
				if(cnt_a == mat_a && cnt_b == mat_b) begin
					if(outs < key[cnt0]*wei[0] + key[cnt1]*wei[1] + key[cnt2]*wei[2] + key[cnt3]*wei[3] + key[cnt4]*wei[4]) begin
						outs  <= key[cnt0]*wei[0] + key[cnt1]*wei[1] + key[cnt2]*wei[2] + key[cnt3]*wei[3] + key[cnt4]*wei[4];
						resultsss[0] <= key[cnt0];
						resultsss[1] <= key[cnt1];
						resultsss[2] <= key[cnt2];
						resultsss[3] <= key[cnt3];
						resultsss[4] <= key[cnt4];
					end
					else if(outs == key[cnt0]*wei[0] + key[cnt1]*wei[1] + key[cnt2]*wei[2] + key[cnt3]*wei[3] + key[cnt4]*wei[4]) begin
						if(resultsss[0]*16 + resultsss[1]*8 + resultsss[2]*4 + resultsss[3]*2 + resultsss[4] < key[cnt0]*16 + key[cnt1]*8 + key[cnt2]*4 + key[cnt3]*2 + key[cnt4]) begin
							resultsss[0] <= key[cnt0];
							resultsss[1] <= key[cnt1];
							resultsss[2] <= key[cnt2];
							resultsss[3] <= key[cnt3];
							resultsss[4] <= key[cnt4];
						end
						else if(resultsss[0]*16 + resultsss[1]*8 + resultsss[2]*4 + resultsss[3]*2 + resultsss[4] == key[cnt0]*16 + key[cnt1]*8 + key[cnt2]*4 + key[cnt3]*2 + key[cnt4]) begin
							if(resultsss[0] > key[cnt0]) begin
								resultsss[0] <= key[cnt0];
								resultsss[1] <= key[cnt1];
								resultsss[2] <= key[cnt2];
								resultsss[3] <= key[cnt3];
								resultsss[4] <= key[cnt4];
							end
							else if(resultsss[0] == key[cnt0]) begin
								if(resultsss[1] > key[cnt1]) begin
									resultsss[0] <= key[cnt0];
									resultsss[1] <= key[cnt1];
									resultsss[2] <= key[cnt2];
									resultsss[3] <= key[cnt3];
									resultsss[4] <= key[cnt4];
								end
								else if(resultsss[1] == key[cnt1]) begin
									if(resultsss[2] > key[cnt2]) begin
										resultsss[0] <= key[cnt0];
										resultsss[1] <= key[cnt1];
										resultsss[2] <= key[cnt2];
										resultsss[3] <= key[cnt3];
										resultsss[4] <= key[cnt4];
									end
									else if(resultsss[2] == key[cnt2]) begin
										if(resultsss[3] > key[cnt3]) begin
											resultsss[0] <= key[cnt0];
											resultsss[1] <= key[cnt1];
											resultsss[2] <= key[cnt2];
											resultsss[3] <= key[cnt3];
											resultsss[4] <= key[cnt4];
										end
									end
								end
								
							end
						
						end
					end
				end
				
				
				cnt_cal <= cnt_cal + 1;
			end
			OUT: begin
				result <= resultsss[cnt_out];
				cnt_out <= cnt_out + 1;
				if(cnt_out == 5) begin
					cnt_out <= 0;
					out_valid <= 0;
				end
			end
            default: cnt_out <= 0;
        endcase
	end
end

endmodule