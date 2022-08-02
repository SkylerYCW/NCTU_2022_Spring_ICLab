//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Final Proejct              : TOF  
//   Author                     : Wen-Yue, Lin
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-5)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TOF(
    // CHIP IO
    clk,
    rst_n,
    in_valid,
    start,
    stop,
    inputtype,
    frame_id,
    busy,

    // AXI4 IO
    arid_m_inf,
    araddr_m_inf,
    arlen_m_inf,
    arsize_m_inf,
    arburst_m_inf,
    arvalid_m_inf,
    arready_m_inf,
    
    rid_m_inf,
    rdata_m_inf,
    rresp_m_inf,
    rlast_m_inf,
    rvalid_m_inf,
    rready_m_inf,

    awid_m_inf,
    awaddr_m_inf,
    awsize_m_inf,
    awburst_m_inf,
    awlen_m_inf,
    awvalid_m_inf,
    awready_m_inf,

    wdata_m_inf,
    wlast_m_inf,
    wvalid_m_inf,
    wready_m_inf,
    
    bid_m_inf,
    bresp_m_inf,
    bvalid_m_inf,
    bready_m_inf 
);
// ===============================================================
//                      Parameter Declaration 
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter


// ===============================================================
//                      Input / Output 
// ===============================================================

// << CHIP io port with system >>
input           clk, rst_n;
input           in_valid;
input           start;
input [15:0]    stop;     
input [1:0]     inputtype; 
input [4:0]     frame_id;
output reg      busy;       

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
    Your AXI-4 interface could be designed as a bridge in submodule,
    therefore I declared output of AXI as wire.  
    Ex: AXI4_interface AXI4_INF(...);
*/

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)    axi read address channel 
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output wire                  arvalid_m_inf;
input  wire                  arready_m_inf;
output wire [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)    axi read data channel 
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1)     axi write address channel 
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output wire [7:0]              awlen_m_inf;
output wire                  awvalid_m_inf;
input  wire                  awready_m_inf;
output wire [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)    axi write data channel 
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output wire [DATA_WIDTH-1:0]   wdata_m_inf;
output wire                    wlast_m_inf;
// -------------------------
// (3)    axi write response channel 
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------



// Parameters & Integer Declaration
parameter IDLE = 'd0;
parameter INPUT0 = 'd1;
parameter WAIT_ARREA = 'd2;
parameter START0 = 'd3;
parameter START1 = 'd4;
parameter WAIT = 'd5;
parameter WIND_R = 'd6;
parameter WIND = 'd7;
parameter WRITE_WIN = 'd8;
parameter WAIT_AWREA = 'd9;
parameter WAIT_WREA = 'd10;
parameter WRITE_BACK = 'd11;
parameter FINISH = 'd12;
parameter WAIT_RREA = 'd13;
parameter PUT_S = 'd14;
parameter OUT = 'd15;

// Wire and reg declaration
reg [4:0] current_state, next_state;
reg [7:0] in_cnt;
reg [8:0] win_cnt;
reg [7:0] win_out [0:15];
reg [10:0] win_big [0:15];
reg [10:0] win_save [0:3][0:15];


reg [1:0] window_r;

reg [1:0] inputtype_r;
reg [4:0] frame_id_r;


integer i, j;

// DRAM reg & wire
reg [4:0] write_cnt;
reg [9:0] wready_cnt;
reg [127:0] out_data;
reg [127:0] in_data;
reg [4:0] his_cnt;
reg wlast_r;

// SRAM reg & wire
reg [127:0] in_data1, in_data2;
wire [127:0] out_data1, out_data2;
reg [6:0] addr1, addr2;
reg wen1, wen2;

reg [127:0] in_data1_r;
reg [127:0] in_data2_r;

SRAM MEM1(.Q(out_data1),.CLK(clk),.CEN(1'b0),.WEN(wen1),.A(addr1),.D(in_data1),.OEN(1'b0));
SRAM MEM2(.Q(out_data2),.CLK(clk),.CEN(1'b0),.WEN(wen2),.A(addr2),.D(in_data2),.OEN(1'b0));

// Current state
always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		current_state <= IDLE;
	else
		current_state <= next_state;
