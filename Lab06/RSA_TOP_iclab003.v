//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_TOP.v
//   Module Name : RSA_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "RSA_IP.v"
//synopsys translate_on

module RSA_TOP (
    // Input signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Output signals
    out_valid, out_m
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_p, in_q;
input [7:0] in_e, in_c;
output reg out_valid;
output reg [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
parameter IDLE = 'd0;
parameter INPUT = 'd1;
parameter INP_ND = 'd2;
parameter CAL = 'd3;
parameter SAVE = 'd4;
parameter OUT = 'd5;

parameter WIDTH = 4;

//================================================================
// Wire & Reg Declaration
//================================================================
reg [2:0] next_state, current_state;

reg [3:0] input_p, input_q;
reg [7:0] input_e;
reg [7:0] input_c [0:7];
wire [7:0] output_n, output_d;

reg [15:0] cal_r [0:7];

reg [2:0] input_cnt;
reg [6:0] cal_cnt;
reg [2:0] save_cnt;
reg [2:0] out_cnt;

reg [7:0] in_n, in_d;
reg [15:0] out_s [0:7];

//================================================================
// DESIGN
//================================================================

RSA_IP RSA1(.IN_P(input_p), .IN_Q(input_q), .IN_E(input_e), .OUT_N(output_n), .OUT_D(output_d));

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
                if (input_cnt == 0)   next_state = INP_ND;
                else            next_state = current_state;
            end
            INP_ND: begin
                next_state = CAL;
            end
			CAL: begin
				if (cal_cnt == in_d-1)    next_state = SAVE;
				else 			next_state = current_state;
			end
            SAVE: begin
                next_state = OUT;
            end
			OUT: begin
				if (out_cnt == 0)	next_state = IDLE;
				else 			next_state = current_state;
			end
            default: 			next_state = current_state;
        endcase
    end
end

// Input
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        input_p <= 0;
        input_q <= 0;
        input_e <= 0;
        input_cnt <= 0;
    end
    else begin
        if (next_state == INPUT) begin
            input_cnt <= input_cnt + 1;
            input_c[input_cnt] <= in_c;

            if (input_cnt == 0) begin
                input_p <= in_p;
                input_q <= in_q;
                input_e <= in_e;
            end
        end
        else if (next_state == IDLE) begin
            input_p <= 0;
            input_q <= 0;
            input_e <= 0;
        end
    end
end

// Calculate
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_n <= 0;
        in_d <= 0;
        cal_cnt <= 0;
    end
    else begin
        if (next_state == INP_ND) begin
            in_n <= output_n;
            in_d <= output_d;
            cal_r[0] <= input_c[0];
            cal_r[1] <= input_c[1];
            cal_r[2] <= input_c[2];
            cal_r[3] <= input_c[3];
            cal_r[4] <= input_c[4];
            cal_r[5] <= input_c[5];
            cal_r[6] <= input_c[6];
            cal_r[7] <= input_c[7];
        end
        else if (next_state == CAL) begin
            cal_cnt <= cal_cnt + 1;
            cal_r[0] <= (cal_r[0] * input_c[0]) % in_n;
            cal_r[1] <= (cal_r[1] * input_c[1]) % in_n;
            cal_r[2] <= (cal_r[2] * input_c[2]) % in_n;
            cal_r[3] <= (cal_r[3] * input_c[3]) % in_n;
            cal_r[4] <= (cal_r[4] * input_c[4]) % in_n;
            cal_r[5] <= (cal_r[5] * input_c[5]) % in_n;
            cal_r[6] <= (cal_r[6] * input_c[6]) % in_n;
            cal_r[7] <= (cal_r[7] * input_c[7]) % in_n;
        end
        else if (next_state == SAVE) begin
            cal_cnt <= 0;
            out_s[0] <= cal_r[0];
            out_s[1] <= cal_r[1];
            out_s[2] <= cal_r[2];
            out_s[3] <= cal_r[3];
            out_s[4] <= cal_r[4];
            out_s[5] <= cal_r[5];
            out_s[6] <= cal_r[6];
            out_s[7] <= cal_r[7];
        end
    end
end

// Output
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        out_m <= 0;
        out_cnt <= 0;
    end
    else begin
        if (next_state == OUT) begin
            out_valid <= 1;
            out_m <= out_s[out_cnt];
            out_cnt <= out_cnt + 1;
        end
        else begin
            out_valid <= 0;
            out_m <= 0;
        end
    end
end

endmodule