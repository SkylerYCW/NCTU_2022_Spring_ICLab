//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

//covergroup Spec1 @();
	
       //finish your covergroup here
	
	
//endgroup

covergroup Spec1 @(negedge clk);
    option.comment = "out_info";
    option.per_instance = 1;
    option.at_least = 20;

    coverpoint inf.out_info[31:28] iff(inf.out_valid) {
        bins stage1 = {No_stage};
        bins stage2 = {Lowest};
        bins stage3 = {Middle};
        bins stage4 = {Highest};
    }

    coverpoint inf.out_info[27:24] iff(inf.out_valid) {
        bins type1 = {No_type};
        bins type2 = {Grass};
        bins type3 = {Fire};
        bins type4 = {Water};
        bins type5 = {Electric};
        bins type6 = {Normal};
    }
endgroup

covergroup Spec2 @(posedge clk);
    option.comment = "id";
    option.per_instance = 1;
    option.at_least = 1;

    coverpoint inf.D.d_id[0] iff(inf.id_valid) {
        option.auto_bin_max = 256; 
    }
endgroup

covergroup Spec3 @(posedge clk);
    option.comment = "act";
    option.per_instance = 1;
    option.at_least = 10;

    coverpoint inf.D.d_act[0] iff(inf.act_valid) {
        bins act[] = (Buy, Sell, Deposit, Check, Use_item, Attack => Buy, Sell, Deposit, Check, Use_item, Attack);
    }
endgroup

covergroup Spec4 @(negedge clk);
    option.comment = "complete";
    option.per_instance = 1;
    option.at_least = 200;

    coverpoint inf.complete iff(inf.out_valid) {
        bins complete1 = {0};
        bins complete2 = {1};
    }
endgroup

covergroup Spec5 @(negedge clk);
    option.comment = "error msg";
    option.per_instance = 1;
    option.at_least = 20;

    coverpoint inf.err_msg iff(inf.out_valid) {
        bins error1 = {Already_Have_PKM};
        bins error2 = {Out_of_money};
        bins error3 = {Bag_is_full};
        bins error4 = {Not_Having_PKM};
        bins error5 = {Has_Not_Grown};
        bins error6 = {Not_Having_Item};
        bins error7 = {HP_is_Zero};
    }
endgroup

//declare the cover group 
Spec1 cov_inst_1 = new();
Spec2 cov_inst_2 = new();
Spec3 cov_inst_3 = new();
Spec4 cov_inst_4 = new();
Spec5 cov_inst_5 = new();

//************************************ below assertion is to check your pattern ***************************************** 
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write the required assertions below
//  assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0 [*2])
//  else
//  begin
//  	$display("Assertion X is violated");
//  	$fatal; 
//  end

//write other assertions

// output signals should be zero after reset
always @(negedge inf.rst_n) begin
    #1;
    assert1_1 : assert ((inf.out_valid === 0) && (inf.complete === 0) && (inf.err_msg === No_Err) && (inf.out_info === 0))
    else begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end
always @(negedge inf.rst_n) begin
    #1;
    assert1_2 : assert ((inf.AR_VALID === 0) && (inf.AR_ADDR === 0) && (inf.R_READY === 0) && (inf.AW_VALID === 0) && (inf.AW_ADDR === 0) && (inf.W_VALID === 0) && (inf.W_DATA === 0) && (inf.B_READY === 0))
    else begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end
always @(negedge inf.rst_n) begin
    #1;
    assert1_3 : assert ((inf.out_valid === 0) && (inf.complete === 0) && (inf.err_msg === No_Err) && (inf.out_info === 0))
    else begin
        $display("Assertion 1 is violated");
        $fatal;
    end
end

// action complete, err_msg should be 4’b0
assert2 : assert property ( @(posedge clk)  (inf.complete === 1 && inf.out_valid === 1) |-> (inf.err_msg === No_Err))
    else begin
        $display("Assertion 2 is violated");
        $fatal; 
    end

// If action is not completed, out_info should be 64’b0
assert3 : assert property ( @(posedge clk)  (inf.complete === 0 && inf.out_valid === 1) |-> (inf.out_info === 64'b0))
    else begin
        $display("Assertion 3 is violated");
        $fatal; 
    end

Action action_r;
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        action_r <= No_action;
    end
    else begin
        if (inf.act_valid) begin
            action_r <= inf.D.d_act[0];
        end
    end
end

// The gap between each input valid is at least 1 cycle and at most 5 cycle
assert4_1 : assert property ( @(posedge clk)  (inf.id_valid === 1 && action_r !== Attack) |-> ##[2:6] (inf.act_valid === 1))
    else begin
        $display("Assertion 4 is violated");
        $fatal; 
    end

assert4_2 : assert property ( @(posedge clk)  (inf.act_valid === 1 && inf.D.d_act[0] !== Check) |-> ##[2:6]
                            ((inf.id_valid === 1) || (inf.item_valid === 1) || (inf.type_valid === 1) || (inf.amnt_valid === 1)))
    else begin
        $display("Assertion 4 is violated");
        $fatal; 
    end

wire [2:0] ch;
assign ch = inf.id_valid + inf.act_valid + inf.amnt_valid + inf.type_valid + inf.item_valid;

// All input valid signals won’t overlap with each other
assert5 : assert property ( @(posedge clk)  ch < 2)
    else begin
        $display("Assertion 5 is violated");
        $fatal; 
    end

// Out_valid can only be high for one cycle
assert6 : assert property ( @(posedge clk)  (inf.out_valid === 1) |=> (inf.out_valid === 0))
    else begin
        $display("Assertion 6 is violated");
        $fatal; 
    end

// Next operation will be valid 2-10 cycles after out_valid fall
assert7_1 : assert property ( @(posedge clk)  (inf.out_valid === 1) |-> ##[2:10]
                            ((inf.id_valid === 1) || (inf.act_valid === 1)))
    else begin
        $display("Assertion 7 is violated");
        $fatal; 
    end

assert7_2 : assert property ( @(posedge clk)  (inf.out_valid === 1) |-> ##1
                            ((inf.id_valid === 0) && (inf.act_valid === 0)))
    else begin
        $display("Assertion 7 is violated");
        $fatal; 
    end


// Latency should be less than 1200 cycles for each operation
assert8_1 : assert property ( @(posedge clk)  (inf.D.d_act[0] === Check) |-> ##[1:1200] (inf.out_valid === 1))
    else begin
        $display("Assertion 8 is violated");
        $fatal; 
    end

assert8_2 : assert property ( @(posedge clk)  ((action_r === Attack) && (inf.id_valid === 1)) |-> ##[1:1200] (inf.out_valid === 1))
    else begin
        $display("Assertion 8 is violated");
        $fatal; 
    end

assert8_3 : assert property ( @(posedge clk)  ((action_r === Buy || action_r === Sell) && (inf.item_valid === 1 || inf.type_valid === 1)) |-> ##[1:1200] (inf.out_valid === 1))
    else begin
        $display("Assertion 8 is violated");
        $fatal; 
    end

assert8_4 : assert property ( @(posedge clk)  ((action_r === Deposit) && (inf.amnt_valid === 1)) |-> ##[1:1200] (inf.out_valid === 1))
    else begin
        $display("Assertion 8 is violated");
        $fatal; 
    end

assert8_5 : assert property ( @(posedge clk)  ((action_r === Use_item) && (inf.item_valid === 1)) |-> ##[1:1200] (inf.out_valid === 1))
    else begin
        $display("Assertion 8 is violated");
        $fatal; 
    end

endmodule