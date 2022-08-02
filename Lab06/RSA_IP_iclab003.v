//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 4) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D
);

// ===============================================================
// Declaration
// ===============================================================
input  [WIDTH-1:0]   IN_P, IN_Q;
input  [WIDTH*2-1:0] IN_E;
output [WIDTH*2-1:0] OUT_N, OUT_D;

localparam N_LEVEL = 7;

wire signed [WIDTH*2-1:0] final_d;

// ===============================================================
// Soft IP DESIGN
// ===============================================================
genvar level_idx, node_idx;
generate
    for (level_idx = 1; level_idx <= N_LEVEL; level_idx = level_idx + 1) begin: gen_level
        if(level_idx == 1) begin: lv_1
            wire signed [WIDTH*2-1:0] s1 [0:1];

            // Initial
            assign s1[0] = (IN_P-1) * (IN_Q-1);
            assign s1[1] = IN_E;
        end
        if(level_idx == 2) begin: lv_2
            wire signed [WIDTH*2-1:0] s2 [0:1];
            wire signed [WIDTH*2-1:0] d2;

            assign s2[0] = gen_level[level_idx-1].lv_1.s1[0] - ((gen_level[level_idx-1].lv_1.s1[0] / gen_level[level_idx-1].lv_1.s1[1]) * gen_level[level_idx-1].lv_1.s1[1]);
            assign s2[1] = gen_level[level_idx-1].lv_1.s1[1];
            assign d2 = -gen_level[level_idx-1].lv_1.s1[0] / gen_level[level_idx-1].lv_1.s1[1];
        end
        if(level_idx == 3) begin: lv_3
            wire signed [WIDTH*2-1:0] s3 [0:1];
            wire signed [WIDTH*2-1:0] d3 [0:1];

            assign s3[0] = gen_level[level_idx-1].lv_2.s2[0];
            assign s3[1] = (gen_level[level_idx-1].lv_2.s2[0] == 1 || gen_level[level_idx-1].lv_2.s2[1] == 1)? gen_level[level_idx-1].lv_2.s2[1] : gen_level[level_idx-1].lv_2.s2[1] - ((gen_level[level_idx-1].lv_2.s2[1] / gen_level[level_idx-1].lv_2.s2[0]) * gen_level[level_idx-1].lv_2.s2[0]);
            assign d3[0] = gen_level[level_idx-1].lv_2.d2;
            assign d3[1] = (gen_level[level_idx-1].lv_2.s2[0] == 1 || gen_level[level_idx-1].lv_2.s2[1] == 1)? 1 : 1 - ((gen_level[level_idx-1].lv_2.s2[1] / gen_level[level_idx-1].lv_2.s2[0]) * gen_level[level_idx-1].lv_2.d2);
        end
        if(level_idx == 4) begin: lv_4
            wire signed [WIDTH*2-1:0] s4 [0:1];
            wire signed [WIDTH*2-1:0] d4 [0:1];

            assign s4[0] = (gen_level[level_idx-1].lv_3.s3[0] == 1 || gen_level[level_idx-1].lv_3.s3[1] == 1)? gen_level[level_idx-1].lv_3.s3[0] : gen_level[level_idx-1].lv_3.s3[0] - ((gen_level[level_idx-1].lv_3.s3[0] / gen_level[level_idx-1].lv_3.s3[1]) * gen_level[level_idx-1].lv_3.s3[1]);
            assign s4[1] = gen_level[level_idx-1].lv_3.s3[1];
            assign d4[0] = (gen_level[level_idx-1].lv_3.s3[0] == 1 || gen_level[level_idx-1].lv_3.s3[1] == 1)? gen_level[level_idx-1].lv_3.d3[0] : gen_level[level_idx-1].lv_3.d3[0] - ((gen_level[level_idx-1].lv_3.s3[0] / gen_level[level_idx-1].lv_3.s3[1]) * gen_level[level_idx-1].lv_3.d3[1]);
            assign d4[1] = gen_level[level_idx-1].lv_3.d3[1];
        end
        if(level_idx == 5) begin: lv_5
            wire signed [WIDTH*2-1:0] s5 [0:1];
            wire signed [WIDTH*2-1:0] d5 [0:1];

            assign s5[0] = gen_level[level_idx-1].lv_4.s4[0];
            assign s5[1] = (gen_level[level_idx-1].lv_4.s4[0] != 1 && gen_level[level_idx-1].lv_4.s4[1] != 1)? gen_level[level_idx-1].lv_4.s4[1] - ((gen_level[level_idx-1].lv_4.s4[1] / gen_level[level_idx-1].lv_4.s4[0]) * gen_level[level_idx-1].lv_4.s4[0]) : gen_level[level_idx-1].lv_4.s4[1];
            assign d5[0] = gen_level[level_idx-1].lv_4.d4[0];
            assign d5[1] = (gen_level[level_idx-1].lv_4.s4[0] != 1 && gen_level[level_idx-1].lv_4.s4[1] != 1)? gen_level[level_idx-1].lv_4.d4[1] - ((gen_level[level_idx-1].lv_4.s4[1] / gen_level[level_idx-1].lv_4.s4[0]) * gen_level[level_idx-1].lv_4.d4[0]) : gen_level[level_idx-1].lv_4.d4[1];
        end
        if(level_idx == 6) begin: lv_6
            wire signed [WIDTH*2-1:0] s6 [0:1];
            wire signed [WIDTH*2-1:0] d6 [0:1];
            
            assign s6[0] = (gen_level[level_idx-1].lv_5.s5[0] == 1 || gen_level[level_idx-1].lv_5.s5[1] == 1)? gen_level[level_idx-1].lv_5.s5[0] : gen_level[level_idx-1].lv_5.s5[0] - ((gen_level[level_idx-1].lv_5.s5[0] / gen_level[level_idx-1].lv_5.s5[1]) * gen_level[level_idx-1].lv_5.s5[1]);
            assign s6[1] = gen_level[level_idx-1].lv_5.s5[1];
            assign d6[0] = (gen_level[level_idx-1].lv_5.s5[0] == 1 || gen_level[level_idx-1].lv_5.s5[1] == 1)? gen_level[level_idx-1].lv_5.d5[0] : gen_level[level_idx-1].lv_5.d5[0] - ((gen_level[level_idx-1].lv_5.s5[0] / gen_level[level_idx-1].lv_5.s5[1]) * gen_level[level_idx-1].lv_5.d5[1]);
            assign d6[1] = gen_level[level_idx-1].lv_5.d5[1];
        end
        if(level_idx == 7) begin: lv_7
            wire signed [WIDTH*2-1:0] s7 [0:1];
            wire signed [WIDTH*2-1:0] d7 [0:1];
            
            assign s7[0] = gen_level[level_idx-1].lv_6.s6[0];
            assign s7[1] = (gen_level[level_idx-1].lv_6.s6[0] == 1 || gen_level[level_idx-1].lv_6.s6[1] == 1)? gen_level[level_idx-1].lv_6.s6[1] : gen_level[level_idx-1].lv_6.s6[1] - ((gen_level[level_idx-1].lv_6.s6[1] / gen_level[level_idx-1].lv_6.s6[0]) * gen_level[level_idx-1].lv_6.s6[0]);
            assign d7[0] = gen_level[level_idx-1].lv_6.d6[0];
            assign d7[1] = (gen_level[level_idx-1].lv_6.s6[0] == 1 || gen_level[level_idx-1].lv_6.s6[1] == 1)? gen_level[level_idx-1].lv_6.d6[1] : gen_level[level_idx-1].lv_6.d6[1] - ((gen_level[level_idx-1].lv_6.s6[1] / gen_level[level_idx-1].lv_6.s6[0]) * gen_level[level_idx-1].lv_6.d6[0]);

            assign final_d = (s7[0] != 1)? d7[1] : d7[0];
        end
    end

endgenerate

assign OUT_N = IN_P*IN_Q;
assign OUT_D = (final_d < 0)? (final_d + ((IN_P-1) * (IN_Q-1))) : final_d;


endmodule