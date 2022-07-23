module pokemon(input clk, INF.pokemon_inf inf);
import usertype::*;

//================================================================
// logic 
//================================================================

parameter IDLE = 'd0;
parameter GET_ID1 = 'd1;
parameter GET_DATA1 = 'd2;
parameter ACT_BUY = 'd3;
parameter ACT_SELL = 'd4;
parameter ACT_USE = 'd5;
parameter ACT_ATTACK = 'd6;
parameter ACT_DEP = 'd7;
parameter ACT_CHECK = 'd8;
parameter PUT_DATA1_1 = 'd9;
parameter PUT_DATA1_2 = 'd10;
parameter PUT_DATA2_1 = 'd11;
parameter PUT_DATA2_2 = 'd12;
parameter GET_ID2 = 'd13;
parameter GET_DATA2 = 'd14;
parameter FINISH = 'd15;

// Item Price
parameter BERRY_BP = 'd16;
parameter BERRY_SP = 'd12;
parameter MEDICINE_BP = 'd128;
parameter MEDICINE_SP = 'd96;
parameter CANDY_BP = 'd300;
parameter CANDY_SP = 'd225;
parameter BRACER_BP = 'd64;
parameter BRACER_SP = 'd48;
parameter STONE_BP = 'd800;
parameter STONE_SP = 'd600;

// PKM INFO
parameter GRASS_BP = 'd100;
parameter GRASS_MSP = 'd510;
parameter GRASS_HSP = 'd1100;
parameter GRASS_LHP = 'd128;
parameter GRASS_LATK = 'd63;
parameter GRASS_LEXP = 'd32;
parameter GRASS_MHP = 'd192;
parameter GRASS_MATK = 'd94;
parameter GRASS_MEXP = 'd63;
parameter GRASS_HHP = 'd254;
parameter GRASS_HATK = 'd123;

parameter FIRE_BP = 'd90;
parameter FIRE_MSP = 'd450;
parameter FIRE_HSP = 'd1000;
parameter FIRE_LHP = 'd119;
parameter FIRE_LATK = 'd64;
parameter FIRE_LEXP = 'd30;
parameter FIRE_MHP = 'd177;
parameter FIRE_MATK = 'd96;
parameter FIRE_MEXP = 'd59;
parameter FIRE_HHP = 'd225;
parameter FIRE_HATK = 'd127;

parameter WATER_BP = 'd110;
parameter WATER_MSP = 'd500;
parameter WATER_HSP = 'd1200;
parameter WATER_LHP = 'd125;
parameter WATER_LATK = 'd60;
parameter WATER_LEXP = 'd28;
parameter WATER_MHP = 'd187;
parameter WATER_MATK = 'd89;
parameter WATER_MEXP = 'd55;
parameter WATER_HHP = 'd245;
parameter WATER_HATK = 'd113;

parameter ELECTRIC_BP = 'd120;
parameter ELECTRIC_MSP = 'd550;
parameter ELECTRIC_HSP = 'd1300;
parameter ELECTRIC_LHP = 'd122;
parameter ELECTRIC_LATK = 'd65;
parameter ELECTRIC_LEXP = 'd26;
parameter ELECTRIC_MHP = 'd182;
parameter ELECTRIC_MATK = 'd97;
parameter ELECTRIC_MEXP = 'd51;
parameter ELECTRIC_HHP = 'd235;
parameter ELECTRIC_HATK = 'd124;

parameter NORMAL_BP = 'd130;
parameter NORMAL_HP = 'd124;
parameter NORMAL_ATK = 'd62;
parameter NORMAL_EXP = 'd29;


logic [4:0] current_state, next_state;

logic do_id, do_act, do_item, do_type, do_amnt, do_attack;
logic [15:0] act_s;

logic use_bracer;

Player_id id1_r;
Player_id id2_r;
Action act_r;
Item item_r;
PKM_Type type_r;
Money_ext amnt_r;

Error_Msg err_msg_r;
logic complete_r;
Player_Info out_r;

logic [2:0] pokemon_num;

Player_Info player1_data;
Player_Info player2_data;
PKM_Info p2_pkm;

//================================================================
// design 
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        
    end
    else begin
        
    end
end
always_comb begin

end

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
            if (do_act) 
                if (act_r == Buy && (do_item || do_type))           next_state = ACT_BUY;
                else if (act_r == Sell && (do_item || do_type))     next_state = ACT_SELL;
                else if (act_r == Deposit && do_amnt)  next_state = ACT_DEP;
                else if (act_r == Use_item && do_item) next_state = ACT_USE;
                else if (act_r == Check)    next_state = ACT_CHECK;
                else if (act_r == Attack && do_attack)   next_state = GET_ID2;
                else                        next_state = current_state;
            else if (inf.id_valid)           next_state = GET_ID1;
            else                        next_state = current_state;
        end
        GET_ID1: begin
                                    next_state = GET_DATA1;
        end
        GET_DATA1: begin
            if (inf.C_out_valid)            next_state = IDLE;
            else                    next_state = current_state;
        end
        ACT_BUY: begin
                                    next_state = PUT_DATA1_1;
        end
        ACT_SELL: begin
                                    next_state = PUT_DATA1_1;
        end
        ACT_USE: begin
                                    next_state = PUT_DATA1_1;
        end
        ACT_ATTACK: begin
                                    next_state = PUT_DATA2_1;
        end
        ACT_DEP: begin
                                    next_state = PUT_DATA1_1;
        end
        ACT_CHECK: begin
                                    next_state = FINISH;
        end
        
        PUT_DATA1_1: begin
                                    next_state = PUT_DATA1_2;
        end
        PUT_DATA1_2: begin
            if (inf.C_out_valid)        next_state = FINISH;
            else                    next_state = current_state;
        end
        PUT_DATA2_1: begin
                                    next_state = PUT_DATA2_2;
        end
        PUT_DATA2_2: begin
            if (inf.C_out_valid)        next_state = PUT_DATA1_1;
            else                    next_state = current_state;
        end
        GET_ID2: begin
                                    next_state = GET_DATA2;
        end
        GET_DATA2: begin
            if (inf.C_out_valid)            next_state = ACT_ATTACK;
            else                    next_state = current_state;
        end
        FINISH: begin
                                    next_state = IDLE;
        end
        default: begin
                                    next_state = current_state;
        end
    endcase
end

// Do action
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        do_act <= 0;
    end
    else begin
        if (inf.act_valid) begin
            do_act <= 1;
        end
        else if (next_state == FINISH) begin
            do_act <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        do_item <= 0;
    end
    else begin
        if (inf.item_valid) begin
            do_item <= 1;
        end
        else if (next_state == FINISH) begin
            do_item <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        do_type <= 0;
    end
    else begin
        if (inf.type_valid) begin
            do_type <= 1;
        end
        else if (next_state == FINISH) begin
            do_type <= 0;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        do_amnt <= 0;
    end
    else begin
        if (inf.amnt_valid) begin
            do_amnt <= 1;
        end
        else if (next_state == FINISH) begin
            do_amnt <= 0;
        end
    end
end

// Do attack
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        do_attack <= 0;
    end
    else begin
        if (act_r == Attack && inf.id_valid) begin
            do_attack <= 1;
        end
        else if (current_state == FINISH) begin
            do_attack <= 0;
        end
    end
end

// ID1 & ID2
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        id1_r <= 0;
    end
    else begin
        if (next_state == GET_ID1) begin
            id1_r <= inf.D.d_id;
        end
    end
