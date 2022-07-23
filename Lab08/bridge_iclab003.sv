module bridge(input clk, INF.bridge_inf inf);

//================================================================
// logic 
//================================================================

parameter IDLE = 'd0;
parameter WAIT_ARREA = 'd1;
parameter WAIT_RREA = 'd2;
parameter WAIT_AWREA = 'd3;
parameter WAIT_WREA = 'd4;
parameter FINISH = 'd5;

logic [3:0] current_state, next_state;
logic [8:0] addr_r;
logic [63:0] data_r;

//================================================================
// design 
//================================================================

// Current state
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// Next state
always_comb begin
    case (current_state)
        IDLE: begin
            if (inf.C_in_valid && inf.C_r_wb) next_state = WAIT_ARREA;
            else if (inf.C_in_valid && !inf.C_r_wb)   next_state = WAIT_AWREA;
            else                    next_state = current_state;
        end
        WAIT_ARREA: begin
            if (inf.AR_READY)           next_state = WAIT_RREA;
            else                    next_state = current_state;
        end
        WAIT_RREA: begin
            if (inf.R_VALID)            next_state = IDLE;
            else                    next_state = current_state;
        end
        WAIT_AWREA: begin
            if (inf.AW_READY)           next_state = WAIT_WREA;
            else                    next_state = current_state;
        end
        WAIT_WREA: begin
            if (inf.W_READY)            next_state = FINISH;
            else                    next_state = current_state;
        end
        FINISH: begin
            if (inf.B_VALID && inf.B_RESP == 0) next_state = IDLE;
            else                    next_state = current_state;
        end
        default: begin
                                    next_state = current_state;
        end
    endcase
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        addr_r <= 0;
        data_r <= 0;
    end
    else begin
        if (inf.C_in_valid) begin
            addr_r <= inf.C_addr;
            data_r <= inf.C_data_w;
        end
        else if (current_state == IDLE) begin
            addr_r <= 0;
            data_r <= 0;
        end
    end
end

// DRAM
// Read
always_comb begin
    case (current_state)
        WAIT_ARREA: begin
            inf.AR_VALID = 1;
        end
        default: begin
            inf.AR_VALID = 0;
        end
    endcase
end
always_comb begin
    case (current_state)
        WAIT_ARREA: begin
            inf.AR_ADDR = 17'h10000 + 8*addr_r;
        end
        default: begin
            inf.AR_ADDR = 0;
        end
    endcase
end
always_comb begin
    case (current_state)
        WAIT_RREA: begin
            inf.R_READY = 1;
        end
        default: begin
            inf.R_READY = 0;
        end
    endcase
end

// Write
always_comb begin
    case (current_state)
        WAIT_AWREA: begin
            inf.AW_VALID = 1;
        end
        default: begin
            inf.AW_VALID = 0;
        end
    endcase
end
always_comb begin
    case (current_state)
        WAIT_AWREA: begin
            inf.AW_ADDR = 17'h10000 + 8*addr_r;
        end
        default: begin
            inf.AW_ADDR = 0;
        end
    endcase
end
always_comb begin
    case (current_state)
        WAIT_WREA: begin
            inf.W_VALID = 1;
        end
        default: begin
            inf.W_VALID = 0;
        end
    endcase
end

always_comb begin
    inf.W_DATA = data_r;
end

always_comb begin
    case (current_state)
        WAIT_WREA: begin
            inf.B_READY = 1;
        end
        FINISH: begin
            inf.B_READY = 1;
        end
        default: begin
            inf.B_READY = 0;
        end
    endcase
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_out_valid <= 0;
        inf.C_data_r <= 0;
    end
    else begin
        if (current_state == WAIT_RREA && inf.R_VALID) begin
            inf.C_out_valid <= 1;
            inf.C_data_r <= inf.R_DATA;
        end
        else if (current_state == FINISH && inf.B_VALID) begin
            inf.C_out_valid <= 1;
            inf.C_data_r <= 0;
        end
        else begin
            inf.C_out_valid <= 0;
            inf.C_data_r <= 0;
        end
    end
end

endmodule