end

// Next state
always @(*) begin
	case (current_state)
		IDLE: begin
            if (in_valid && inputtype == 2'b00)          next_state = WAIT_ARREA;
            else if (in_valid)      next_state = INPUT0;
            else                next_state = current_state;
		end
		INPUT0: begin
            if (start)          next_state = START0;
            else                next_state = current_state;
		end
        WAIT_ARREA: begin
            if (arready_m_inf)   next_state = WAIT_RREA;
            else                next_state = current_state;
        end
        START0: begin
            if (!start)         next_state = WAIT;
            else                next_state = current_state;
        end
        START1: begin
            if (!in_valid)      next_state = WIND_R;
            else if (!start)    next_state = WAIT;
            else                next_state = current_state;
        end
        WAIT: begin
            if (start)          next_state = START1;
            else                next_state = current_state;
        end
        WIND_R: begin
            if (addr1 == 1 && addr2 == 1)   next_state = WIND;
            else                            next_state =current_state;
        end
        WIND: begin
            if (win_cnt == 128)     next_state = WRITE_WIN;
            else                next_state = current_state;
        end
        WRITE_WIN: begin
                                next_state = WAIT_AWREA;
        end
        WAIT_AWREA: begin
            if (awready_m_inf)  next_state = WRITE_BACK;
            else                next_state = WAIT_AWREA;
        end
        WAIT_WREA: begin
            if (inputtype_r == 2'b00) begin
                if (his_cnt == 15 && wready_m_inf)      next_state = FINISH;
                else if (wready_m_inf)  next_state = WAIT_AWREA;
                else                    next_state = current_state;
            end
            else begin
                if (his_cnt == 15 && wready_cnt == 15)  next_state = FINISH;
                else if (wready_m_inf)  next_state = WRITE_BACK;
                else                    next_state = current_state;
            end
        end
        WRITE_BACK: begin
            if (write_cnt == 8)     next_state = WAIT_WREA;
            else                    next_state = current_state;
        end
		FINISH: begin
            if (bvalid_m_inf && bresp_m_inf == 2'b00 && bid_m_inf == 0)   next_state = IDLE;
            else                next_state = current_state;
		end
        WAIT_RREA: begin
            if (rvalid_m_inf)   next_state = PUT_S;
            else                next_state = current_state;
        end
        PUT_S: begin
            if (his_cnt == 15 && wready_cnt == 255)  next_state = WIND_R;
            else if (write_cnt == 16)  next_state = WAIT_RREA;
            else                next_state = current_state;
        end
        default:                next_state = current_state;
	endcase
end

// Input count
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_cnt <= 0;
    end
    else begin
        if (next_state == START0 || next_state == START1 || next_state == PUT_S) begin
            in_cnt <= in_cnt + 1;
        end
        else if (next_state == IDLE || next_state == WAIT) begin
            in_cnt <= 0;
        end
    end
end

// Address
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        addr1 <= 0;
        addr2 <= 0;
    end
    else begin
        if (next_state == START0 || next_state == START1 || next_state == PUT_S) begin
            if (in_cnt%2 == 0) begin
                addr1 <= addr1 + 1;
            end
            else begin
                addr2 <= addr2 + 1;
            end
        end
        else if (next_state == WAIT || next_state == IDLE) begin
            addr1 <= 0;
            addr2 <= 0;
        end
        else if (next_state == WAIT_AWREA) begin
            if (inputtype_r == 2'b00) begin
                addr1 <= 120;
                addr2 <= 120;
            end
            else begin
                addr1 <= 0;
                addr2 <= 0;
            end
        end
        else if (next_state == WIND_R) begin
            if (addr1 == 0 && addr2 == 0) begin
                addr1 <= addr1 + 1;
                addr2 <= addr2 + 1;
            end
            else begin
                addr1 <= 0;
                addr2 <= 0;
            end
        end
        else if (next_state == WIND) begin
            addr1 <= addr1 + 1;
            if (addr2 != 127) begin
                addr2 <= addr2 + 1;
            end
        end
        else if (next_state == WRITE_BACK) begin
            addr1 <= addr1 + 1;
            addr2 <= addr2 + 1;
        end
    end
end

// Wen
always @(*) begin
    if (next_state == START0 || next_state == START1) begin
        if (in_cnt%2 == 0) begin
            wen1 = 0;
            wen2 = 1;
        end
        else begin
            wen1 = 1;
            wen2 = 0;
        end
    end
    else if (next_state == PUT_S) begin
        if (in_cnt%2 == 0) begin
            wen1 = 0;
            wen2 = 1;
        end
        else begin
            wen1 = 1;
            wen2 = 0;
        end
    end
    else if (next_state == WRITE_WIN) begin
        wen1 = 1;
        wen2 = 0;
    end
    else begin
        wen1 = 1;
        wen2 = 1;
    end
end

wire [7:0] in_w1 [0:15];
wire [7:0] in_w2 [0:15];

assign in_w1[0] = out_data1[7:0];
assign in_w1[1] = out_data1[15:8];
assign in_w1[2] = out_data1[23:16];
assign in_w1[3] = out_data1[31:24];
assign in_w1[4] = out_data1[39:32];
assign in_w1[5] = out_data1[47:40];
assign in_w1[6] = out_data1[55:48];
assign in_w1[7] = out_data1[63:56];
assign in_w1[8] = out_data1[71:64];
assign in_w1[9] = out_data1[79:72];
assign in_w1[10] = out_data1[87:80];
assign in_w1[11] = out_data1[95:88];
assign in_w1[12] = out_data1[103:96];
assign in_w1[13] = out_data1[111:104];
assign in_w1[14] = out_data1[119:112];
assign in_w1[15] = out_data1[127:120];

assign in_w2[0] = out_data2[7:0];
assign in_w2[1] = out_data2[15:8];
assign in_w2[2] = out_data2[23:16];
assign in_w2[3] = out_data2[31:24];
assign in_w2[4] = out_data2[39:32];
assign in_w2[5] = out_data2[47:40];
assign in_w2[6] = out_data2[55:48];
assign in_w2[7] = out_data2[63:56];
assign in_w2[8] = out_data2[71:64];
assign in_w2[9] = out_data2[79:72];
assign in_w2[10] = out_data2[87:80];
assign in_w2[11] = out_data2[95:88];
assign in_w2[12] = out_data2[103:96];
assign in_w2[13] = out_data2[111:104];
assign in_w2[14] = out_data2[119:112];
assign in_w2[15] = out_data2[127:120];

// Input data
always @(*) begin
    in_data1 = 0;
    in_data2 = 0;
    if (next_state == START0) begin
        if (in_cnt%2 == 0) begin
            in_data1 = {7'b0, stop[15], 7'b0, stop[14], 7'b0, stop[13], 7'b0, stop[12], 
                        7'b0, stop[11], 7'b0, stop[10], 7'b0, stop[9], 7'b0, stop[8], 
                        7'b0, stop[7], 7'b0, stop[6], 7'b0, stop[5], 7'b0, stop[4], 
                        7'b0, stop[3], 7'b0, stop[2], 7'b0, stop[1], 7'b0, stop[0]
                        };
        end
        else if (in_cnt%2 == 1) begin
            in_data2 = {7'b0, stop[15], 7'b0, stop[14], 7'b0, stop[13], 7'b0, stop[12], 
                        7'b0, stop[11], 7'b0, stop[10], 7'b0, stop[9], 7'b0, stop[8], 
                        7'b0, stop[7], 7'b0, stop[6], 7'b0, stop[5], 7'b0, stop[4], 
                        7'b0, stop[3], 7'b0, stop[2], 7'b0, stop[1], 7'b0, stop[0]
                        };
        end
    end
    else if (next_state == START1) begin
        if (in_cnt%2 == 0) begin
            in_data1 = {{in_w1[15]+stop[15]}, {in_w1[14]+stop[14]}, {in_w1[13]+stop[13]}, {in_w1[12]+stop[12]}, 
                        {in_w1[11]+stop[11]}, {in_w1[10]+stop[10]}, {in_w1[9]+stop[9]}, {in_w1[8]+stop[8]}, 
                        {in_w1[7]+stop[7]}, {in_w1[6]+stop[6]}, {in_w1[5]+stop[5]}, {in_w1[4]+stop[4]}, 
                        {in_w1[3]+stop[3]}, {in_w1[2]+stop[2]}, {in_w1[1]+stop[1]}, {in_w1[0]+stop[0]}
                        };
        end
        else if (in_cnt%2 == 1) begin
            in_data2 = {{in_w2[15]+stop[15]}, {in_w2[14]+stop[14]}, {in_w2[13]+stop[13]}, {in_w2[12]+stop[12]}, 
                        {in_w2[11]+stop[11]}, {in_w2[10]+stop[10]}, {in_w2[9]+stop[9]}, {in_w2[8]+stop[8]}, 
                        {in_w2[7]+stop[7]}, {in_w2[6]+stop[6]}, {in_w2[5]+stop[5]}, {in_w2[4]+stop[4]}, 
                        {in_w2[3]+stop[3]}, {in_w2[2]+stop[2]}, {in_w2[1]+stop[1]}, {in_w2[0]+stop[0]}
                        };
        end
    end
    else if (next_state == WRITE_WIN) begin
        in_data1 = 0;
        in_data2 = {win_out[15], win_out[14], win_out[13], win_out[12], win_out[11], win_out[10], win_out[9], win_out[8], 
                    win_out[7], win_out[6], win_out[5], win_out[4], win_out[3], win_out[2], win_out[1], win_out[0]
                    };
    end
    else if (next_state == PUT_S) begin
        case (his_cnt)
            0: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:8], rdata_m_inf[7:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:8], in_data[7:0]};
                end
                else begin
                    in_data2 = {out_data2[127:8], in_data[7:0]};
                end
            end
            1: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:16], rdata_m_inf[7:0], out_data1[7:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:16], in_data[7:0], out_data1[7:0]};
                end
                else begin
                    in_data2 = {out_data2[127:16], in_data[7:0], out_data2[7:0]};
                end
            end
            2: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:24], rdata_m_inf[7:0], out_data1[15:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:24], in_data[7:0], out_data1[15:0]};
                end
                else begin
                    in_data2 = {out_data2[127:24], in_data[7:0], out_data2[15:0]};
                end
                
                
            end
            3: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:32], rdata_m_inf[7:0], out_data1[23:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:32], in_data[7:0], out_data1[23:0]};
                end
                else begin
                    in_data2 = {out_data2[127:32], in_data[7:0], out_data2[23:0]};
                end
            end
            4: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:40], rdata_m_inf[7:0], out_data1[31:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:40], in_data[7:0], out_data1[31:0]};
                end
                else begin
                    in_data2 = {out_data2[127:40], in_data[7:0], out_data2[31:0]};
                end
            end
            5: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:48], rdata_m_inf[7:0], out_data1[39:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:48], in_data[7:0], out_data1[39:0]};
                end
                else begin
                    in_data2 = {out_data2[127:48], in_data[7:0], out_data2[39:0]};
                end
            end
            6: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:56], rdata_m_inf[7:0], out_data1[47:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:56], in_data[7:0], out_data1[47:0]};
                end
                else begin
                    in_data2 = {out_data2[127:56], in_data[7:0], out_data2[47:0]};
                end
            end
            7: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:64], rdata_m_inf[7:0], out_data1[55:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:64], in_data[7:0], out_data1[55:0]};
                end
                else begin
                    in_data2 = {out_data2[127:64], in_data[7:0], out_data2[55:0]};
                end
            end
            8: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:72], rdata_m_inf[7:0], out_data1[63:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:72], in_data[7:0], out_data1[63:0]};
                end
                else begin
                    in_data2 = {out_data2[127:72], in_data[7:0], out_data2[63:0]};
                end
            end
            9: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:80], rdata_m_inf[7:0], out_data1[71:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:80], in_data[7:0], out_data1[71:0]};
                end
                else begin
                    in_data2 = {out_data2[127:80], in_data[7:0], out_data2[71:0]};
                end
            end
            10: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:88], rdata_m_inf[7:0], out_data1[79:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:88], in_data[7:0], out_data1[79:0]};
                end
                else begin
                    in_data2 = {out_data2[127:88], in_data[7:0], out_data2[79:0]};
                end
            end
            11: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:96], rdata_m_inf[7:0], out_data1[87:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:96], in_data[7:0], out_data1[87:0]};
                end
                else begin
                    in_data2 = {out_data2[127:96], in_data[7:0], out_data2[87:0]};
                end
            end
            12: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:104], rdata_m_inf[7:0], out_data1[95:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:104], in_data[7:0], out_data1[95:0]};
                end
                else begin
                    in_data2 = {out_data2[127:104], in_data[7:0], out_data2[95:0]};
                end
            end
            13: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:112], rdata_m_inf[7:0], out_data1[103:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:112], in_data[7:0], out_data1[103:0]};
                end
                else begin
                    in_data2 = {out_data2[127:112], in_data[7:0], out_data2[103:0]};
                end
            end
            14: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {out_data1[127:120], rdata_m_inf[7:0], out_data1[111:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {out_data1[127:120], in_data[7:0], out_data1[111:0]};
                end
                else begin
                    in_data2 = {out_data2[127:120], in_data[7:0], out_data2[111:0]};
                end
            end
            15: begin
                if (in_cnt%16 == 0) begin
                    in_data1 = {rdata_m_inf[7:0], out_data1[119:0]};
                end
                else if (in_cnt%2 == 0) begin
                    in_data1 = {in_data[7:0], out_data1[119:0]};
                end
                else begin
                    in_data2 = {in_data[7:0], out_data2[119:0]};
                end
            end
        endcase
    end
    else begin
        in_data1 = 0;
        in_data2 = 0;
    end
end

// Inputtype & frame id
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inputtype_r <= 0;
        frame_id_r <= 0;
    end
    else begin
        if (current_state == IDLE && in_valid) begin
            inputtype_r <= inputtype;
            frame_id_r <= frame_id;
        end
        else if (current_state == IDLE) begin
            inputtype_r <= 0;
            frame_id_r <= 0;
        end
    end
end

// Window
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        win_cnt <= 0;
    end
    else begin
        if (next_state == WIND) begin
            win_cnt <= win_cnt + 1;

            for (i = 0; i < 16; i = i + 1) begin
                win_save[0][i] <= win_save[2][i];
                win_save[1][i] <= win_save[3][i];
                win_save[2][i] <= in_w1[i];
                win_save[3][i] <= in_w2[i];
            end

            if (inputtype_r == 2'b01) begin
                if (win_cnt > 1 && win_cnt < 127) begin
                    for (i = 0; i < 10; i = i + 8) begin
                        for (j = 0; j < 3; j = j + 2) begin
                            if (win_big[i+j] < win_save[0][i+j] + win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] +
                                            win_save[0][i+j+1] + win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] +
                                            win_save[0][i+j+4] + win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] +
                                            win_save[0][i+j+5] + win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5]) begin
                                if (win_save[0][i+j] + win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] +
                                    win_save[0][i+j+1] + win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] +
                                    win_save[0][i+j+4] + win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] +
                                    win_save[0][i+j+5] + win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5]
                                    <
                                    win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] + in_w2[i+j] +
                                    win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] + in_w2[i+j+1] +
                                    win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] + in_w2[i+j+4] +
                                    win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5] + in_w2[i+j+5]
                                    ) begin
                                    win_big[i+j] <= win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] + in_w2[i+j] +
                                                win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] + in_w2[i+j+1] +
                                                win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] + in_w2[i+j+4] +
                                                win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5] + in_w2[i+j+5];
                                    win_out[i+j] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+1] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+4] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+5] <= (win_cnt-2)*2 + 1;
                                end
                                else begin
                                    win_big[i+j] <= win_save[0][i+j] + win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] +
                                                win_save[0][i+j+1] + win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] +
                                                win_save[0][i+j+4] + win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] +
                                                win_save[0][i+j+5] + win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5];
                                    win_out[i+j] <= (win_cnt-2)*2;
                                    win_out[i+j+1] <= (win_cnt-2)*2;
                                    win_out[i+j+4] <= (win_cnt-2)*2;
                                    win_out[i+j+5] <= (win_cnt-2)*2;
                                end
                            end
                            else begin
                                if (win_big[i+j] < win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] + in_w2[i+j] +
                                                win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] + in_w2[i+j+1] +
                                                win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] + in_w2[i+j+4] +
                                                win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5] + in_w2[i+j+5]) begin
                                    win_big[i+j] <= win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] + in_w2[i+j] +
                                                win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] + in_w2[i+j+1] +
                                                win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] + in_w2[i+j+4] +
                                                win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5] + in_w2[i+j+5];
                                    win_out[i+j] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+1] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+4] <= (win_cnt-2)*2 + 1;
                                    win_out[i+j+5] <= (win_cnt-2)*2 + 1;
                                end
                                else begin
                                    win_big[i+j] <= win_big[i+j];
                                end
                            end
                        end
                    end
                end
                else if (win_cnt == 127) begin
                    for (i = 0; i < 10; i = i + 8) begin
                        for (j = 0; j < 3; j = j + 2) begin
                            if (win_big[i+j] < win_save[0][i+j] + win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] +
                                                win_save[0][i+j+1] + win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] +
                                                win_save[0][i+j+4] + win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] +
                                                win_save[0][i+j+5] + win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5]) begin
                                win_big[i+j] <= win_save[0][i+j] + win_save[1][i+j] + win_save[2][i+j] + win_save[3][i+j] + in_w1[i+j] +
                                                win_save[0][i+j+1] + win_save[1][i+j+1] + win_save[2][i+j+1] + win_save[3][i+j+1] + in_w1[i+j+1] +
                                                win_save[0][i+j+4] + win_save[1][i+j+4] + win_save[2][i+j+4] + win_save[3][i+j+4] + in_w1[i+j+4] +
                                                win_save[0][i+j+5] + win_save[1][i+j+5] + win_save[2][i+j+5] + win_save[3][i+j+5] + in_w1[i+j+5];
                                win_out[i+j] <= (win_cnt-2)*2;
                                win_out[i+j+1] <= (win_cnt-2)*2;
                                win_out[i+j+4] <= (win_cnt-2)*2;
                                win_out[i+j+5] <= (win_cnt-2)*2;
                            end
                            else begin
                                win_big[i+j] <= win_big[i+j];
                            end
                        end
                    end
                end
            end
            else begin
                if (win_cnt > 1 && win_cnt < 127) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        if (win_big[i] < win_save[0][i] + win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i]) begin
                            if (win_save[0][i] + win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i] < win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i] + in_w2[i]) begin
                                win_big[i] <= win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i] + in_w2[i];
                                win_out[i] <= (win_cnt-2)*2 + 1;
                            end
                            else begin
                                win_big[i] <= win_save[0][i] + win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i];
                                win_out[i] <= (win_cnt-2)*2;
                            end
                        end
                        else begin
                            if (win_big[i] < win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i] + in_w2[i]) begin
                                win_big[i] <= win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i] + in_w2[i];
                                win_out[i] <= (win_cnt-2)*2 + 1;
                            end
                            else begin
                                win_big[i] <= win_big[i];
                                win_out[i] <= win_out[i];
                            end
                        end
                    end
                end
                else if (win_cnt == 127) begin
                    for (i = 0; i < 16; i = i + 1) begin
                        if (win_big[i] < win_save[0][i] + win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i]) begin
                            win_big[i] <= win_save[0][i] + win_save[1][i] + win_save[2][i] + win_save[3][i] + in_w1[i];
                            win_out[i] <= (win_cnt-2)*2;
                        end
                        else begin
                            win_big[i] <= win_big[i];
                            win_out[i] <= win_out[i];
                        end
                    end
                end
            end
        end
        else if (next_state == IDLE) begin
            for (i = 0; i < 16; i = i + 1) begin
                win_big[i] <= 0;
                win_out[i] <= 1;
            end

            win_cnt <= 0;
        end
    end