end
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        id2_r <= 0;
    end
    else begin
        if (act_r == Attack && inf.id_valid) begin
            id2_r <= inf.D.d_id;
        end
    end
end

// Action
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        act_r <= 0;
    end
    else begin
        if (inf.act_valid) begin
            act_r <= inf.D.d_act;
        end
        else if (next_state == PUT_DATA1_1) begin
            act_r <= 0;
        end
    end
end

// Type
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        type_r <= 0;
    end
    else begin
        if (inf.type_valid) begin
            type_r <= inf.D.d_type;
        end
        else if (next_state == PUT_DATA1_1) begin
            type_r <= 0;
        end
    end
end

// Item
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        item_r <= 0;
    end
    else begin
        if (inf.item_valid) begin
            item_r <= inf.D.d_item;
        end
        else if (next_state == PUT_DATA1_1) begin
            item_r <= 0;
        end
    end
end

// Amount of money
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        amnt_r <= 0;
    end
    else begin
        if (inf.amnt_valid) begin
            amnt_r <= inf.D.d_money;
        end
        else if (next_state == PUT_DATA1_1) begin
            amnt_r <= 0;
        end
    end
end

// Use bracer
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        use_bracer <= 0;
    end
    else begin
        if (current_state == GET_ID1) begin
            use_bracer <= 0;
        end
        else if (current_state == ACT_SELL) begin
            if (item_r != No_item) begin            // Sell item
            end
            else begin       // Sell pkm
                if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
                end
                else begin
                    case (player1_data.pkm_info.pkm_type)
                        Grass: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                use_bracer <= 0;
                            end
                        end
                        Fire: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                use_bracer <= 0;
                            end
                        end
                        Water: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                use_bracer <= 0;
                            end
                        end
                        Electric: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                use_bracer <= 0;
                            end
                        end
                    endcase
                end
            end
        end
        else if (current_state == ACT_USE) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else begin
                case (item_r)
                    Candy: begin
                        if (player1_data.bag_info.candy_num == 0) begin
                        end
                        else begin
                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd17) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd48) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd15) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd44) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd13) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd40) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd11) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd36) begin
                                            end
                                            else begin
                                                use_bracer <= 0;
                                            end
                                        end
                                    endcase
                                end
                            endcase
                        end
                    end
                    Bracer: begin
                        if (player1_data.bag_info.bracer_num == 0) begin
                        end
                        else begin
                            if (use_bracer == 0) begin
                                use_bracer <= 1;
                            end
                        end
                    end
                    Water_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == F_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                        end
                        else begin
                            use_bracer <= 0;
                        end
                    end
                    Fire_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                        end
                        else begin
                            use_bracer <= 0;
                        end
                    end
                    Thunder_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == F_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                        end
                        else begin
                            use_bracer <= 0;
                        end
                    end
                endcase
            end
        end
        else if (current_state == ACT_ATTACK) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player2_data.pkm_info.pkm_type == No_type || player2_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player1_data.pkm_info.hp == 0) begin
            end
            else if (player2_data.pkm_info.hp == 0) begin
            end
            else begin
                use_bracer <= 0;
                /*
                // player1 exp
                case (player1_data.pkm_info.pkm_type)
                    Grass: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd16) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd47) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd8) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        use_bracer <= 0;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Fire: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd14) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd43) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd6) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        use_bracer <= 0;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Water: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd12) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd4) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        use_bracer <= 0;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd23) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Electric: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd10) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd2) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        use_bracer <= 0;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd19) begin
                                        end
                                        else begin
                                            use_bracer <= 0;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                endcase
                */
            end
        end
    end
end

