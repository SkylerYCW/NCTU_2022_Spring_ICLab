module ESCAPE(
    //Input Port
    clk,
    rst_n,
    in_valid1,
    in_valid2,
    in,
    in_data,
    //Output Port
    out_valid1,
    out_valid2,
    out,
    out_data
);

//==================INPUT OUTPUT==================//
    input clk, rst_n, in_valid1, in_valid2;
    input [1:0] in;
    input [8:0] in_data;    
    output reg	out_valid1, out_valid2;
    output reg [2:0] out;
    output reg [8:0] out_data;
//================================================//    


parameter IDLE    = 3'd0;
parameter INPUT   = 3'd1;
parameter CAL     = 3'd2;
parameter HOST    = 3'd3;
parameter ANS1    = 3'd4;
parameter ANS2    = 3'd5;
parameter ANS3    = 3'd6;
parameter OUT     = 3'd7;


//==================Register==================//
reg [2:0] current_state, next_state;

reg [4:0] row_pos, col_pos;
reg [1:0] maze_data [0:16][0:16];
reg [2:0] hostage_num, hostage_count;
reg signed [8:0] passwd_data [0:3];
reg signed [8:0] passwd_data_r [0:3];
wire signed [8:0] in_passwd;

reg signed [8:0] passwd_data_e [0:3];
reg signed [7:0] passwd_data_even [0:3];
reg signed [7:0] passwd_data_even_r1 [0:3];
reg signed [7:0] passwd_data_even_r2 [0:3];
reg signed [7:0] passwd_data_even_r3 [0:3];
reg signed [8:0] even_max, even_min;

reg signed [8:0] passwd_data_o [0:2];
reg signed [8:0] passwd_data_odd [0:2];
reg signed [8:0] passwd_data_odd_r1 [0:2];
reg signed [8:0] passwd_data_odd_r2 [0:2];
reg signed [8:0] passwd_data_odd_r3 [0:2];
reg signed [8:0] odd_max, odd_min;


reg signed [8:0] temp;
reg [2:0] passwd_cnt;

reg [4:0] current_row, current_col;
reg [2:0] last_step;
reg stall;

reg signed [8:0] out_ans [0:3];
reg [2:0] out_cnt;

integer i, j, max, min, half;
//============================================//    

//==================Design==================//

//  Current State
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		current_state <= IDLE;
    else
		current_state <= next_state;
end

//  Next State
always @(*) begin
    if (!rst_n) next_state = IDLE;
    else begin
        case (current_state)
			IDLE: begin
				if (in_valid1)	next_state = INPUT;
				else 			next_state = current_state;
			end
            INPUT: begin
                if (row_pos == 16 && col_pos == 16)   next_state = CAL;
                else            next_state = current_state;
            end
			CAL: begin
				if (maze_data[current_row][current_col] == 3)	next_state = HOST;
                else if (hostage_count == hostage_num && (current_col == 16 && current_row == 16))
                                next_state = ANS1;
				else 			next_state = current_state;
			end
            HOST: begin
                if (in_valid2)  next_state = CAL;
                else            next_state = current_state;
            end
            ANS1: begin
                next_state = ANS2;
            end
            ANS2: begin
                next_state = ANS3;
            end
            ANS3: begin
                next_state = OUT;
            end
			OUT: begin
                if (hostage_num == 0 || hostage_num == 1)   next_state = IDLE;
				else if (out_cnt == hostage_count-1)	next_state = IDLE;
				else 			next_state = current_state;
			end
        endcase
    end