end

// Output
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		busy <= 0;
	end
	else begin
		if (current_state == IDLE) begin
			busy <= 0;
		end
        else if (next_state == WIND_R) begin
            busy <= 1;
        end
        else if (next_state == WIND) begin
            busy <= 1;
        end
        else if (next_state == WAIT_ARREA) begin
            busy <= 1;
        end
	end
end

// DRAM

// write_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        write_cnt <= 0;
    end
    else begin
        if (next_state == WRITE_BACK) begin
            write_cnt <= write_cnt + 1;
        end
        else if (next_state == WAIT_WREA || next_state == WAIT_AWREA) begin
            write_cnt <= 0;
        end
        else if (next_state == PUT_S) begin
            write_cnt <= write_cnt + 1;
        end
        else if (next_state == WAIT_RREA || next_state == WIND_R) begin
            write_cnt <= 0;
        end
    end
end

// wready_cnt & his_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wready_cnt <= 0;
        his_cnt <= 0;
    end
    else begin
        if (current_state == WAIT_WREA) begin
            if (inputtype_r == 2'b00) begin
                if (wready_m_inf) begin
                    his_cnt <= his_cnt + 1;
                end
            end
            else begin
                if (wready_cnt == 15) begin
                    his_cnt <= his_cnt + 1;
                    wready_cnt <= 0;
                end
                else if (wready_m_inf) begin
                    wready_cnt <= wready_cnt + 1;
                end
            end
        end
        else if (current_state == WIND_R) begin
            his_cnt <= 0;
        end
        else if (current_state == WAIT_AWREA) begin
            wready_cnt <= 0;
        end
        else if (next_state == PUT_S) begin
            if (wready_cnt == 255) begin
                if (his_cnt == 15) begin
                    his_cnt <= 0;
                end
                else begin
                    his_cnt <= his_cnt + 1;
                end

                wready_cnt <= 0;
            end
            else begin
                wready_cnt <= wready_cnt + 1;
            end
        end
        else if (current_state == IDLE) begin
            his_cnt <= 0;
        end
    end
end

// in_data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_data <= 0;
    end
    else begin
        if (current_state == WAIT_RREA) begin
            in_data <= (rdata_m_inf >> 8);
        end
        else if (next_state == PUT_S) begin
            in_data <= (in_data >> 8);
        end
    end
end

// out_data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_data <= 0;
    end
    else begin
        if (current_state == WRITE_BACK) begin
            if (inputtype_r == 2'b00) begin
                out_data <= {in_w2[his_cnt], in_w1[his_cnt], out_data[127:16]};
            end
            else begin
                out_data <= {in_w2[his_cnt], in_w1[his_cnt], out_data[127:16]};
            end
        end
        else if (current_state == IDLE) begin
            out_data <= 0;
        end
    end
end

// wlast
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wlast_r <= 0;
    end
    else begin
        if (inputtype_r == 2'b00) begin
            if (next_state == WAIT_WREA) begin
                wlast_r <= 1;
            end
            else begin
                wlast_r <= 0;
            end
        end
        else begin
            if (his_cnt == 15 && wready_cnt == 15) begin
                wlast_r <= 1;
            end
            else begin
                wlast_r <= 0;
            end
        end
    end
end

// Read
assign arid_m_inf = 0;
assign arburst_m_inf = 2'b01;
assign arsize_m_inf = 3'b100;
assign arlen_m_inf = 255;
assign arvalid_m_inf = (current_state == WAIT_ARREA)? 1 : 0;
assign araddr_m_inf = {32'h00010000 + 32'h00001000*frame_id_r};
assign rready_m_inf = (current_state == WAIT_RREA)? 1: 0;

// Write
assign awid_m_inf = 0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf = 3'b100;
assign awlen_m_inf = (inputtype_r == 2'b00)? 0 : 255;
assign awvalid_m_inf = (current_state == WAIT_AWREA)? 1 : 0;
assign awaddr_m_inf = (inputtype_r == 2'b00)? {32'h00010000 + 32'h00001000*frame_id_r + 240 + his_cnt*32'h00000100} : {32'h00010000 + 32'h00001000*frame_id_r};
assign wvalid_m_inf = (current_state == WAIT_WREA)? 1 : 0;
assign wdata_m_inf = out_data;
assign wlast_m_inf = wlast_r;
assign bready_m_inf = (current_state == FINISH)? 1 : 0;

endmodule