// complete out_info err_msg
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        complete_r <= 0;
        out_r <= 0;
        err_msg_r <= 0;
    end
    else begin
        if (current_state == IDLE) begin
            out_r <= player1_data;
        end
        else if (current_state == ACT_BUY) begin
            if (type_r == No_type) begin            // Buy item
                case (item_r)
                    Berry: begin
                        if (BERRY_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.bag_info.berry_num == 15) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Bag_is_full;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.berry_num <= player1_data.bag_info.berry_num + 1;
                            out_r.bag_info.money <= player1_data.bag_info.money - BERRY_BP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Medicine: begin
                        if (MEDICINE_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.bag_info.medicine_num == 15) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Bag_is_full;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.medicine_num <= player1_data.bag_info.medicine_num + 1;
                            out_r.bag_info.money <= player1_data.bag_info.money - MEDICINE_BP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Candy: begin
                        if (CANDY_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.bag_info.candy_num == 15) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Bag_is_full;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.candy_num <= player1_data.bag_info.candy_num + 1;
                            out_r.bag_info.money <= player1_data.bag_info.money - CANDY_BP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Bracer: begin
                        if (BRACER_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.bag_info.bracer_num == 15) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Bag_is_full;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.bracer_num <= player1_data.bag_info.bracer_num + 1;
                            out_r.bag_info.money <= player1_data.bag_info.money - BRACER_BP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Water_stone, Fire_stone, Thunder_stone: begin
                        if (STONE_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.bag_info.stone != No_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Bag_is_full;
                        end
                        else begin
                            complete_r <= 1;

                            if (item_r == Water_stone) begin
                                out_r.bag_info.stone <= W_stone;
                            end
                            else if (item_r == Fire_stone) begin
                                out_r.bag_info.stone <= F_stone;
                            end
                            else if (item_r == Thunder_stone) begin
                                out_r.bag_info.stone <= T_stone;
                            end

                            out_r.bag_info.money <= player1_data.bag_info.money - STONE_BP;

                            err_msg_r <= No_Err;
                        end
                    end
                endcase
            end
            else if (item_r == No_item) begin       // Buy pkm
                case (type_r)
                    Grass: begin
                        if (GRASS_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Already_Have_PKM;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.money <= player1_data.bag_info.money - GRASS_BP;
                            out_r.pkm_info.stage <= Lowest;
                            out_r.pkm_info.pkm_type <= Grass;
                            out_r.pkm_info.hp <= GRASS_LHP;
                            out_r.pkm_info.atk <= GRASS_LATK;
                            out_r.pkm_info.exp <= 0;

                            err_msg_r <= No_Err;
                        end
                    end
                    Fire: begin
                        if (FIRE_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Already_Have_PKM;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.money <= player1_data.bag_info.money - FIRE_BP;
                            out_r.pkm_info.stage <= Lowest;
                            out_r.pkm_info.pkm_type <= Fire;
                            out_r.pkm_info.hp <= FIRE_LHP;
                            out_r.pkm_info.atk <= FIRE_LATK;
                            out_r.pkm_info.exp <= 0;

                            err_msg_r <= No_Err;
                        end
                    end
                    Water: begin
                        if (WATER_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Already_Have_PKM;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.money <= player1_data.bag_info.money - WATER_BP;
                            out_r.pkm_info.stage <= Lowest;
                            out_r.pkm_info.pkm_type <= Water;
                            out_r.pkm_info.hp <= WATER_LHP;
                            out_r.pkm_info.atk <= WATER_LATK;
                            out_r.pkm_info.exp <= 0;

                            err_msg_r <= No_Err;
                        end
                    end
                    Electric: begin
                        if (ELECTRIC_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Already_Have_PKM;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.money <= player1_data.bag_info.money - ELECTRIC_BP;
                            out_r.pkm_info.stage <= Lowest;
                            out_r.pkm_info.pkm_type <= Electric;
                            out_r.pkm_info.hp <= ELECTRIC_LHP;
                            out_r.pkm_info.atk <= ELECTRIC_LATK;
                            out_r.pkm_info.exp <= 0;

                            err_msg_r <= No_Err;
                        end
                    end
                    Normal: begin
                        if (NORMAL_BP > player1_data.bag_info.money) begin    // No money
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Out_of_money;
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Already_Have_PKM;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.money <= player1_data.bag_info.money - NORMAL_BP;
                            out_r.pkm_info.stage <= Lowest;
                            out_r.pkm_info.pkm_type <= Normal;
                            out_r.pkm_info.hp <= NORMAL_HP;
                            out_r.pkm_info.atk <= NORMAL_ATK;
                            out_r.pkm_info.exp <= 0;

                            err_msg_r <= No_Err;
                        end
                    end
                endcase
            end
        end
        else if (current_state == ACT_SELL) begin
            if (item_r != No_item) begin            // Sell item
                case (item_r)
                    Berry: begin
                        if (player1_data.bag_info.berry_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.berry_num <= player1_data.bag_info.berry_num - 1;
                            out_r.bag_info.money <= player1_data.bag_info.money + BERRY_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Medicine: begin
                        if (player1_data.bag_info.medicine_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.medicine_num <= player1_data.bag_info.medicine_num - 1;
                            out_r.bag_info.money <= player1_data.bag_info.money + MEDICINE_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Candy: begin
                        if (player1_data.bag_info.candy_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.candy_num <= player1_data.bag_info.candy_num - 1;
                            out_r.bag_info.money <= player1_data.bag_info.money + CANDY_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Bracer: begin
                        if (player1_data.bag_info.bracer_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.bracer_num <= player1_data.bag_info.bracer_num - 1;
                            out_r.bag_info.money <= player1_data.bag_info.money + BRACER_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Water_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == F_stone || player1_data.bag_info.stone == T_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.stone <= No_stone;
                            out_r.bag_info.money <= player1_data.bag_info.money + STONE_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Fire_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == T_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.stone <= No_stone;
                            out_r.bag_info.money <= player1_data.bag_info.money + STONE_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                    Thunder_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == F_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;

                            out_r.bag_info.stone <= No_stone;
                            out_r.bag_info.money <= player1_data.bag_info.money + STONE_SP;

                            err_msg_r <= No_Err;
                        end
                    end
                endcase
            end
            else begin       // Sell pkm
                if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
                    complete_r <= 0;
                    out_r <= 0;
                    err_msg_r <= Not_Having_PKM;
                end
                else begin
                    case (player1_data.pkm_info.pkm_type)
                        Grass: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                                complete_r <= 0;
                                out_r <= 0;
                                err_msg_r <= Has_Not_Grown;
                            end
                            else begin
                                complete_r <= 1;

                                if (player1_data.pkm_info.stage == Middle) begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + GRASS_MSP;
                                end
                                else begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + GRASS_HSP;
                                end
                                
                                out_r.pkm_info.stage <= No_stage;
                                out_r.pkm_info.pkm_type <= No_type;
                                out_r.pkm_info.hp <= 0;
                                out_r.pkm_info.atk <= 0;
                                out_r.pkm_info.exp <= 0;

                                err_msg_r <= No_Err;
                            end
                        end
                        Fire: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                                complete_r <= 0;
                                out_r <= 0;
                                err_msg_r <= Has_Not_Grown;
                            end
                            else begin
                                complete_r <= 1;

                                if (player1_data.pkm_info.stage == Middle) begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + FIRE_MSP;
                                end
                                else begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + FIRE_HSP;
                                end
                                
                                out_r.pkm_info.stage <= No_stage;
                                out_r.pkm_info.pkm_type <= No_type;
                                out_r.pkm_info.hp <= 0;
                                out_r.pkm_info.atk <= 0;
                                out_r.pkm_info.exp <= 0;

                                err_msg_r <= No_Err;
                            end
                        end
                        Water: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                                complete_r <= 0;
                                out_r <= 0;
                                err_msg_r <= Has_Not_Grown;
                            end
                            else begin
                                complete_r <= 1;

                                if (player1_data.pkm_info.stage == Middle) begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + WATER_MSP;
                                end
                                else begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + WATER_HSP;
                                end
                                
                                out_r.pkm_info.stage <= No_stage;
                                out_r.pkm_info.pkm_type <= No_type;
                                out_r.pkm_info.hp <= 0;
                                out_r.pkm_info.atk <= 0;
                                out_r.pkm_info.exp <= 0;

                                err_msg_r <= No_Err;
                            end
                        end
                        Electric: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                                complete_r <= 0;
                                out_r <= 0;
                                err_msg_r <= Has_Not_Grown;
                            end
                            else begin
                                complete_r <= 1;

                                if (player1_data.pkm_info.stage == Middle) begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + ELECTRIC_MSP;
                                end
                                else begin
                                    out_r.bag_info.money <= player1_data.bag_info.money + ELECTRIC_HSP;
                                end
                                
                                out_r.pkm_info.stage <= No_stage;
                                out_r.pkm_info.pkm_type <= No_type;
                                out_r.pkm_info.hp <= 0;
                                out_r.pkm_info.atk <= 0;
                                out_r.pkm_info.exp <= 0;

                                err_msg_r <= No_Err;
                            end
                        end
                        Normal: begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Has_Not_Grown;
                        end
                    endcase
                end
            end
        end
        else if (current_state == ACT_CHECK) begin
            complete_r <= 1;
            out_r <= player1_data;
            err_msg_r <= No_Err;
        end
        else if (current_state == ACT_DEP) begin
            complete_r <= 1;
            out_r.bag_info.money <= player1_data.bag_info.money + amnt_r;
            err_msg_r <= No_Err;
        end
        else if (current_state == ACT_USE) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
                complete_r <= 0;
                out_r <= 0;
                err_msg_r <= Not_Having_PKM;
            end
            else begin
                case (item_r)
                    Berry: begin
                        if (player1_data.bag_info.berry_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.berry_num <= player1_data.bag_info.berry_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd96) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd128;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd160) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd192;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd222) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd254;
                                            end
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd87) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd119;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd145) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd177;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd193) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd225;
                                            end
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd93) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd125;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd155) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd187;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd213) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd245;
                                            end
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd90) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd122;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd150) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd182;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd203) begin
                                                out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                out_r.pkm_info.hp <= 'd235;
                                            end
                                        end
                                    endcase
                                end
                                Normal: begin
                                    if (player1_data.pkm_info.hp < 'd92) begin
                                        out_r.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                    end
                                    else begin
                                        out_r.pkm_info.hp <= 'd124;
                                    end
                                end
                            endcase
                        end
                    end
                    Medicine: begin
                        if (player1_data.bag_info.medicine_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.medicine_num <= player1_data.bag_info.medicine_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            out_r.pkm_info.hp <= 'd128;
                                        end
                                        Middle: begin
                                            out_r.pkm_info.hp <= 'd192;
                                        end
                                        Highest: begin
                                            out_r.pkm_info.hp <= 'd254;
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            out_r.pkm_info.hp <= 'd119;
                                        end
                                        Middle: begin
                                            out_r.pkm_info.hp <= 'd177;
                                        end
                                        Highest: begin
                                            out_r.pkm_info.hp <= 'd225;
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            out_r.pkm_info.hp <= 'd125;
                                        end
                                        Middle: begin
                                            out_r.pkm_info.hp <= 'd187;
                                        end
                                        Highest: begin
                                            out_r.pkm_info.hp <= 'd245;
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            out_r.pkm_info.hp <= 'd122;
                                        end
                                        Middle: begin
                                            out_r.pkm_info.hp <= 'd182;
                                        end
                                        Highest: begin
                                            out_r.pkm_info.hp <= 'd235;
                                        end
                                    endcase
                                end
                                Normal: begin
                                    out_r.pkm_info.hp <= 'd124;
                                end
                            endcase
                        end
                    end
                    Candy: begin
                        if (player1_data.bag_info.candy_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.candy_num <= player1_data.bag_info.candy_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd17) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Middle;
                                                out_r.pkm_info.atk <= 'd94;
                                                out_r.pkm_info.hp <= 'd192;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd48) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Highest;
                                                out_r.pkm_info.atk <= 'd123;
                                                out_r.pkm_info.hp <= 'd254;
                                            end
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd15) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Middle;
                                                out_r.pkm_info.atk <= 'd96;
                                                out_r.pkm_info.hp <= 'd177;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd44) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Highest;
                                                out_r.pkm_info.atk <= 'd127;
                                                out_r.pkm_info.hp <= 'd225;
                                            end
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd13) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Middle;
                                                out_r.pkm_info.atk <= 'd89;
                                                out_r.pkm_info.hp <= 'd187;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd40) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Highest;
                                                out_r.pkm_info.atk <= 'd113;
                                                out_r.pkm_info.hp <= 'd245;
                                            end
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd11) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Middle;
                                                out_r.pkm_info.atk <= 'd97;
                                                out_r.pkm_info.hp <= 'd182;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd36) begin
                                                out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                out_r.pkm_info.exp <= 'd0;
                                                out_r.pkm_info.stage <= Highest;
                                                out_r.pkm_info.atk <= 'd124;
                                                out_r.pkm_info.hp <= 'd235;
                                            end
                                        end
                                    endcase
                                end
                                Normal: begin
                                    if (player1_data.pkm_info.exp < 'd14) begin
                                        out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                    end
                                    else begin
                                        out_r.pkm_info.exp <= 'd29;
                                    end
                                end
                            endcase
                        end
                    end
                    Bracer: begin
                        if (player1_data.bag_info.bracer_num == 0) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.bracer_num <= player1_data.bag_info.bracer_num - 1;
                            
                            if (use_bracer == 0) begin
                                out_r.pkm_info.atk <= player1_data.pkm_info.atk + 'd32;
                            end
                        end
                    end
                    Water_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == F_stone || player1_data.bag_info.stone == T_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            complete_r <= 1;
                            out_r.bag_info.stone <= No_stone;
                            err_msg_r <= No_Err;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.stone <= No_stone;
                            out_r.pkm_info.stage <= Highest;
                            out_r.pkm_info.pkm_type <= Water;
                            out_r.pkm_info.hp <= 'd245;
                            out_r.pkm_info.atk <= 'd113;
                            out_r.pkm_info.exp <= 'd0;
                        end
                    end
                    Fire_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == T_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            complete_r <= 1;
                            out_r.bag_info.stone <= No_stone;
                            err_msg_r <= No_Err;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.stone <= No_stone;
                            out_r.pkm_info.stage <= Highest;
                            out_r.pkm_info.pkm_type <= Fire;
                            out_r.pkm_info.hp <= 'd225;
                            out_r.pkm_info.atk <= 'd127;
                            out_r.pkm_info.exp <= 'd0;
                        end
                    end
                    Thunder_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == F_stone) begin
                            complete_r <= 0;
                            out_r <= 0;
                            err_msg_r <= Not_Having_Item;
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            complete_r <= 1;
                            out_r.bag_info.stone <= No_stone;
                            err_msg_r <= No_Err;
                        end
                        else begin
                            complete_r <= 1;
                            err_msg_r <= No_Err;

                            out_r.bag_info.stone <= No_stone;
                            out_r.pkm_info.stage <= Highest;
                            out_r.pkm_info.pkm_type <= Electric;
                            out_r.pkm_info.hp <= 'd235;
                            out_r.pkm_info.atk <= 'd124;
                            out_r.pkm_info.exp <= 'd0;
                        end
                    end
                endcase
            end
        end
        else if (current_state == ACT_ATTACK) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
                complete_r <= 0;
                out_r <= 0;
                err_msg_r <= Not_Having_PKM;
            end
            else if (player2_data.pkm_info.pkm_type == No_type || player2_data.pkm_info.stage == No_stage) begin    // No pkm
                complete_r <= 0;
                out_r <= 0;
                err_msg_r <= Not_Having_PKM;
            end
            else if (player1_data.pkm_info.hp == 0) begin
                complete_r <= 0;
                out_r <= 0;
                err_msg_r <= HP_is_Zero;
            end
            else if (player2_data.pkm_info.hp == 0) begin
                complete_r <= 0;
                out_r <= 0;
                err_msg_r <= HP_is_Zero;
            end
            else begin
                complete_r <= 1;
                out_r <= 1;
                err_msg_r <= No_Err;
                /*
                // player1 exp
                case (player1_data.pkm_info.pkm_type)
                    Grass: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (out_r.pkm_info.exp < 'd16) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd94;
                                            out_r.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd47) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd123;
                                            out_r.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd8) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd94;
                                            out_r.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd123;
                                            out_r.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        out_r.pkm_info.exp <= 'd0;
                                        out_r.pkm_info.stage <= Middle;
                                        out_r.pkm_info.atk <= 'd94;
                                        out_r.pkm_info.hp <= 'd192;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd123;
                                            out_r.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Fire: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd14) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd96;
                                            out_r.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd43) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd127;
                                            out_r.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd6) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd96;
                                            out_r.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd127;
                                            out_r.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        out_r.pkm_info.exp <= 'd0;
                                        out_r.pkm_info.stage <= Middle;
                                        out_r.pkm_info.atk <= 'd96;
                                        out_r.pkm_info.hp <= 'd177;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd127;
                                            out_r.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Water: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd12) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd89;
                                            out_r.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd113;
                                            out_r.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd4) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd89;
                                            out_r.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd113;
                                            out_r.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        out_r.pkm_info.exp <= 'd0;
                                        out_r.pkm_info.stage <= Middle;
                                        out_r.pkm_info.atk <= 'd89;
                                        out_r.pkm_info.hp <= 'd187;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd23) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd113;
                                            out_r.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Electric: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd10) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd97;
                                            out_r.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd124;
                                            out_r.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd2) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Middle;
                                            out_r.pkm_info.atk <= 'd97;
                                            out_r.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd124;
                                            out_r.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        out_r.pkm_info.exp <= 'd0;
                                        out_r.pkm_info.stage <= Middle;
                                        out_r.pkm_info.atk <= 'd97;
                                        out_r.pkm_info.hp <= 'd182;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd19) begin
                                            out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            out_r.pkm_info.exp <= 'd0;
                                            out_r.pkm_info.stage <= Highest;
                                            out_r.pkm_info.atk <= 'd124;
                                            out_r.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Normal: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                if (player1_data.pkm_info.exp < 'd13) begin
                                    out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                end
                                else begin
                                    out_r.pkm_info.exp <= 'd29;
                                end
                            end
                            Middle: begin
                                if (player1_data.pkm_info.exp < 'd5) begin
                                    out_r.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                end
                                else begin
                                    out_r.pkm_info.exp <= 'd29;
                                end
                            end
                            Highest: begin
                                out_r.pkm_info.exp <= 'd29;
                            end
                        endcase
                    end
                endcase
*/
            end
        end
    end