end
//Even Step1
always @(*) begin
    if (!rst_n) begin
        passwd_data_even[0] = 0;
        passwd_data_even[1] = 0;
        passwd_data_even[2] = 0;
        passwd_data_even[3] = 0;
    end
    else begin
        for (i = 0; i < 4; i = i + 1) begin
            passwd_data_even[i] = 0;
        end
        case (current_state)
            ANS1: begin
                for (i = 0; i < 4; i = i + 1) begin
                    passwd_data_even[i] = passwd_data_even[i];
                end
                if (hostage_num == 2) begin				//even
                    for (i = 0; i < 2; i = i + 1) begin
                        if (passwd_data[i][8] == 0) begin		//positive
                            passwd_data_even[i] = (passwd_data[i][3:0]-3) + ((passwd_data[i][7:4]-3) * 10);
                        end
                        else begin							//negative
                            passwd_data_even[i] = - (passwd_data[i][3:0]-3) - ((passwd_data[i][7:4]-3) * 10);
                        end
                    end
                end
                else if (hostage_num == 4) begin				//even
                    for (i = 0; i < 4; i = i + 1) begin
                        if (passwd_data[i][8] == 0) begin		//positive
                            passwd_data_even[i] = (passwd_data[i][3:0]-3) + ((passwd_data[i][7:4]-3) * 10);
                        end
                        else begin							//negative
                            passwd_data_even[i] = - (passwd_data[i][3:0]-3) - ((passwd_data[i][7:4]-3) * 10);
                        end
                    end
                end

                //Subtrsct half of range
                if (hostage_num == 2) begin
                    
                    even_max = -255;
                    even_min = 255;
                    for (i = 0; i < 2; i = i + 1) begin
                        if (even_max < passwd_data_even[i]) begin
                            even_max = passwd_data_even[i];
                        end
                        if (even_min > passwd_data_even[i]) begin
                            even_min = passwd_data_even[i];
                        end
                    end
                    
                    half = (passwd_data_even[1] + passwd_data_even[0]) / 2;
                    for (i = 0; i < 2; i = i + 1) begin
                        passwd_data_even[i] = passwd_data_even[i] - half;
                    end
                end/*
                else if (hostage_num == 4) begin
                    even_max = -255;
                    even_min = 255;
                    for (i = 0; i < 4; i = i + 1) begin
                        if (even_max < passwd_data_even[i]) begin
                            even_max = passwd_data_even[i];
                        end
                        if (even_min > passwd_data_even[i]) begin
                            even_min = passwd_data_even[i];
                        end
                    end

                    half = (even_max + even_min) / 2;
                    for (i = 0; i < 4; i = i + 1) begin
                        passwd_data_even[i] = passwd_data_even[i] - half;
                    end

                    passwd_data_even[0] = passwd_data_even[0];
                    passwd_data_even[1] = (passwd_data_even[0]*2 + passwd_data_even[1]) / 3;
                    passwd_data_even[2] = (passwd_data_even[1]*2 + passwd_data_even[2]) / 3;
                    passwd_data_even[3] = (passwd_data_even[2]*2 + passwd_data_even[3]) / 3;
                end*/
                
            end
            
            default: begin
                for (i = 0; i < 4; i = i + 1) begin
                    passwd_data_even[i] = passwd_data_even[i];
                end
            end
        endcase
    end
end

//Even Step2
always @(*) begin
    if (!rst_n) begin
        passwd_data_even_r2[0] = 0;
        passwd_data_even_r2[1] = 0;
        passwd_data_even_r2[2] = 0;
        passwd_data_even_r2[3] = 0;
    end
    else begin
        for (i = 0; i < 4; i = i + 1) begin
            passwd_data_even_r2[i] = passwd_data_even_r1[i];
        end
        case (current_state)
            ANS2: begin
                //Subtrsct half of range
                if (hostage_num == 4) begin
                    even_max = -255;
                    even_min = 255;
                    for (i = 0; i < 4; i = i + 1) begin
                        if (even_max < passwd_data_even_r2[i]) begin
                            even_max = passwd_data_even_r2[i];
                        end
                        if (even_min > passwd_data_even_r2[i]) begin
                            even_min = passwd_data_even_r2[i];
                        end
                    end

                    half = (even_max + even_min) / 2;
                    for (i = 0; i < 4; i = i + 1) begin
                        passwd_data_even_r2[i] = passwd_data_even_r2[i] - half;
                    end

                    passwd_data_even_r2[0] = passwd_data_even_r2[0];
                    passwd_data_even_r2[1] = (passwd_data_even_r2[0]*2 + passwd_data_even_r2[1]) / 3;
                    passwd_data_even_r2[2] = (passwd_data_even_r2[1]*2 + passwd_data_even_r2[2]) / 3;
                    passwd_data_even_r2[3] = (passwd_data_even_r2[2]*2 + passwd_data_even_r2[3]) / 3;
                end
            end
            default: begin
                for (i = 0; i < 4; i = i + 1) begin
                    passwd_data_even_r2[i] = passwd_data_even_r2[i];
                end
            end
        endcase
    end
