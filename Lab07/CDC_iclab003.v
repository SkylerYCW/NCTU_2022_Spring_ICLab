`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Input Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Output Port
	ready,
    out_valid,
	out_account
); 
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------

input 				rst_n, clk1, clk2, in_valid;
input [DSIZE-1:0] 	in_account,in_A,in_T;

output reg				out_valid,ready;
output reg [DSIZE-1:0] 	out_account;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg [DSIZE-1:0] account_r [0:4];
reg [DSIZE*2-1:0] performance_r [0:4];
reg [DSIZE-1:0] best_account;

reg [11:0] in_cnt;

reg r_inc, w_inc;
reg [7:0] w_data;
wire [7:0] r_data;
wire w_full, r_empty;

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------


//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------

// Ready
always @(*) begin
    if (!rst_n) begin
        ready = 0;
    end
    else begin
        if (w_full == 0) begin
            ready = 1;
        end
        else begin
            ready = 0;
        end
    end
end

// Input
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        performance_r[0] <= 0;
        performance_r[1] <= 0;
        performance_r[2] <= 0;
        performance_r[3] <= 0;
        performance_r[4] <= 0;
    end
    else begin
        if (in_valid) begin
            performance_r[0] <= in_A * in_T;
            performance_r[1] <= performance_r[0];
            performance_r[2] <= performance_r[1];
            performance_r[3] <= performance_r[2];
            performance_r[4] <= performance_r[3];
        end
    end
end
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        account_r[0] <= 0;
        account_r[1] <= 0;
        account_r[2] <= 0;
        account_r[3] <= 0;
        account_r[4] <= 0;
    end
    else begin
        if (in_valid) begin
            account_r[0] <= in_account;
            account_r[1] <= account_r[0];
            account_r[2] <= account_r[1];
            account_r[3] <= account_r[2];
            account_r[4] <= account_r[3];
        end
    end
end
// Input count
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        in_cnt <= 0;
    end
    else begin
        if (in_valid || ((in_cnt == 4000 || in_cnt == 4001) && !w_full)) begin
            in_cnt <= in_cnt + 1;
        end
    end
end
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        best_account <= 0;
    end
    else begin
        if ((in_valid && in_cnt > 4) || (in_cnt == 4000 && !w_full)) begin
            if (performance_r[4] < performance_r[3]) begin
                if (performance_r[4] < performance_r[2]) begin
                    if (performance_r[4] < performance_r[1]) begin
                        if (performance_r[4] < performance_r[0]) begin
                            best_account <= account_r[4];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                    else begin
                        if (performance_r[1] < performance_r[0]) begin
                            best_account <= account_r[1];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                end
                else begin
                    if (performance_r[2] < performance_r[1]) begin
                        if (performance_r[2] < performance_r[0]) begin
                            best_account <= account_r[2];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                    else begin
                        if (performance_r[1] < performance_r[0]) begin
                            best_account <= account_r[1];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                end
            end
            else begin
                if (performance_r[3] < performance_r[2]) begin
                    if (performance_r[3] < performance_r[1]) begin
                        if (performance_r[3] < performance_r[0]) begin
                            best_account <= account_r[3];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                    else begin
                        if (performance_r[1] < performance_r[0]) begin
                            best_account <= account_r[1];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                end
                else begin
                    if (performance_r[2] < performance_r[1]) begin
                        if (performance_r[2] < performance_r[0]) begin
                            best_account <= account_r[2];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                    else begin
                        if (performance_r[1] < performance_r[0]) begin
                            best_account <= account_r[1];
                        end
                        else begin
                            best_account <= account_r[0];
                        end
                    end
                end
            end
        end
    end
end

// Write & read
always @(*) begin
    if (in_cnt > 5 && in_cnt < 4002 && !w_full) begin
        if (in_valid || (in_cnt == 4000 || in_cnt == 4001)) begin
            w_inc = 1'b1;
        end
        else begin
            w_inc = 1'b0;
        end
    end
    else begin
        w_inc = 1'b0;
    end
end
always @(*) begin
    r_inc = !r_empty;
end
always @(*) begin
    w_data = best_account;
end

// Output
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        out_valid <= 0;
        out_account <= 0;
    end
    else begin
        if (r_inc) begin
            out_valid <= 1;
            out_account <= r_data;
        end
        else begin
            out_valid <= 0;
            out_account <= 0;
        end
    end
end


AFIFO u_AFIFO(
    .rclk(clk2),
    .rinc(r_inc),
    .rempty(r_empty),
	.wclk(clk1),
    .winc(w_inc),
    .wfull(w_full),
    .rst_n(rst_n),
    .rdata(r_data),
    .wdata(w_data)
    );

	
endmodule