end

// Player1 data
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        player1_data <= 0;
    end
    else begin
        if (current_state == GET_DATA1) begin
            player1_data.pkm_info.stage <= inf.C_data_r[39:36];
            player1_data.pkm_info.pkm_type <= inf.C_data_r[35:32];
            player1_data.pkm_info.hp <= inf.C_data_r[47:40];
            player1_data.pkm_info.atk <= inf.C_data_r[55:48];
            player1_data.pkm_info.exp <= inf.C_data_r[63:56];
            player1_data.bag_info.berry_num <= inf.C_data_r[7:4];
            player1_data.bag_info.medicine_num <= inf.C_data_r[3:0];
            player1_data.bag_info.candy_num <= inf.C_data_r[15:12];
            player1_data.bag_info.bracer_num <= inf.C_data_r[11:8];
            player1_data.bag_info.stone <= inf.C_data_r[23:22];
            player1_data.bag_info.money[13:8] <= inf.C_data_r[21:16];
            player1_data.bag_info.money[7:0] <= inf.C_data_r[31:24];
        end
        else if (current_state == ACT_BUY) begin
            if (type_r == No_type) begin            //Buy item
                case (item_r)
                    Berry: begin
                        if (BERRY_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.bag_info.berry_num == 15) begin
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - BERRY_BP;
                            player1_data.bag_info.berry_num <= player1_data.bag_info.berry_num + 1;
                        end
                    end
                    Medicine: begin
                        if (MEDICINE_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.bag_info.medicine_num == 15) begin
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - MEDICINE_BP;
                            player1_data.bag_info.medicine_num <= player1_data.bag_info.medicine_num + 1;
                        end
                    end
                    Candy: begin
                        if (CANDY_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.bag_info.candy_num == 15) begin
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - CANDY_BP;
                            player1_data.bag_info.candy_num <= player1_data.bag_info.candy_num + 1;
                        end
                    end
                    Bracer: begin
                        if (BRACER_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.bag_info.bracer_num == 15) begin
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - BRACER_BP;
                            player1_data.bag_info.bracer_num <= player1_data.bag_info.bracer_num + 1;
                        end
                    end
                    Water_stone, Fire_stone, Thunder_stone: begin
                        if (STONE_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.bag_info.stone != No_stone) begin
                        end
                        else begin
                            if (item_r == Water_stone) begin
                                player1_data.bag_info.stone <= W_stone;
                            end
                            else if (item_r == Fire_stone) begin
                                player1_data.bag_info.stone <= F_stone;
                            end
                            else if (item_r == Thunder_stone) begin
                                player1_data.bag_info.stone <= T_stone;
                            end

                            player1_data.bag_info.money <= player1_data.bag_info.money - STONE_BP;
                        end
                    end
                endcase
            end
            else if (item_r == No_item) begin       // Buy pkm
                case (type_r)
                    Grass: begin
                        if (GRASS_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - GRASS_BP;
                            player1_data.pkm_info.stage <= Lowest;
                            player1_data.pkm_info.pkm_type <= Grass;
                            player1_data.pkm_info.hp <= GRASS_LHP;
                            player1_data.pkm_info.atk <= GRASS_LATK;
                            player1_data.pkm_info.exp <= 0;
                        end
                    end
                    Fire: begin
                        if (FIRE_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - FIRE_BP;
                            player1_data.pkm_info.stage <= Lowest;
                            player1_data.pkm_info.pkm_type <= Fire;
                            player1_data.pkm_info.hp <= FIRE_LHP;
                            player1_data.pkm_info.atk <= FIRE_LATK;
                            player1_data.pkm_info.exp <= 0;
                        end
                    end
                    Water: begin
                        if (WATER_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - WATER_BP;
                            player1_data.pkm_info.stage <= Lowest;
                            player1_data.pkm_info.pkm_type <= Water;
                            player1_data.pkm_info.hp <= WATER_LHP;
                            player1_data.pkm_info.atk <= WATER_LATK;
                            player1_data.pkm_info.exp <= 0;
                        end
                    end
                    Electric: begin
                        if (ELECTRIC_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - ELECTRIC_BP;
                            player1_data.pkm_info.stage <= Lowest;
                            player1_data.pkm_info.pkm_type <= Electric;
                            player1_data.pkm_info.hp <= ELECTRIC_LHP;
                            player1_data.pkm_info.atk <= ELECTRIC_LATK;
                            player1_data.pkm_info.exp <= 0;
                        end
                    end
                    Normal: begin
                        if (NORMAL_BP > player1_data.bag_info.money) begin    // No money
                        end
                        else if (player1_data.pkm_info.pkm_type != No_type || player1_data.pkm_info.stage != No_stage) begin    // Have pkm
                        end
                        else begin
                            player1_data.bag_info.money <= player1_data.bag_info.money - NORMAL_BP;
                            player1_data.pkm_info.stage <= Lowest;
                            player1_data.pkm_info.pkm_type <= Normal;
                            player1_data.pkm_info.hp <= NORMAL_HP;
                            player1_data.pkm_info.atk <= NORMAL_ATK;
                            player1_data.pkm_info.exp <= 0;
                        end
                    end
                endcase
            end
        end
        else if (current_state == ACT_SELL) begin
            if (item_r != No_item) begin            // Sell item
                case (item_r)
                    Berry: begin
                        if (player1_data.bag_info.berry_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.berry_num <= player1_data.bag_info.berry_num - 1;
                            player1_data.bag_info.money <= player1_data.bag_info.money + BERRY_SP;
                        end
                    end
                    Medicine: begin
                        if (player1_data.bag_info.medicine_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.medicine_num <= player1_data.bag_info.medicine_num - 1;
                            player1_data.bag_info.money <= player1_data.bag_info.money + MEDICINE_SP;
                        end
                    end
                    Candy: begin
                        if (player1_data.bag_info.candy_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.candy_num <= player1_data.bag_info.candy_num - 1;
                            player1_data.bag_info.money <= player1_data.bag_info.money + CANDY_SP;
                        end
                    end
                    Bracer: begin
                        if (player1_data.bag_info.bracer_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.bracer_num <= player1_data.bag_info.bracer_num - 1;
                            player1_data.bag_info.money <= player1_data.bag_info.money + BRACER_SP;
                        end
                    end
                    Water_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == F_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.bag_info.money <= player1_data.bag_info.money + STONE_SP;
                        end
                    end
                    Fire_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.bag_info.money <= player1_data.bag_info.money + STONE_SP;
                        end
                    end
                    Thunder_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == F_stone) begin
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.bag_info.money <= player1_data.bag_info.money + STONE_SP;
                        end
                    end
                endcase
            end
            else begin       // Sell pkm
                if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
                end
                else begin
                    case (player1_data.pkm_info.pkm_type)
                        Grass: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                if (player1_data.pkm_info.stage == Middle) begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + GRASS_MSP;
                                end
                                else begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + GRASS_HSP;
                                end
                                
                                player1_data.pkm_info.stage <= No_stage;
                                player1_data.pkm_info.pkm_type <= No_type;
                                player1_data.pkm_info.hp <= 0;
                                player1_data.pkm_info.atk <= 0;
                                player1_data.pkm_info.exp <= 0;
                            end
                        end
                        Fire: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                if (player1_data.pkm_info.stage == Middle) begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + FIRE_MSP;
                                end
                                else begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + FIRE_HSP;
                                end
                                
                                player1_data.pkm_info.stage <= No_stage;
                                player1_data.pkm_info.pkm_type <= No_type;
                                player1_data.pkm_info.hp <= 0;
                                player1_data.pkm_info.atk <= 0;
                                player1_data.pkm_info.exp <= 0;
                            end
                        end
                        Water: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                if (player1_data.pkm_info.stage == Middle) begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + WATER_MSP;
                                end
                                else begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + WATER_HSP;
                                end
                                
                                player1_data.pkm_info.stage <= No_stage;
                                player1_data.pkm_info.pkm_type <= No_type;
                                player1_data.pkm_info.hp <= 0;
                                player1_data.pkm_info.atk <= 0;
                                player1_data.pkm_info.exp <= 0;
                            end
                        end
                        Electric: begin
                            if (player1_data.pkm_info.stage == Lowest) begin    // pkm lowest
                            end
                            else begin
                                if (player1_data.pkm_info.stage == Middle) begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + ELECTRIC_MSP;
                                end
                                else begin
                                    player1_data.bag_info.money <= player1_data.bag_info.money + ELECTRIC_HSP;
                                end
                                
                                player1_data.pkm_info.stage <= No_stage;
                                player1_data.pkm_info.pkm_type <= No_type;
                                player1_data.pkm_info.hp <= 0;
                                player1_data.pkm_info.atk <= 0;
                                player1_data.pkm_info.exp <= 0;
                            end
                        end
                        Normal: begin
                        end
                    endcase
                end
            end
        end
        else if (current_state == ACT_CHECK) begin
        end
        else if (current_state == ACT_DEP) begin
            player1_data.bag_info.money <= player1_data.bag_info.money + amnt_r;
        end
        else if (current_state == ACT_USE) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else begin
                case (item_r)
                    Berry: begin
                        if (player1_data.bag_info.berry_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.berry_num <= player1_data.bag_info.berry_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd96) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd128;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd160) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd192;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd222) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd254;
                                            end
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd87) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd119;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd145) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd177;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd193) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd225;
                                            end
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd93) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd125;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd155) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd187;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd213) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd245;
                                            end
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.hp < 'd90) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd122;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.hp < 'd150) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd182;
                                            end
                                        end
                                        Highest: begin
                                            if (player1_data.pkm_info.hp < 'd203) begin
                                                player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                            end
                                            else begin
                                                player1_data.pkm_info.hp <= 'd235;
                                            end
                                        end
                                    endcase
                                end
                                Normal: begin
                                    if (player1_data.pkm_info.hp < 'd92) begin
                                        player1_data.pkm_info.hp <= player1_data.pkm_info.hp + 'd32;
                                    end
                                    else begin
                                        player1_data.pkm_info.hp <= 'd124;
                                    end
                                end
                            endcase
                        end
                    end
                    Medicine: begin
                        if (player1_data.bag_info.medicine_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.medicine_num <= player1_data.bag_info.medicine_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            player1_data.pkm_info.hp <= 'd128;
                                        end
                                        Middle: begin
                                            player1_data.pkm_info.hp <= 'd192;
                                        end
                                        Highest: begin
                                            player1_data.pkm_info.hp <= 'd254;
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            player1_data.pkm_info.hp <= 'd119;
                                        end
                                        Middle: begin
                                            player1_data.pkm_info.hp <= 'd177;
                                        end
                                        Highest: begin
                                            player1_data.pkm_info.hp <= 'd225;
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            player1_data.pkm_info.hp <= 'd125;
                                        end
                                        Middle: begin
                                            player1_data.pkm_info.hp <= 'd187;
                                        end
                                        Highest: begin
                                            player1_data.pkm_info.hp <= 'd245;
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            player1_data.pkm_info.hp <= 'd122;
                                        end
                                        Middle: begin
                                            player1_data.pkm_info.hp <= 'd182;
                                        end
                                        Highest: begin
                                            player1_data.pkm_info.hp <= 'd235;
                                        end
                                    endcase
                                end
                                Normal: begin
                                    player1_data.pkm_info.hp <= 'd124;
                                end
                            endcase
                        end
                    end
                    Candy: begin
                        if (player1_data.bag_info.candy_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.candy_num <= player1_data.bag_info.candy_num - 1;

                            case (player1_data.pkm_info.pkm_type)
                                Grass: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd17) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Middle;
                                                player1_data.pkm_info.atk <= 'd94;
                                                player1_data.pkm_info.hp <= 'd192;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd48) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Highest;
                                                player1_data.pkm_info.atk <= 'd123;
                                                player1_data.pkm_info.hp <= 'd254;
                                            end
                                        end
                                    endcase
                                end
                                Fire: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd15) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Middle;
                                                player1_data.pkm_info.atk <= 'd96;
                                                player1_data.pkm_info.hp <= 'd177;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd44) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Highest;
                                                player1_data.pkm_info.atk <= 'd127;
                                                player1_data.pkm_info.hp <= 'd225;
                                            end
                                        end
                                    endcase
                                end
                                Water: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd13) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Middle;
                                                player1_data.pkm_info.atk <= 'd89;
                                                player1_data.pkm_info.hp <= 'd187;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd40) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Highest;
                                                player1_data.pkm_info.atk <= 'd113;
                                                player1_data.pkm_info.hp <= 'd245;
                                            end
                                        end
                                    endcase
                                end
                                Electric: begin
                                    case (player1_data.pkm_info.stage)
                                        Lowest: begin
                                            if (player1_data.pkm_info.exp < 'd11) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Middle;
                                                player1_data.pkm_info.atk <= 'd97;
                                                player1_data.pkm_info.hp <= 'd182;
                                            end
                                        end
                                        Middle: begin
                                            if (player1_data.pkm_info.exp < 'd36) begin
                                                player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                            end
                                            else begin
                                                player1_data.pkm_info.exp <= 'd0;
                                                player1_data.pkm_info.stage <= Highest;
                                                player1_data.pkm_info.atk <= 'd124;
                                                player1_data.pkm_info.hp <= 'd235;
                                            end
                                        end
                                    endcase
                                end
                                Normal: begin
                                    if (player1_data.pkm_info.exp < 'd14) begin
                                        player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd15;
                                    end
                                    else begin
                                        player1_data.pkm_info.exp <= 'd29;
                                    end
                                end
                            endcase
                        end
                    end
                    Bracer: begin
                        if (player1_data.bag_info.bracer_num == 0) begin
                        end
                        else begin
                            player1_data.bag_info.bracer_num <= player1_data.bag_info.bracer_num - 1;

                            if (use_bracer == 0) begin
                                player1_data.pkm_info.atk <= player1_data.pkm_info.atk + 'd32;
                            end
                        end
                    end
                    Water_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == F_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            player1_data.bag_info.stone <= No_stone;
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.pkm_info.stage <= Highest;
                            player1_data.pkm_info.pkm_type <= Water;
                            player1_data.pkm_info.hp <= 'd245;
                            player1_data.pkm_info.atk <= 'd113;
                            player1_data.pkm_info.exp <= 'd0;
                        end
                    end
                    Fire_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == T_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            player1_data.bag_info.stone <= No_stone;
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.pkm_info.stage <= Highest;
                            player1_data.pkm_info.pkm_type <= Fire;
                            player1_data.pkm_info.hp <= 'd225;
                            player1_data.pkm_info.atk <= 'd127;
                            player1_data.pkm_info.exp <= 'd0;
                        end
                    end
                    Thunder_stone: begin
                        if (player1_data.bag_info.stone == No_stone || player1_data.bag_info.stone == W_stone || player1_data.bag_info.stone == F_stone) begin
                        end
                        else if (player1_data.pkm_info.exp != 'd29 || player1_data.pkm_info.pkm_type != Normal) begin
                            player1_data.bag_info.stone <= No_stone;
                        end
                        else begin
                            player1_data.bag_info.stone <= No_stone;
                            player1_data.pkm_info.stage <= Highest;
                            player1_data.pkm_info.pkm_type <= Electric;
                            player1_data.pkm_info.hp <= 'd235;
                            player1_data.pkm_info.atk <= 'd124;
                            player1_data.pkm_info.exp <= 'd0;
                        end
                    end
                endcase
            end
        end
        else if (current_state == ACT_ATTACK) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player2_data.pkm_info.pkm_type == No_type || player2_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player1_data.pkm_info.hp == 0) begin
            end
            else if (player2_data.pkm_info.hp == 0) begin
            end
            else begin
                if (use_bracer) begin
                    player1_data.pkm_info.atk <= player1_data.pkm_info.atk - 'd32;
                end

                // player1 exp
                case (player1_data.pkm_info.pkm_type)
                    Grass: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd16) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd94;
                                            player1_data.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd47) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd123;
                                            player1_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd8) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd94;
                                            player1_data.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd123;
                                            player1_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        player1_data.pkm_info.exp <= 'd0;
                                        player1_data.pkm_info.stage <= Middle;
                                        player1_data.pkm_info.atk <= 'd94;
                                        player1_data.pkm_info.hp <= 'd192;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd123;
                                            player1_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Fire: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd14) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd96;
                                            player1_data.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd43) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd127;
                                            player1_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd6) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd96;
                                            player1_data.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd127;
                                            player1_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        player1_data.pkm_info.exp <= 'd0;
                                        player1_data.pkm_info.stage <= Middle;
                                        player1_data.pkm_info.atk <= 'd96;
                                        player1_data.pkm_info.hp <= 'd177;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd127;
                                            player1_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Water: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd12) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd89;
                                            player1_data.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd39) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd113;
                                            player1_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd4) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd89;
                                            player1_data.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd31) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd113;
                                            player1_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        player1_data.pkm_info.exp <= 'd0;
                                        player1_data.pkm_info.stage <= Middle;
                                        player1_data.pkm_info.atk <= 'd89;
                                        player1_data.pkm_info.hp <= 'd187;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd23) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd113;
                                            player1_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Electric: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd10) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd97;
                                            player1_data.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd35) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd124;
                                            player1_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player1_data.pkm_info.exp < 'd2) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Middle;
                                            player1_data.pkm_info.atk <= 'd97;
                                            player1_data.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd27) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd124;
                                            player1_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player1_data.pkm_info.stage)
                                    Lowest: begin
                                        player1_data.pkm_info.exp <= 'd0;
                                        player1_data.pkm_info.stage <= Middle;
                                        player1_data.pkm_info.atk <= 'd97;
                                        player1_data.pkm_info.hp <= 'd182;
                                    end
                                    Middle: begin
                                        if (player1_data.pkm_info.exp < 'd19) begin
                                            player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd32;
                                        end
                                        else begin
                                            player1_data.pkm_info.exp <= 'd0;
                                            player1_data.pkm_info.stage <= Highest;
                                            player1_data.pkm_info.atk <= 'd124;
                                            player1_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Normal: begin
                        case (player2_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                if (player1_data.pkm_info.exp < 'd13) begin
                                    player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player1_data.pkm_info.exp <= 'd29;
                                end
                            end
                            Middle: begin
                                if (player1_data.pkm_info.exp < 'd5) begin
                                    player1_data.pkm_info.exp <= player1_data.pkm_info.exp + 'd24;
                                end
                                else begin
                                    player1_data.pkm_info.exp <= 'd29;
                                end
                            end
                            Highest: begin
                                player1_data.pkm_info.exp <= 'd29;
                            end
                        endcase
                    end
                endcase
            end
        end
    end
end

// Player2 data
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        player2_data <= 0;
    end
    else begin
        if (current_state == GET_DATA2) begin
            player2_data.pkm_info.stage <= inf.C_data_r[39:36];
            player2_data.pkm_info.pkm_type <= inf.C_data_r[35:32];
            player2_data.pkm_info.hp <= inf.C_data_r[47:40];
            player2_data.pkm_info.atk <= inf.C_data_r[55:48];
            player2_data.pkm_info.exp <= inf.C_data_r[63:56];
            player2_data.bag_info.berry_num <= inf.C_data_r[7:4];
            player2_data.bag_info.medicine_num <= inf.C_data_r[3:0];
            player2_data.bag_info.candy_num <= inf.C_data_r[15:12];
            player2_data.bag_info.bracer_num <= inf.C_data_r[11:8];
            player2_data.bag_info.stone <= inf.C_data_r[23:22];
            player2_data.bag_info.money[13:8] <= inf.C_data_r[21:16];
            player2_data.bag_info.money[7:0] <= inf.C_data_r[31:24];
        end
        else if (current_state == ACT_ATTACK) begin
            if (player1_data.pkm_info.pkm_type == No_type || player1_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player2_data.pkm_info.pkm_type == No_type || player2_data.pkm_info.stage == No_stage) begin    // No pkm
            end
            else if (player1_data.pkm_info.hp == 0) begin
            end
            else if (player2_data.pkm_info.hp == 0) begin
            end
            else begin
                // player2 hp
                case (player1_data.pkm_info.pkm_type)
                    Grass: begin
                        case (player2_data.pkm_info.pkm_type)
                            Grass: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Fire: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Water: begin
                                if (player2_data.pkm_info.hp > 2*player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - 2*player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Electric: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Normal: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                        endcase
                    end
                    Fire: begin
                        case (player2_data.pkm_info.pkm_type)
                            Grass: begin
                                if (player2_data.pkm_info.hp > 2*player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - 2*player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Fire: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Water: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Electric: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Normal: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                        endcase
                    end
                    Water: begin
                        case (player2_data.pkm_info.pkm_type)
                            Grass: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Fire: begin
                                if (player2_data.pkm_info.hp > 2*player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - 2*player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Water: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Electric: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Normal: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                        endcase
                    end
                    Electric: begin
                        case (player2_data.pkm_info.pkm_type)
                            Grass: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Fire: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Water: begin
                                if (player2_data.pkm_info.hp > 2*player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - 2*player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Electric: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk / 2) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk / 2;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                            Normal: begin
                                if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                                    player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                                end
                                else begin
                                    player2_data.pkm_info.hp <= 'd0;
                                end
                            end
                        endcase
                    end
                    Normal: begin
                        if (player2_data.pkm_info.hp > player1_data.pkm_info.atk) begin
                            player2_data.pkm_info.hp <= player2_data.pkm_info.hp - player1_data.pkm_info.atk;
                        end
                        else begin
                            player2_data.pkm_info.hp <= 'd0;
                        end
                    end
                endcase

                // player2 exp
                case (player2_data.pkm_info.pkm_type)
                    Grass: begin
                        case (player1_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd24) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd94;
                                            player2_data.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd55) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd123;
                                            player2_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd20) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd94;
                                            player2_data.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd51) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd123;
                                            player2_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd16) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd94;
                                            player2_data.pkm_info.hp <= 'd192;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd47) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd123;
                                            player2_data.pkm_info.hp <= 'd254;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Fire: begin
                        case (player1_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd22) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd96;
                                            player2_data.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd51) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd127;
                                            player2_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd18) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd96;
                                            player2_data.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd47) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd127;
                                            player2_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd14) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd96;
                                            player2_data.pkm_info.hp <= 'd177;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd43) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd127;
                                            player2_data.pkm_info.hp <= 'd225;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Water: begin
                        case (player1_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd20) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd89;
                                            player2_data.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd47) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd113;
                                            player2_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd16) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd89;
                                            player2_data.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd43) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd113;
                                            player2_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd12) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd89;
                                            player2_data.pkm_info.hp <= 'd187;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd39) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd113;
                                            player2_data.pkm_info.hp <= 'd245;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Electric: begin
                        case (player1_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd18) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd97;
                                            player2_data.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd43) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd124;
                                            player2_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Middle: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd14) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd97;
                                            player2_data.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd39) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd124;
                                            player2_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                            Highest: begin
                                case (player2_data.pkm_info.stage)
                                    Lowest: begin
                                        if (player2_data.pkm_info.exp < 'd10) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Middle;
                                            player2_data.pkm_info.atk <= 'd97;
                                            player2_data.pkm_info.hp <= 'd182;
                                        end
                                    end
                                    Middle: begin
                                        if (player2_data.pkm_info.exp < 'd35) begin
                                            player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                        end
                                        else begin
                                            player2_data.pkm_info.exp <= 'd0;
                                            player2_data.pkm_info.stage <= Highest;
                                            player2_data.pkm_info.atk <= 'd124;
                                            player2_data.pkm_info.hp <= 'd235;
                                        end
                                    end
                                endcase
                            end
                        endcase
                    end
                    Normal: begin
                        case (player1_data.pkm_info.stage)       // Opponent's stage
                            Lowest: begin
                                if (player2_data.pkm_info.exp < 'd21) begin
                                    player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd8;
                                end
                                else begin
                                    player2_data.pkm_info.exp <= 'd29;
                                end
                            end
                            Middle: begin
                                if (player2_data.pkm_info.exp < 'd17) begin
                                    player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd12;
                                end
                                else begin
                                    player2_data.pkm_info.exp <= 'd29;
                                end
                            end
                            Highest: begin
                                if (player2_data.pkm_info.exp < 'd13) begin
                                    player2_data.pkm_info.exp <= player2_data.pkm_info.exp + 'd16;
                                end
                                else begin
                                    player2_data.pkm_info.exp <= 'd29;
                                end
                            end
                        endcase
                    end
                endcase
            end
        end
    end
end

// C_in_valid & C_r_wb & C_addr & C_data_w
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.C_in_valid <= 0;
        inf.C_r_wb <= 0;
        inf.C_addr <= 0;
        inf.C_data_w <= 0;
    end
    else begin
        if (current_state == GET_ID1) begin
            inf.C_in_valid <= 1'b1;
            inf.C_r_wb <= 1;
            inf.C_addr <= id1_r;
        end
        else if (current_state == GET_DATA1 || current_state == PUT_DATA1_2 || current_state == PUT_DATA2_2) begin
            inf.C_in_valid <= 1'b0;
        end
        else if (current_state == GET_ID2) begin
            inf.C_in_valid <= 1'b1;
            inf.C_r_wb <= 1;
            inf.C_addr <= id2_r;
        end
        else if (current_state == GET_DATA2) begin
            inf.C_in_valid <= 1'b0;
        end
        else if (current_state == PUT_DATA1_1) begin
            inf.C_in_valid <= 1'b1;
            inf.C_r_wb <= 0;
            inf.C_addr <= id1_r;

            inf.C_data_w[39:36] <= player1_data.pkm_info.stage;
            inf.C_data_w[35:32] <= player1_data.pkm_info.pkm_type;
            inf.C_data_w[47:40] <= player1_data.pkm_info.hp;
            if (use_bracer) begin
                inf.C_data_w[55:48] <= player1_data.pkm_info.atk - 'd32;
            end
            else begin
                inf.C_data_w[55:48] <= player1_data.pkm_info.atk;
            end
            
            inf.C_data_w[63:56] <= player1_data.pkm_info.exp;
            inf.C_data_w[7:4] <= player1_data.bag_info.berry_num;
            inf.C_data_w[3:0] <= player1_data.bag_info.medicine_num;
            inf.C_data_w[15:12] <= player1_data.bag_info.candy_num;
            inf.C_data_w[11:8] <= player1_data.bag_info.bracer_num;
            inf.C_data_w[23:22] <= player1_data.bag_info.stone;
            inf.C_data_w[21:16] <= player1_data.bag_info.money[13:8];
            inf.C_data_w[31:24] <= player1_data.bag_info.money[7:0];
        end
        else if (current_state == PUT_DATA2_1) begin
            inf.C_in_valid <= 1'b1;
            inf.C_r_wb <= 0;
            inf.C_addr <= id2_r;

            inf.C_data_w[39:36] <= player2_data.pkm_info.stage;
            inf.C_data_w[35:32] <= player2_data.pkm_info.pkm_type;
            inf.C_data_w[47:40] <= player2_data.pkm_info.hp;
            inf.C_data_w[55:48] <= player2_data.pkm_info.atk;
            inf.C_data_w[63:56] <= player2_data.pkm_info.exp;
            inf.C_data_w[7:4] <= player2_data.bag_info.berry_num;
            inf.C_data_w[3:0] <= player2_data.bag_info.medicine_num;
            inf.C_data_w[15:12] <= player2_data.bag_info.candy_num;
            inf.C_data_w[11:8] <= player2_data.bag_info.bracer_num;
            inf.C_data_w[23:22] <= player2_data.bag_info.stone;
            inf.C_data_w[21:16] <= player2_data.bag_info.money[13:8];
            inf.C_data_w[31:24] <= player2_data.bag_info.money[7:0];
        end
        else if (current_state == IDLE) begin
            inf.C_in_valid <= 0;
            inf.C_r_wb <= 0;
            inf.C_addr <= 0;
            inf.C_data_w <= 0;
        end
        else begin
            inf.C_in_valid <= 0;
            inf.C_r_wb <= 0;
            inf.C_addr <= 0;
            inf.C_data_w <= 0;
        end
    end
end

// Output
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) begin
        inf.out_valid <= 0;
        inf.err_msg <= 0;
        inf.complete <= 0;
        inf.out_info <= 0;
    end
    else begin
        if (current_state == FINISH) begin
            inf.out_valid <= 1;
            inf.err_msg <= err_msg_r;
            inf.complete <= complete_r;
            inf.out_info <= out_r;
            if (do_attack) begin
                if (out_r == 1) begin
                    inf.out_info <= {player1_data.pkm_info, player2_data.pkm_info};
                end
                else begin
                    inf.out_info <= 0;
                end
            end
        end
        else if (current_state == IDLE) begin
            inf.out_valid <= 0;
            inf.err_msg <= 0;
            inf.complete <= 0;
            inf.out_info <= 0;
        end
    end
end

endmodule