end

//Odd Step1
always @(*) begin
    if (!rst_n) begin
        passwd_data_odd[0] = 0;
        passwd_data_odd[1] = 0;
        passwd_data_odd[2] = 0;
    end
    else begin
        for (i = 0; i < 3; i = i + 1) begin
            passwd_data_odd[i] = passwd_data_odd[i];
        end
        case (current_state)
            ANS1: begin
                //Excess-3
                if (hostage_num == 3) begin		//odd
                    for (i = 0; i < 3; i = i + 1) begin
                        passwd_data_odd[i] = passwd_data[i];
                    end
                end
                if (hostage_num == 3) begin
                    odd_max = -255;
                    odd_min = 255;
                    for (i = 0; i < 3; i = i + 1) begin
                        if (odd_max < passwd_data_odd[i]) begin
                            odd_max = passwd_data_odd[i];
                        end
                        if (odd_min > passwd_data_odd[i]) begin
                            odd_min = passwd_data_odd[i];
                        end
                    end

                    half = (odd_max + odd_min) / 2;
                    for (i = 0; i < 3; i = i + 1) begin
                        passwd_data_odd[i] = passwd_data_odd[i] - half;
                    end
                    passwd_data_odd[0] = passwd_data_odd[0];
                    passwd_data_odd[1] = (passwd_data_odd[0]*2 + passwd_data_odd[1]) / 3;
                    passwd_data_odd[2] = (passwd_data_odd[1]*2 + passwd_data_odd[2]) / 3;

                end
                
            end
            
            default: begin
                for (i = 0; i < 3; i = i + 1) begin
                    passwd_data_odd[i] = passwd_data_odd[i];
                end
            end
        endcase
    end
end

always @(*) begin
    if (!rst_n) begin
        passwd_data_odd_r2[0] = 0;
        passwd_data_odd_r2[1] = 0;
        passwd_data_odd_r2[2] = 0;
    end
    else begin
        for (i = 0; i < 3; i = i + 1) begin
            passwd_data_odd_r2[i] = passwd_data_odd_r1[i];
        end
    end
end
/*
//Odd Step2
always @(*) begin
    if (!rst_n) begin
        passwd_data_odd_r2[0] = 0;
        passwd_data_odd_r2[1] = 0;
        passwd_data_odd_r2[2] = 0;
    end
    else begin
        for (i = 0; i < 3; i = i + 1) begin
            passwd_data_odd_r2[i] = passwd_data_odd_r1[i];
        end
        case (current_state)
        
            ANS1: begin
                for (i = 0; i < 3; i = i + 1) begin
                    passwd_data_odd[i] = passwd_data_odd[i];
                end
                //Excess-3
                if (hostage_num == 3) begin		//odd
                    for (i = 0; i < hostage_num; i = i + 1) begin
                        passwd_data_odd[i] = passwd_data_r[i];
                    end
                end
            end
            *//*
            ANS2: begin
                if (hostage_num == 3) begin
                    half = (passwd_data_odd_r2[2] + passwd_data_odd_r2[0]) / 2;

                    for (i = 0; i < 3; i = i + 1) begin
                        passwd_data_odd_r2[i] = passwd_data_odd_r2[i] - half;
                    end
                end
                
            end
            default: begin
                for (i = 0; i < 3; i = i + 1) begin
                    passwd_data_odd_r2[i] = passwd_data_odd_r1[i];
                end
            end
        endcase
    end
end
*/
/*
always @(*) begin
    if (!rst_n) begin
        out_ans[0] = 0;
        out_ans[1] = 0;
        out_ans[2] = 0;
        out_ans[3] = 0;
    end
    else begin
        out_ans[0] = out_ans[0];
        out_ans[1] = out_ans[1];
        out_ans[2] = out_ans[2];
        out_ans[3] = out_ans[3];
        case (current_state)
            ANS3: begin
                out_ans[0] = out_ans[0];
                out_ans[1] = out_ans[1];
                out_ans[2] = out_ans[2];
                out_ans[3] = out_ans[3];
                if (hostage_num > 1) begin
                    //Cumulation
                    if (hostage_num == 2) begin
                        out_ans[0] = passwd_data_even_r1[0];
                        out_ans[1] = passwd_data_even_r1[1];
                        out_ans[2] = out_ans[2];
                        out_ans[3] = out_ans[3];
                    end
                    if (hostage_num == 3) begin
                        out_ans[0] = passwd_data_odd_r1[0];
                        out_ans[1] = passwd_data_odd_r1[1];
                        //out_ans[1] = (out_ans[0]*2 + passwd_data_odd_r3[1]) / 3;
                        //out_ans[2] = (out_ans[1]*2 + passwd_data_odd_r3[2]) / 3;
                        out_ans[2] = passwd_data_odd_r1[2];
                        out_ans[3] = out_ans[3];
                    end
                    if (hostage_num == 4) begin
                        out_ans[0] = passwd_data_even_r1[0];
                        out_ans[1] = passwd_data_even_r1[1];
                        out_ans[2] = passwd_data_even_r1[2];
                        out_ans[3] = passwd_data_even_r1[3];
                    end
                end
                else begin
                    out_ans[1] = 0;
                    out_ans[2] = 0;
                    out_ans[3] = 0;
                    
                    if (hostage_num == 0)
                        out_ans[0] = 0;
                    else if (hostage_num == 1)
                        out_ans[0] = passwd_data[0];
                end
            end
            default: begin
                out_ans[0] = out_ans[0];
                out_ans[1] = out_ans[1];
                out_ans[2] = out_ans[2];
                out_ans[3] = out_ans[3];
            end
        endcase
    end
end*/

