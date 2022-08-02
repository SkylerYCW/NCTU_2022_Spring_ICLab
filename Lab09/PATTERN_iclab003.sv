`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;

//================================================================
// parameters & integer
//================================================================
parameter PATNUM = 1;
integer patcount;
integer lat, total_latency;

parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
logic [7:0] golden_DRAM[ ((65536+256*8)-1) : (65536)];
initial $readmemh(DRAM_p_r, golden_DRAM);

integer i, j, k, gap;
integer buy_item, sell_item;
integer id_gen, id1_gen, id2_gen, act_gen, type_gen, item_gen, amnt_gen;
integer id_num, act_num;
integer pkm_price, pkm_hp, pkm_atk, pkm_exp;
integer item_price;
integer use_bracer;

integer which_act;

Player_Info player1_save;
Player_Info player1_reg;
Player_Info player2_reg;
logic golden_complete;
Error_Msg golden_error_msg;
logic [63:0] golden_out_info;


//================================================================
// wire & registers 
//================================================================


//================================================================
// Class
//================================================================

class Act_generate;
	rand Action action_r;
	
	constraint c_action { action_r inside { Buy, Sell, Deposit, Check, Use_item, Attack}; }  // Modify, Attack, Use_item, Sell
endclass

class Type_generate;
	rand PKM_Type type_r;
	
	constraint c_type { type_r inside {Grass, Fire, Water, Electric, Normal}; }

endclass

class Item_generate;
	rand Item item_r;
	
	constraint c_item { item_r inside {Berry, Medicine, Candy, Bracer, Water_stone, Fire_stone, Thunder_stone}; }

endclass

//================================================================
// initial
//================================================================

initial begin
    reset_task;
    for (patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
        input_task;
    end
    
	pass_task;
end


//================================================================
// task
//================================================================

task reset_task;
    inf.rst_n = 1'b1;
	inf.id_valid = 1'b0;
    inf.act_valid = 1'b0;
    inf.item_valid = 1'b0;
    inf.type_valid = 1'b0;
    inf.amnt_valid = 1'b0;
	inf.D = 'dx;
    total_latency = 0;
    use_bracer = 0;

	#(10);
	inf.rst_n = 1'b0;
    #(10);

    inf.rst_n = 1'b1;
endtask

task input_task;
	id_num = 256;							// Modify
	act_num = 8;                           // Modify

	for (i = 0; i < id_num; i = i + 1) begin
        id1_gen = i;
		id1_task;
        rst_atk1_task;
        use_bracer = 0;
        
        for (j = 0; j < act_num; j = j + 1) begin
            act_task;
        end
	end

endtask

task id1_task;
    gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);

	while (id1_gen === id_gen) begin
        id1_gen = $urandom_range(0, 255);       // Modify $urandom_range(0, 255)
    end
    id_gen = id1_gen;

	inf.id_valid = 1'b1;
	inf.D = {8'b0, id1_gen};
	
	player1_reg.bag_info = {golden_DRAM[65536+id1_gen*8], golden_DRAM[65536+id1_gen*8 + 1], golden_DRAM[65536+id1_gen*8 + 2], golden_DRAM[65536+id1_gen*8 + 3]};
	player1_reg.pkm_info = {golden_DRAM[65536+id1_gen*8 + 4], golden_DRAM[65536+id1_gen*8 + 5], golden_DRAM[65536+id1_gen*8 + 6], golden_DRAM[65536+id1_gen*8 + 7]};
	
	@(negedge clk);
	
	inf.id_valid = 1'b0;
	inf.D = 'dx;
endtask

task id2_task;
    gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);

	id2_gen = $urandom_range(0, 255);
	while (id2_gen === id1_gen) begin
        id2_gen = $urandom_range(0, 255);
    end
	inf.id_valid = 1'b1;
	inf.D = {8'b0, id2_gen};
	
	player2_reg.bag_info = {golden_DRAM[65536+id2_gen*8], golden_DRAM[65536+id2_gen*8 + 1], golden_DRAM[65536+id2_gen*8 + 2], golden_DRAM[65536+id2_gen*8 + 3]};
	player2_reg.pkm_info = {golden_DRAM[65536+id2_gen*8 + 4], golden_DRAM[65536+id2_gen*8 + 5], golden_DRAM[65536+id2_gen*8 + 6], golden_DRAM[65536+id2_gen*8 + 7]};
	
	@(negedge clk);
	
	inf.id_valid = 1'b0;
	inf.D = 'dx;
endtask

task act_task;
	Act_generate act_g = new();
	assert(act_g.randomize());
	act_gen = act_g.action_r;		// act_g.action_r

    gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);
	inf.act_valid = 1'b1;
	inf.D = {12'b0, act_gen};

    overlap_task;
	@(negedge clk);
	
	inf.act_valid = 1'b0;
	inf.D = 'dx;

    case (act_gen)
        Buy: buy_task;
        Sell: sell_task;
        Use_item: use_task; 
        Attack: attack_task;
        Deposit: deposit_task;
        Check: check_task;
    endcase

    wait_out_valid_task;
	
endtask

task buy_task;
	gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);
	
	buy_item = $urandom_range(0, 1);		// 0: buy pkm    1: buy item    $urandom_range(0, 1)
	
	case (buy_item)
		0: begin
			buy_pkm_type_task;
            check_buy_pkm_task;
		end
		1: begin
			buy_item_task;
            check_buy_item_task;
		end
	endcase
    
endtask

task buy_pkm_type_task;
	Type_generate type_g = new();
	assert(type_g.randomize());
	type_gen = type_g.type_r;		// type_g.type_r

    inf.type_valid = 1'b1;
	inf.D = {12'b0, type_gen};
    overlap_task;
	
    if (type_gen == Grass) begin
        pkm_price = 'd100;
        pkm_hp = 'd128;
        pkm_atk = 'd63;
        pkm_exp = 0;
    end
    else if (type_gen == Fire) begin
        pkm_price = 'd90;
        pkm_hp = 'd119;
        pkm_atk = 'd64;
        pkm_exp = 0;
    end
    else if (type_gen == Water) begin
        pkm_price = 'd110;
        pkm_hp = 'd125;
        pkm_atk = 'd60;
        pkm_exp = 0;
    end
    else if (type_gen == Electric) begin
        pkm_price = 'd120;
        pkm_hp = 'd122;
        pkm_atk = 'd65;
        pkm_exp = 0;
    end
    else if (type_gen == Normal) begin
        pkm_price = 'd130;
        pkm_hp = 'd124;
        pkm_atk = 'd62;
        pkm_exp = 0;
    end

    @(negedge clk);
	
	inf.type_valid = 1'b0;
	inf.D = 'dx;

endtask

task buy_item_task;
	Item_generate item_g = new();
	assert(item_g.randomize());
	item_gen = item_g.item_r;		// item_g.item_r

    inf.item_valid = 1'b1;
	inf.D = {12'b0, item_gen};
    overlap_task;

    if (item_gen == Berry) begin
        item_price = 'd16;
    end
    else if (item_gen == Medicine) begin
        item_price = 'd128;
    end
    else if (item_gen == Candy) begin
        item_price = 'd300;
    end
    else if (item_gen == Bracer) begin
        item_price = 'd64;
    end
    else if (item_gen == Water_stone || item_gen == Fire_stone || item_gen == Thunder_stone) begin
        item_price = 'd800;
    end

	@(negedge clk);
	
	inf.item_valid = 1'b0;
	inf.D = 'dx;
endtask

task sell_task;
	gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);
	
    sell_item = $urandom_range(0, 1);		// 0: sell pkm    1: sell item

	case (sell_item)
		0: begin
			sell_pkm_type_task;
            check_sell_pkm_task;
		end
		1: begin
			sell_item_task;
            check_sell_item_task;
		end
	endcase
endtask

task sell_pkm_type_task;
	Type_generate type_g = new();
	assert(type_g.randomize());
	type_gen = No_type;		// type_g

    inf.type_valid = 1'b1;
	inf.D = 0;
    overlap_task;
	
    if (player1_reg.pkm_info.pkm_type == Grass) begin
        if (player1_reg.pkm_info.stage == Middle) begin
            pkm_price = 'd510;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            pkm_price = 'd1100;
        end
        else begin
            pkm_price = 'd0;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Fire) begin
        if (player1_reg.pkm_info.stage == Middle) begin
            pkm_price = 'd450;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            pkm_price = 'd1000;
        end
        else begin
            pkm_price = 'd0;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Water) begin
        if (player1_reg.pkm_info.stage == Middle) begin
            pkm_price = 'd500;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            pkm_price = 'd1200;
        end
        else begin
            pkm_price = 'd0;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Electric) begin
        if (player1_reg.pkm_info.stage == Middle) begin
            pkm_price = 'd550;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            pkm_price = 'd1300;
        end
        else begin
            pkm_price = 'd0;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Normal) begin
        pkm_price = 'd0;
    end

    @(negedge clk);
	
	inf.type_valid = 1'b0;
	inf.D = 'dx;

endtask

task sell_item_task;
	Item_generate item_g = new();
	assert(item_g.randomize());
	item_gen = item_g.item_r;		// item_g.item_r

    inf.item_valid = 1'b1;
	inf.D = {12'b0, item_gen};
    overlap_task;

    if (item_gen == Berry) begin
        item_price = 'd12;
    end
    else if (item_gen == Medicine) begin
        item_price = 'd96;
    end
    else if (item_gen == Candy) begin
        item_price = 'd225;
    end
    else if (item_gen == Bracer) begin
        item_price = 'd48;
    end
    else if (item_gen == Water_stone || item_gen == Fire_stone || item_gen == Thunder_stone) begin
        item_price = 'd600;
    end

	@(negedge clk);
	
	inf.item_valid = 1'b0;
	inf.D = 'dx;
endtask

task use_task;
	gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);
	
	use_item_task;
    check_use_item_task;
endtask

task use_item_task;
	Item_generate item_g = new();
	assert(item_g.randomize());
	item_gen = item_g.item_r;		// item_g.item_r

    inf.item_valid = 1'b1;
	inf.D = {12'b0, item_gen};
    overlap_task;

	@(negedge clk);
	
	inf.item_valid = 1'b0;
	inf.D = 'dx;
endtask

task attack_task;
	id2_task;
    rst_atk2_task;
    check_attack_task;
endtask

task deposit_task;
	gap = $urandom_range(1, 5);
	repeat(gap)@(negedge clk);
	
    amnt_gen = $urandom_range(1, 50);

    inf.amnt_valid = 1'b1;
    inf.D = {2'b0, amnt_gen};
    overlap_task;

	@(negedge clk);
	
	inf.amnt_valid = 1'b0;
	inf.D = 'dx;

    golden_complete = 1;

    player1_reg.bag_info.money = player1_reg.bag_info.money + amnt_gen;
    golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
    golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

    golden_out_info = player1_reg;
    golden_error_msg = No_Err;
endtask

task check_task;
	golden_complete = 1;
    golden_out_info = player1_reg;
    golden_error_msg = No_Err;
endtask

task check_buy_pkm_task;
    if (pkm_price > player1_reg.bag_info.money) begin    // No money
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Out_of_money;
    end
    else if (player1_reg.pkm_info.pkm_type !== No_type || player1_reg.pkm_info.stage !== No_stage) begin    // Have pkm
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Already_Have_PKM;
    end
    else begin
        golden_complete = 1;

        player1_reg.bag_info.money = player1_reg.bag_info.money - pkm_price;
        player1_reg.pkm_info.stage = Lowest;
        player1_reg.pkm_info.pkm_type = type_gen;
        player1_reg.pkm_info.hp = pkm_hp;
        player1_reg.pkm_info.atk = pkm_atk;
        player1_reg.pkm_info.exp = pkm_exp;

        golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
        golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];
        golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
        golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
        golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
        golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

        golden_out_info = player1_reg;

        golden_error_msg = No_Err;
    end
    
endtask

task check_buy_item_task;
    if (item_price > player1_reg.bag_info.money) begin    // No money
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Out_of_money;
    end
    else begin
        if (item_gen == Berry) begin
            if (player1_reg.bag_info.berry_num == 15) begin
                golden_complete = 0;
                golden_out_info = 0;
                golden_error_msg = Bag_is_full;
            end
            else begin
                golden_complete = 1;
                
                player1_reg.bag_info.money = player1_reg.bag_info.money - item_price;
                player1_reg.bag_info.berry_num = player1_reg.bag_info.berry_num + 1;

                golden_DRAM[65536+id1_gen*8][7:4] = player1_reg.bag_info.berry_num;
                golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
                golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

                golden_out_info = player1_reg;
                golden_error_msg = No_Err;
            end
        end
        else if (item_gen == Medicine) begin
            if (player1_reg.bag_info.medicine_num == 15) begin
                golden_complete = 0;
                golden_out_info = 0;
                golden_error_msg = Bag_is_full;
            end
            else begin
                golden_complete = 1;
                
                player1_reg.bag_info.money = player1_reg.bag_info.money - item_price;
                player1_reg.bag_info.medicine_num = player1_reg.bag_info.medicine_num + 1;

                golden_DRAM[65536+id1_gen*8][3:0] = player1_reg.bag_info.medicine_num;
                golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
                golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

                golden_out_info = player1_reg;
                golden_error_msg = No_Err;
            end
        end
        else if (item_gen == Candy) begin
            if (player1_reg.bag_info.candy_num == 15) begin
                golden_complete = 0;
                golden_out_info = 0;
                golden_error_msg = Bag_is_full;
            end
            else begin
                golden_complete = 1;
                
                player1_reg.bag_info.money = player1_reg.bag_info.money - item_price;
                player1_reg.bag_info.candy_num = player1_reg.bag_info.candy_num + 1;

                golden_DRAM[65536+id1_gen*8 + 1][7:4] = player1_reg.bag_info.candy_num;
                golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
                golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

                golden_out_info = player1_reg;
                golden_error_msg = No_Err;
            end
        end
        else if (item_gen == Bracer) begin
            if (player1_reg.bag_info.bracer_num == 15) begin
                golden_complete = 0;
                golden_out_info = 0;
                golden_error_msg = Bag_is_full;
            end
            else begin
                golden_complete = 1;
                
                player1_reg.bag_info.money = player1_reg.bag_info.money - item_price;
                player1_reg.bag_info.bracer_num = player1_reg.bag_info.bracer_num + 1;

                golden_DRAM[65536+id1_gen*8 + 1][3:0] = player1_reg.bag_info.bracer_num;
                golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
                golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

                golden_out_info = player1_reg;
                golden_error_msg = No_Err;
            end
        end
        else if (item_gen == Water_stone || item_gen == Fire_stone || item_gen == Thunder_stone) begin
            if (player1_reg.bag_info.stone !== No_stone) begin
                golden_complete = 0;
                golden_out_info = 0;
                golden_error_msg = Bag_is_full;
            end
            else begin
                golden_complete = 1;
                
                player1_reg.bag_info.money = player1_reg.bag_info.money - item_price;
                if (item_gen == Water_stone) begin
                    player1_reg.bag_info.stone = W_stone;
                end
                else if (item_gen == Fire_stone) begin
                    player1_reg.bag_info.stone = F_stone;
                end
                else if (item_gen == Thunder_stone) begin
                    player1_reg.bag_info.stone = T_stone;
                end
                
                golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
                golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
                golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

                golden_out_info = player1_reg;
                golden_error_msg = No_Err;
            end
        end
    end

endtask

task check_sell_pkm_task;
    if (player1_reg.pkm_info.pkm_type === No_type || player1_reg.pkm_info.stage === No_stage) begin    // No pkm
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Not_Having_PKM;
    end
    else if (player1_reg.pkm_info.stage === Lowest) begin    // pkm lowest
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Has_Not_Grown;
    end
    else begin
        golden_complete = 1;

        player1_reg.bag_info.money = player1_reg.bag_info.money + pkm_price;
        player1_reg.pkm_info.stage = No_stage;
        player1_reg.pkm_info.pkm_type = No_type;
        player1_reg.pkm_info.hp = 0;
        player1_reg.pkm_info.atk = 0;
        player1_reg.pkm_info.exp = 0;
        use_bracer = 0;

        golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
        golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];
        golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
        golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
        golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
        golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

        golden_out_info = player1_reg;

        golden_error_msg = No_Err;
    end
    
endtask

task check_sell_item_task;
    if (item_gen == Berry) begin
        if (player1_reg.bag_info.berry_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.berry_num = player1_reg.bag_info.berry_num - 1;

            golden_DRAM[65536+id1_gen*8][7:4] = player1_reg.bag_info.berry_num;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Medicine) begin
        if (player1_reg.bag_info.medicine_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.medicine_num = player1_reg.bag_info.medicine_num - 1;

            golden_DRAM[65536+id1_gen*8][3:0] = player1_reg.bag_info.medicine_num;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Candy) begin
        if (player1_reg.bag_info.candy_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.candy_num = player1_reg.bag_info.candy_num - 1;

            golden_DRAM[65536+id1_gen*8 + 1][7:4] = player1_reg.bag_info.candy_num;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Bracer) begin
        if (player1_reg.bag_info.bracer_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.bracer_num = player1_reg.bag_info.bracer_num - 1;

            golden_DRAM[65536+id1_gen*8 + 1][3:0] = player1_reg.bag_info.bracer_num;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Water_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone === F_stone || player1_reg.bag_info.stone === T_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.stone = No_stone;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Fire_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone == W_stone || player1_reg.bag_info.stone == T_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.stone = No_stone;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Thunder_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone == W_stone || player1_reg.bag_info.stone == F_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.money = player1_reg.bag_info.money + item_price;
            player1_reg.bag_info.stone = No_stone;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 2][5:0] = player1_reg.bag_info.money[13:8];
            golden_DRAM[65536+id1_gen*8 + 3] = player1_reg.bag_info.money[7:0];

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end

endtask

task check_use_item_task;
    if (player1_reg.pkm_info.pkm_type === No_type || player1_reg.pkm_info.stage === No_stage) begin    // No pkm
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Not_Having_PKM;
    end
    else if (item_gen == Berry) begin
        if (player1_reg.bag_info.berry_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            if (player1_reg.pkm_info.pkm_type == Grass) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.hp < 'd96) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd128;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.hp < 'd160) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd192;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    if (player1_reg.pkm_info.hp < 'd222) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd254;
                    end
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Fire) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.hp < 'd87) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd119;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.hp < 'd145) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd177;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    if (player1_reg.pkm_info.hp < 'd193) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd225;
                    end
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Water) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.hp < 'd93) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd125;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.hp < 'd155) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd187;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    if (player1_reg.pkm_info.hp < 'd213) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd245;
                    end
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Electric) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.hp < 'd90) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd122;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.hp < 'd150) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd182;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    if (player1_reg.pkm_info.hp < 'd203) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd235;
                    end
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Normal) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.hp < 'd92) begin
                        player1_reg.pkm_info.hp = player1_reg.pkm_info.hp + 'd32;
                    end
                    else begin
                        player1_reg.pkm_info.hp = 'd124;
                    end
                end
            end

            player1_reg.bag_info.berry_num = player1_reg.bag_info.berry_num - 1;

            golden_DRAM[65536+id1_gen*8][7:4] = player1_reg.bag_info.berry_num;
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Medicine) begin
        if (player1_reg.bag_info.medicine_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            if (player1_reg.pkm_info.pkm_type == Grass) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    player1_reg.pkm_info.hp = 'd128;
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    player1_reg.pkm_info.hp = 'd192;
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.hp = 'd254;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Fire) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    player1_reg.pkm_info.hp = 'd119;
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    player1_reg.pkm_info.hp = 'd177;
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.hp = 'd225;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Water) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    player1_reg.pkm_info.hp = 'd125;
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    player1_reg.pkm_info.hp = 'd187;
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.hp = 'd245;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Electric) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    player1_reg.pkm_info.hp = 'd122;
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    player1_reg.pkm_info.hp = 'd182;
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.hp = 'd235;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Normal) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    player1_reg.pkm_info.hp = 'd124;
                end
            end

            player1_reg.bag_info.medicine_num = player1_reg.bag_info.medicine_num - 1;

            golden_DRAM[65536+id1_gen*8][3:0] = player1_reg.bag_info.medicine_num;
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Candy) begin
        if (player1_reg.bag_info.candy_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            if (player1_reg.pkm_info.pkm_type == Grass) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.exp < 'd17) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Middle;
                        player1_reg.pkm_info.atk = 'd94;
                        player1_reg.pkm_info.hp = 'd192;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.exp < 'd48) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Highest;
                        player1_reg.pkm_info.atk = 'd123;
                        player1_reg.pkm_info.hp = 'd254;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.exp = 'd0;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Fire) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.exp < 'd15) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Middle;
                        player1_reg.pkm_info.atk = 'd96;
                        player1_reg.pkm_info.hp = 'd177;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.exp < 'd44) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Highest;
                        player1_reg.pkm_info.atk = 'd127;
                        player1_reg.pkm_info.hp = 'd225;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.exp = 'd0;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Water) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.exp < 'd13) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Middle;
                        player1_reg.pkm_info.atk = 'd89;
                        player1_reg.pkm_info.hp = 'd187;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.exp < 'd40) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Highest;
                        player1_reg.pkm_info.atk = 'd113;
                        player1_reg.pkm_info.hp = 'd245;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.exp = 'd0;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Electric) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.exp < 'd11) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Middle;
                        player1_reg.pkm_info.atk = 'd97;
                        player1_reg.pkm_info.hp = 'd182;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Middle) begin
                    if (player1_reg.pkm_info.exp < 'd36) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd0;
                        player1_reg.pkm_info.stage = Highest;
                        player1_reg.pkm_info.atk = 'd124;
                        player1_reg.pkm_info.hp = 'd235;
                        use_bracer = 0;
                    end
                end
                else if (player1_reg.pkm_info.stage == Highest) begin
                    player1_reg.pkm_info.exp = 'd0;
                end
            end
            else if (player1_reg.pkm_info.pkm_type == Normal) begin
                if (player1_reg.pkm_info.stage == Lowest) begin
                    if (player1_reg.pkm_info.exp < 'd14) begin
                        player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd15;
                    end
                    else begin
                        player1_reg.pkm_info.exp = 'd29;
                    end
                end
            end

            player1_reg.bag_info.candy_num = player1_reg.bag_info.candy_num - 1;

            golden_DRAM[65536+id1_gen*8 + 1][7:4] = player1_reg.bag_info.candy_num;
            golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
            golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
            golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Bracer) begin
        if (player1_reg.bag_info.bracer_num == 0) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.bracer_num = player1_reg.bag_info.bracer_num - 1;
            if (use_bracer == 0) begin
                player1_reg.pkm_info.atk = player1_reg.pkm_info.atk + 'd32;
                use_bracer = 1;
            end

            golden_DRAM[65536+id1_gen*8 + 1][3:0] = player1_reg.bag_info.bracer_num;
            golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
            golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Water_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone === F_stone || player1_reg.bag_info.stone === T_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else if (player1_reg.pkm_info.exp !== 'd29 || player1_reg.pkm_info.pkm_type !== Normal) begin
            golden_complete = 1;

            player1_reg.bag_info.stone = No_stone;

            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.stone = No_stone;
            player1_reg.pkm_info.stage = Highest;
            player1_reg.pkm_info.pkm_type = Water;
            player1_reg.pkm_info.hp = 'd245;
            player1_reg.pkm_info.atk = 'd113;
            player1_reg.pkm_info.exp = 'd0;
            use_bracer = 0;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
            golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
            golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Fire_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone == W_stone || player1_reg.bag_info.stone == T_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else if (player1_reg.pkm_info.exp !== 'd29 || player1_reg.pkm_info.pkm_type !== Normal) begin
            golden_complete = 1;

            player1_reg.bag_info.stone = No_stone;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.stone = No_stone;
            player1_reg.pkm_info.stage = Highest;
            player1_reg.pkm_info.pkm_type = Fire;
            player1_reg.pkm_info.hp = 'd225;
            player1_reg.pkm_info.atk = 'd127;
            player1_reg.pkm_info.exp = 'd0;
            use_bracer = 0;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
            golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
            golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end
    else if (item_gen == Thunder_stone) begin
        if (player1_reg.bag_info.stone === No_stone || player1_reg.bag_info.stone == W_stone || player1_reg.bag_info.stone == F_stone) begin
            golden_complete = 0;
            golden_out_info = 0;
            golden_error_msg = Not_Having_Item;
        end
        else if (player1_reg.pkm_info.exp !== 'd29 || player1_reg.pkm_info.pkm_type !== Normal) begin
            golden_complete = 1;

            player1_reg.bag_info.stone = No_stone;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
        else begin
            golden_complete = 1;
            
            player1_reg.bag_info.stone = No_stone;
            player1_reg.pkm_info.stage = Highest;
            player1_reg.pkm_info.pkm_type = Electric;
            player1_reg.pkm_info.hp = 'd235;
            player1_reg.pkm_info.atk = 'd124;
            player1_reg.pkm_info.exp = 'd0;
            use_bracer = 0;
            
            golden_DRAM[65536+id1_gen*8 + 2][7:6] = player1_reg.bag_info.stone;
            golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
            golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
            golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
            golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

            golden_out_info = player1_reg;
            golden_error_msg = No_Err;
        end
    end

endtask

task check_attack_task;
    if (player1_reg.pkm_info.pkm_type === No_type || player1_reg.pkm_info.stage === No_stage) begin    // No pkm
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Not_Having_PKM;
    end
    else if (player2_reg.pkm_info.pkm_type === No_type || player2_reg.pkm_info.stage === No_stage) begin    // No pkm
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = Not_Having_PKM;
    end
    else if (player1_reg.pkm_info.hp === 0) begin
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = HP_is_Zero;
    end
    else if (player2_reg.pkm_info.hp === 0) begin
        golden_complete = 0;
        golden_out_info = 0;
        golden_error_msg = HP_is_Zero;
    end
    else begin
        case (player1_reg.pkm_info.pkm_type)
            Grass: begin
                case (player2_reg.pkm_info.pkm_type)
                    Grass: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Fire: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Water: begin
                        if (player2_reg.pkm_info.hp > 2*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 2*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Electric: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Normal: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                endcase
            end
            Fire: begin
                case (player2_reg.pkm_info.pkm_type)
                    Grass: begin
                        if (player2_reg.pkm_info.hp > 2*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 2*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Fire: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Water: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Electric: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Normal: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                endcase
            end
            Water: begin
                case (player2_reg.pkm_info.pkm_type)
                    Grass: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Fire: begin
                        if (player2_reg.pkm_info.hp > 2*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 2*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Water: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Electric: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Normal: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                endcase
            end
            Electric: begin
                case (player2_reg.pkm_info.pkm_type)
                    Grass: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Fire: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Water: begin
                        if (player2_reg.pkm_info.hp > 2*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 2*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Electric: begin
                        if (player2_reg.pkm_info.hp > 0.5*player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - 0.5*player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                    Normal: begin
                        if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                            player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                        end
                        else begin
                            player2_reg.pkm_info.hp = 'd0;
                        end
                    end
                endcase
            end
            Normal: begin
                if (player2_reg.pkm_info.hp > player1_reg.pkm_info.atk) begin
                    player2_reg.pkm_info.hp = player2_reg.pkm_info.hp - player1_reg.pkm_info.atk;
                end
                else begin
                    player2_reg.pkm_info.hp = 'd0;
                end
            end
        endcase
        
        player1_save = player1_reg;

        // player1 exp
        case (player1_reg.pkm_info.pkm_type)
            Grass: begin
                case (player2_reg.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd16) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd94;
                                    player1_reg.pkm_info.hp = 'd192;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd47) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd123;
                                    player1_reg.pkm_info.hp = 'd254;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd8) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd94;
                                    player1_reg.pkm_info.hp = 'd192;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd39) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd123;
                                    player1_reg.pkm_info.hp = 'd254;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                player1_reg.pkm_info.exp = 'd0;
                                player1_reg.pkm_info.stage = Middle;
                                player1_reg.pkm_info.atk = 'd94;
                                player1_reg.pkm_info.hp = 'd192;
                                use_bracer = 0;
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd31) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd32;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd123;
                                    player1_reg.pkm_info.hp = 'd254;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Fire: begin
                case (player2_reg.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd14) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd96;
                                    player1_reg.pkm_info.hp = 'd177;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd43) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd127;
                                    player1_reg.pkm_info.hp = 'd225;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd6) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd96;
                                    player1_reg.pkm_info.hp = 'd177;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd35) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd127;
                                    player1_reg.pkm_info.hp = 'd225;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                player1_reg.pkm_info.exp = 'd0;
                                player1_reg.pkm_info.stage = Middle;
                                player1_reg.pkm_info.atk = 'd96;
                                player1_reg.pkm_info.hp = 'd177;
                                use_bracer = 0;
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd27) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd32;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd127;
                                    player1_reg.pkm_info.hp = 'd225;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Water: begin
                case (player2_reg.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd12) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd89;
                                    player1_reg.pkm_info.hp = 'd187;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd39) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd113;
                                    player1_reg.pkm_info.hp = 'd245;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd4) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd89;
                                    player1_reg.pkm_info.hp = 'd187;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd31) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd113;
                                    player1_reg.pkm_info.hp = 'd245;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                player1_reg.pkm_info.exp = 'd0;
                                player1_reg.pkm_info.stage = Middle;
                                player1_reg.pkm_info.atk = 'd89;
                                player1_reg.pkm_info.hp = 'd187;
                                use_bracer = 0;
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd23) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd32;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd113;
                                    player1_reg.pkm_info.hp = 'd245;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Electric: begin
                case (player2_reg.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd10) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd97;
                                    player1_reg.pkm_info.hp = 'd182;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd35) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd124;
                                    player1_reg.pkm_info.hp = 'd235;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                if (player1_reg.pkm_info.exp < 'd2) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Middle;
                                    player1_reg.pkm_info.atk = 'd97;
                                    player1_reg.pkm_info.hp = 'd182;
                                    use_bracer = 0;
                                end
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd27) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd124;
                                    player1_reg.pkm_info.hp = 'd235;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player1_reg.pkm_info.stage)
                            Lowest: begin
                                player1_reg.pkm_info.exp = 'd0;
                                player1_reg.pkm_info.stage = Middle;
                                player1_reg.pkm_info.atk = 'd97;
                                player1_reg.pkm_info.hp = 'd182;
                                use_bracer = 0;
                            end
                            Middle: begin
                                if (player1_reg.pkm_info.exp < 'd19) begin
                                    player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd32;
                                end
                                else begin
                                    player1_reg.pkm_info.exp = 'd0;
                                    player1_reg.pkm_info.stage = Highest;
                                    player1_reg.pkm_info.atk = 'd124;
                                    player1_reg.pkm_info.hp = 'd235;
                                    use_bracer = 0;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Normal: begin
                case (player2_reg.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        if (player1_reg.pkm_info.exp < 'd13) begin
                            player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd16;
                        end
                        else begin
                            player1_reg.pkm_info.exp = 'd29;
                        end
                    end
                    Middle: begin
                        if (player1_reg.pkm_info.exp < 'd5) begin
                            player1_reg.pkm_info.exp = player1_reg.pkm_info.exp + 'd24;
                        end
                        else begin
                            player1_reg.pkm_info.exp = 'd29;
                        end
                    end
                    Highest: begin
                        player1_reg.pkm_info.exp = 'd29;
                    end
                endcase
            end
        endcase

        // player2 exp
        case (player2_reg.pkm_info.pkm_type)
            Grass: begin
                case (player1_save.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd24) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd94;
                                    player2_reg.pkm_info.hp = 'd192;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd55) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd123;
                                    player2_reg.pkm_info.hp = 'd254;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd20) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd94;
                                    player2_reg.pkm_info.hp = 'd192;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd51) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd123;
                                    player2_reg.pkm_info.hp = 'd254;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd16) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd94;
                                    player2_reg.pkm_info.hp = 'd192;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd47) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd123;
                                    player2_reg.pkm_info.hp = 'd254;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Fire: begin
                case (player1_save.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd22) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd96;
                                    player2_reg.pkm_info.hp = 'd177;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd51) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd127;
                                    player2_reg.pkm_info.hp = 'd225;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd18) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd96;
                                    player2_reg.pkm_info.hp = 'd177;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd47) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd127;
                                    player2_reg.pkm_info.hp = 'd225;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd14) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd96;
                                    player2_reg.pkm_info.hp = 'd177;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd43) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd127;
                                    player2_reg.pkm_info.hp = 'd225;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Water: begin
                case (player1_save.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd20) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd89;
                                    player2_reg.pkm_info.hp = 'd187;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd47) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd113;
                                    player2_reg.pkm_info.hp = 'd245;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd16) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd89;
                                    player2_reg.pkm_info.hp = 'd187;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd43) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd113;
                                    player2_reg.pkm_info.hp = 'd245;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd12) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd89;
                                    player2_reg.pkm_info.hp = 'd187;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd39) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd113;
                                    player2_reg.pkm_info.hp = 'd245;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Electric: begin
                case (player1_save.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd18) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd97;
                                    player2_reg.pkm_info.hp = 'd182;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd43) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd124;
                                    player2_reg.pkm_info.hp = 'd235;
                                end
                            end
                        endcase
                    end
                    Middle: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd14) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd97;
                                    player2_reg.pkm_info.hp = 'd182;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd39) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd124;
                                    player2_reg.pkm_info.hp = 'd235;
                                end
                            end
                        endcase
                    end
                    Highest: begin
                        case (player2_reg.pkm_info.stage)
                            Lowest: begin
                                if (player2_reg.pkm_info.exp < 'd10) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Middle;
                                    player2_reg.pkm_info.atk = 'd97;
                                    player2_reg.pkm_info.hp = 'd182;
                                end
                            end
                            Middle: begin
                                if (player2_reg.pkm_info.exp < 'd35) begin
                                    player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_reg.pkm_info.exp = 'd0;
                                    player2_reg.pkm_info.stage = Highest;
                                    player2_reg.pkm_info.atk = 'd124;
                                    player2_reg.pkm_info.hp = 'd235;
                                end
                            end
                        endcase
                    end
                endcase
            end
            Normal: begin
                case (player1_save.pkm_info.stage)       // Opponent's stage
                    Lowest: begin
                        if (player2_reg.pkm_info.exp < 'd21) begin
                            player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd8;
                        end
                        else begin
                            player2_reg.pkm_info.exp = 'd29;
                        end
                    end
                    Middle: begin
                        if (player2_reg.pkm_info.exp < 'd17) begin
                            player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd12;
                        end
                        else begin
                            player2_reg.pkm_info.exp = 'd29;
                        end
                    end
                    Highest: begin
                        if (player2_reg.pkm_info.exp < 'd13) begin
                            player2_reg.pkm_info.exp = player2_reg.pkm_info.exp + 'd16;
                        end
                        else begin
                            player2_reg.pkm_info.exp = 'd29;
                        end
                    end
                endcase
            end
        endcase

        rst_atk1_task;
        use_bracer = 0;

        golden_DRAM[65536+id1_gen*8 + 4] = {player1_reg.pkm_info.stage, player1_reg.pkm_info.pkm_type};
        golden_DRAM[65536+id1_gen*8 + 5] = player1_reg.pkm_info.hp;
        golden_DRAM[65536+id1_gen*8 + 6] = player1_reg.pkm_info.atk;
        golden_DRAM[65536+id1_gen*8 + 7] = player1_reg.pkm_info.exp;

        golden_DRAM[65536+id2_gen*8 + 4] = {player2_reg.pkm_info.stage, player2_reg.pkm_info.pkm_type};
        golden_DRAM[65536+id2_gen*8 + 5] = player2_reg.pkm_info.hp;
        golden_DRAM[65536+id2_gen*8 + 6] = player2_reg.pkm_info.atk;
        golden_DRAM[65536+id2_gen*8 + 7] = player2_reg.pkm_info.exp;

        golden_complete = 1;
        golden_out_info = {player1_reg.pkm_info, player2_reg.pkm_info};
        golden_error_msg = No_Err;
    end

endtask

task rst_atk1_task;
    if (player1_reg.pkm_info.pkm_type == Grass) begin
        if (player1_reg.pkm_info.stage == Lowest) begin
            player1_reg.pkm_info.atk = 'd63;
        end
        else if (player1_reg.pkm_info.stage == Middle) begin
            player1_reg.pkm_info.atk = 'd94;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            player1_reg.pkm_info.atk = 'd123;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Fire) begin
        if (player1_reg.pkm_info.stage == Lowest) begin
            player1_reg.pkm_info.atk = 'd64;
        end
        else if (player1_reg.pkm_info.stage == Middle) begin
            player1_reg.pkm_info.atk = 'd96;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            player1_reg.pkm_info.atk = 'd127;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Water) begin
        if (player1_reg.pkm_info.stage == Lowest) begin
            player1_reg.pkm_info.atk = 'd60;
        end
        else if (player1_reg.pkm_info.stage == Middle) begin
            player1_reg.pkm_info.atk = 'd89;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            player1_reg.pkm_info.atk = 'd113;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Electric) begin
        if (player1_reg.pkm_info.stage == Lowest) begin
            player1_reg.pkm_info.atk = 'd65;
        end
        else if (player1_reg.pkm_info.stage == Middle) begin
            player1_reg.pkm_info.atk = 'd97;
        end
        else if (player1_reg.pkm_info.stage == Highest) begin
            player1_reg.pkm_info.atk = 'd124;
        end
    end
    else if (player1_reg.pkm_info.pkm_type == Normal) begin
        if (player1_reg.pkm_info.stage == Lowest) begin
            player1_reg.pkm_info.atk = 'd62;
        end
    end
endtask

task rst_atk2_task;
    if (player2_reg.pkm_info.pkm_type == Grass) begin
        if (player2_reg.pkm_info.stage == Lowest) begin
            player2_reg.pkm_info.atk = 'd63;
        end
        else if (player2_reg.pkm_info.stage == Middle) begin
            player2_reg.pkm_info.atk = 'd94;
        end
        else if (player2_reg.pkm_info.stage == Highest) begin
            player2_reg.pkm_info.atk = 'd123;
        end
    end
    else if (player2_reg.pkm_info.pkm_type == Fire) begin
        if (player2_reg.pkm_info.stage == Lowest) begin
            player2_reg.pkm_info.atk = 'd64;
        end
        else if (player2_reg.pkm_info.stage == Middle) begin
            player2_reg.pkm_info.atk = 'd96;
        end
        else if (player2_reg.pkm_info.stage == Highest) begin
            player2_reg.pkm_info.atk = 'd127;
        end
    end
    else if (player2_reg.pkm_info.pkm_type == Water) begin
        if (player2_reg.pkm_info.stage == Lowest) begin
            player2_reg.pkm_info.atk = 'd60;
        end
        else if (player2_reg.pkm_info.stage == Middle) begin
            player2_reg.pkm_info.atk = 'd89;
        end
        else if (player2_reg.pkm_info.stage == Highest) begin
            player2_reg.pkm_info.atk = 'd113;
        end
    end
    else if (player2_reg.pkm_info.pkm_type == Electric) begin
        if (player2_reg.pkm_info.stage == Lowest) begin
            player2_reg.pkm_info.atk = 'd65;
        end
        else if (player2_reg.pkm_info.stage == Middle) begin
            player2_reg.pkm_info.atk = 'd97;
        end
        else if (player2_reg.pkm_info.stage == Highest) begin
            player2_reg.pkm_info.atk = 'd124;
        end
    end
    else if (player2_reg.pkm_info.pkm_type == Normal) begin
        if (player2_reg.pkm_info.stage == Lowest) begin
            player2_reg.pkm_info.atk = 'd62;
        end
    end
endtask

task overlap_task;
	if (inf.out_valid === 1) begin
		//$display("Out_valid cannot overlap with the input valid signal");
		//$finish;
	end
endtask

task wait_out_valid_task;
    lat = 0;
    while (inf.out_valid !== 1'b1) begin
        lat = lat + 1;
        @(negedge clk);
        //if (lat > 1200) begin
            //$display("Latency over 1200");
			//$finish;
        //end
    end
    total_latency = total_latency + lat;
    if (inf.complete !== golden_complete || inf.err_msg !== golden_error_msg || inf.out_info !== golden_out_info) begin
        //$display("Your complete: %4h     Golden complete: %4h", inf.complete, golden_complete);
        //$display("Your err_msg: %4h      Golden err_msg: %4h", inf.err_msg, golden_error_msg);
        //$display("Your out_info: %4h     Golden out_info: %4h", inf.out_info, golden_out_info);
        $display("Wrong Answer");
		$finish;
    end
	
	repeat(2)@(negedge clk);
	
endtask

task pass_task;
    //$display("********************************************************************");
    //$display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    //$display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    //$display("********************************************************************");
    $finish;
endtask

endprogram