assign in_passwd = in_data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_valid1 <= 0;
        out_valid2 <= 0;
        out <= 0;

        out_ans[0] <= 0;
        out_ans[1] <= 0;
        out_ans[2] <= 0;
        out_ans[3] <= 0;

        out_data <= 0;

        row_pos <= 0;
        col_pos <= 0;

        current_row <= 0;
        current_col <= 0;

        hostage_num <= 0;
        hostage_count <= 0;
        stall <= 0;

        last_step <= 0;

        passwd_cnt <= 0;

        passwd_data_even_r1[0] <= 0;
        passwd_data_even_r1[1] <= 0;
        passwd_data_even_r1[2] <= 0;
        passwd_data_even_r1[3] <= 0;

        passwd_data_even_r3[0] <= 0;
        passwd_data_even_r3[1] <= 0;
        passwd_data_even_r3[2] <= 0;
        passwd_data_even_r3[3] <= 0;
        out_cnt <= 0;
    end
    else begin
        case (current_state)
            IDLE: begin
                hostage_num <= 0;
                hostage_count <= 0;
                passwd_cnt <= 0;
                current_row <= 0;
                current_col <= 0;

                out_cnt <= 0;
                out_data <= 0;
                out_valid1 <= 0;

                if (in_valid1) begin
                    maze_data[row_pos][col_pos] <= in;
                    col_pos <= col_pos + 1;
                end
            end
            
            INPUT: begin
                maze_data[row_pos][col_pos] <= in;
                if (in == 3) begin
                    hostage_num <= hostage_num + 1;
                end
                if (col_pos != 16) begin
                    col_pos <= col_pos + 1;
                end
                else begin
                    col_pos <= 0;
                    if (row_pos != 16)
                        row_pos <= row_pos + 1;
                    else begin
                        row_pos <= 0;
                    end
                end
            end

            CAL: begin
                out_valid2 <= 1;

                if (stall == 0 && maze_data[current_row][current_col] == 2) begin
                    if (stall == 0) begin
                        stall <= 1;
                        out <= 3'd4;
                    end
                    else begin
                        stall <= 0;
                    end
                end
                else if (maze_data[current_row][current_col] == 3) begin
                    stall <= 0;
                    maze_data[current_row][current_col] <= 1;
                    out_valid2 <= 0;
                    out <= 0;
                    hostage_count <= hostage_count + 1;
                end
                else begin
                    stall <= 0;
                    case (current_col)
                        0: begin                //Col == 0
                            case (current_row)
                                0: begin        //Row == 0
                                    case(last_step)
                                        2: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                        default: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                    endcase
                                end
                                16: begin       //Row == 16
                                    case(last_step)
                                        1 : begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                        end
                                        2: begin
                                            if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                    endcase
                                end
                                default: begin
                                    case(last_step)
                                        1 : begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                        end
                                        2: begin
                                            if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                    endcase
                                end
                            endcase
                        end
                        16: begin
                            case (current_row)
                                0: begin        //Row == 0
                                    case(last_step)
                                        0: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                    endcase
                                end
                                16: begin       //Row == 16
                                    if (hostage_count != hostage_num) begin
                                        case(last_step)
                                            0: begin
                                                if (maze_data[current_row-1][current_col] != 0) begin
                                                    out <= 3'd3;
                                                    last_step <= 3'd3;
                                                    current_row <= current_row - 1;
                                                end
                                                else if (maze_data[current_row][current_col-1] != 0) begin
                                                    out <= 3'd2;
                                                    last_step <= 3'd2;
                                                    current_col <= current_col - 1;
                                                end
                                            end
                                            1: begin
                                                if (maze_data[current_row][current_col-1] != 0) begin
                                                    out <= 3'd2;
                                                    last_step <= 3'd2;
                                                    current_col <= current_col - 1;
                                                end
                                                else if (maze_data[current_row-1][current_col] != 0) begin
                                                    out <= 3'd3;
                                                    last_step <= 3'd3;
                                                    current_row <= current_row - 1;
                                                end
                                            end
                                        endcase
                                    end
                                    else begin
                                        out_valid2 <= 0;
                                        out <= 0;
                                    end
                                end
                                default: begin
                                    case(last_step)
                                        0: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                        end
                                        1 : begin
                                            if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                    endcase
                                end
                            endcase
                        end
                        default: begin
                            case (current_row)
                                0: begin        //Row == 0
                                    case(last_step)
                                        0: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                        end
                                        2: begin
                                            if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                    endcase
                                end
                                16: begin       //Row == 16
                                   case(last_step)
                                        0: begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                        end
                                        1 : begin
                                            if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                        end
                                        2: begin
                                            if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                    endcase
                                end
                                default: begin
                                    case(last_step)
                                        0: begin
                                            if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                        end
                                        1 : begin
                                            if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                        end
                                        2: begin
                                            if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                            else if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                        end
                                        3: begin
                                            if (maze_data[current_row][current_col+1] != 0) begin
                                                out <= 3'd0;
                                                last_step <= 3'd0;
                                                current_col <= current_col + 1;
                                            end
                                            else if (maze_data[current_row-1][current_col] != 0) begin
                                                out <= 3'd3;
                                                last_step <= 3'd3;
                                                current_row <= current_row - 1;
                                            end
                                            else if (maze_data[current_row][current_col-1] != 0) begin
                                                out <= 3'd2;
                                                last_step <= 3'd2;
                                                current_col <= current_col - 1;
                                            end
                                            else if (maze_data[current_row+1][current_col] != 0) begin
                                                out <= 3'd1;
                                                last_step <= 3'd1;
                                                current_row <= current_row + 1;
                                            end
                                        end
                                    endcase
                                end
                            endcase
                        end
                    endcase
                end
            end

            HOST: begin
                if(in_valid2) begin
                    passwd_cnt <= passwd_cnt + 1;
                    if (passwd_cnt == 0) begin
                        passwd_data[0] <= in_data;
                    end
                    else if (passwd_cnt == 1) begin
                        if (passwd_data[0] < in_passwd) begin
                            passwd_data[0] <= in_data;
                            passwd_data[1] <= passwd_data[0];
                        end
                        else begin
                            passwd_data[1] <= in_data;
                        end
                    end
                    else if (passwd_cnt == 2) begin
                        if (passwd_data[0] < in_passwd) begin
                            passwd_data[0] <= in_data;
                            passwd_data[1] <= passwd_data[0];
                            passwd_data[2] <= passwd_data[1];
                        end
                        else if (passwd_data[1] < in_passwd)begin
                            passwd_data[1] <= in_data;
                            passwd_data[2] <= passwd_data[1];
                        end
                        else begin
                            passwd_data[2] <= in_data;
                        end
                    end
                    else if (passwd_cnt == 3) begin
                        if (passwd_data[0] < in_passwd) begin
                            passwd_data[0] <= in_data;
                            passwd_data[1] <= passwd_data[0];
                            passwd_data[2] <= passwd_data[1];
                            passwd_data[3] <= passwd_data[2];
                        end
                        else if (passwd_data[1] < in_passwd)begin
                            passwd_data[1] <= in_data;
                            passwd_data[2] <= passwd_data[1];
                            passwd_data[3] <= passwd_data[2];
                        end
                        else if (passwd_data[2] < in_passwd)begin
                            passwd_data[2] <= in_data;
                            passwd_data[3] <= passwd_data[2];
                        end
                        else begin
                            passwd_data[3] <= in_data;
                        end
                    end
                end
            end

            ANS1: begin
                
                if (hostage_num == 2) begin
                    passwd_data_even_r1[0] <= passwd_data_even[0];
                    passwd_data_even_r1[1] <= passwd_data_even[1];
                end
                else if (hostage_num == 3) begin
                    passwd_data_odd_r1[0] <= passwd_data_odd[0];
                    passwd_data_odd_r1[1] <= passwd_data_odd[1];
                    passwd_data_odd_r1[2] <= passwd_data_odd[2];
                end
                else if (hostage_num == 4) begin
                    passwd_data_even_r1[0] <= passwd_data_even[0];
                    passwd_data_even_r1[1] <= passwd_data_even[1];
                    passwd_data_even_r1[2] <= passwd_data_even[2];
                    passwd_data_even_r1[3] <= passwd_data_even[3];
                end
            end
            ANS2: begin
                
                if (hostage_num > 1) begin
                    //Cumulation
                    if (hostage_num == 2) begin
                        out_ans[0] <= passwd_data_even_r2[0];
                        out_ans[1] <= passwd_data_even_r2[1];
                    end
                    if (hostage_num == 3) begin
                        out_ans[0] <= passwd_data_odd_r2[0];
                        out_ans[1] <= passwd_data_odd_r2[1];
                        //out_ans[1] = (out_ans[0]*2 + passwd_data_odd_r3[1]) / 3;
                        //out_ans[2] = (out_ans[1]*2 + passwd_data_odd_r3[2]) / 3;
                        out_ans[2] <= passwd_data_odd_r2[2];
                    end
                    if (hostage_num == 4) begin
                        out_ans[0] <= passwd_data_even_r2[0];
                        out_ans[1] <= passwd_data_even_r2[1];
                        out_ans[2] <= passwd_data_even_r2[2];
                        out_ans[3] <= passwd_data_even_r2[3];
                    end
                end
                else begin
                    out_ans[1] <= 0;
                    out_ans[2] <= 0;
                    out_ans[3] <= 0;
                    
                    if (hostage_num == 0)
                        out_ans[0] <= 0;
                    else if (hostage_num == 1)
                        out_ans[0] <= passwd_data[0];
                end
            
                if (hostage_num == 2) begin
                    passwd_data_even_r3[0] <= passwd_data_even_r2[0];
                    passwd_data_even_r3[1] <= passwd_data_even_r2[1];
                end
                else if (hostage_num == 3) begin
                    passwd_data_odd_r3[0] <= passwd_data_odd_r2[0];
                    passwd_data_odd_r3[1] <= passwd_data_odd_r2[1];
                    passwd_data_odd_r3[2] <= passwd_data_odd_r2[2];
                end
                else if (hostage_num == 4) begin
                    passwd_data_even_r3[0] <= passwd_data_even_r2[0];
                    passwd_data_even_r3[1] <= passwd_data_even_r2[1];
                    passwd_data_even_r3[2] <= passwd_data_even_r2[2];
                    passwd_data_even_r3[3] <= passwd_data_even_r2[3];
                end
                //out_valid1 <= 1;
                //out_data <= out_ans[out_cnt];
                //out_cnt <= out_cnt + 1;
            end

            ANS3: begin
                out_valid1 <= 1;
                out_data <= out_ans[out_cnt];
                out_cnt <= out_cnt + 1;
            end

            OUT: begin
                if (hostage_num == 0 || hostage_num == 1) begin
                    out_data <= 0;
                    out_cnt <= 0;
                    out_valid1 <= 0;
                end
                else begin
                    out_data <= out_ans[out_cnt];
                    if (out_cnt == hostage_num - 1) begin
                        out_cnt <= 0;
                    end
                    else begin
                        out_cnt <= out_cnt + 1;
                    end
                end
            end


        endcase
    end

end

endmodule