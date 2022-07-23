
`ifdef RTL
    `define CYCLE_TIME 15.0
`endif
`ifdef GATE
    `define CYCLE_TIME 15.0
`endif

module PATTERN(
    // Output signals
	clk,
    rst_n,
	in_valid1,
	in_valid2,
	in,
	in_data,
    // Input signals
    out_valid1,
	out_valid2,
    out,
	out_data
);

// =================================================
// Input & Output Declaration
// =================================================

output reg clk, rst_n, in_valid1, in_valid2;
output reg [1:0] in;
output reg [8:0] in_data;
input out_valid1, out_valid2;
input [2:0] out;
input [8:0] out_data;

// =================================================
// Parameters & Integer Declaration
// =================================================
integer input_file, output_file;
integer total_cycles, cycles;
integer PATNUM, patcount;
integer passwdcount;
integer hostage_num, trap_num;
integer gap;
integer max, min, half;

integer a, b, c, d, e, f, g;
integer i, j;
integer golden_step;

// =================================================
// Wire & Reg Declaration
// =================================================
reg [1:0] maze_data [0:16][0:16];
reg [8:0] passwd_d;
reg signed [8:0] passwd_data [0:3];
reg signed [7:0] passwd_data_even [0:3];
reg signed [8:0] passwd_data_odd [0:3];
reg [3:0] ex3_reg1, ex3_reg2;

reg [4:0] current_row, current_col;
reg [8:0] temp;
reg stall;

reg signed [8:0] golden_result [0:3];

always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial clk = 0;

initial begin
	rst_n = 1;
	in_valid1 = 1'b0;
	in_valid2 = 1'b0;
	in = 'bx;
	in_data = 'bx;
	
	force clk = 0;
	reset_task;

	input_file = $fopen("../00_TESTBED/input.txt", "r");
	@(negedge clk);

	PATNUM = 500;
	total_cycles = 0;
	
	for (patcount = 0; patcount < PATNUM; patcount = patcount + 1) begin
		stall = 0;
		cycles = 0;
		passwdcount = 0;
		current_row = 0;
		current_col = 0;

		input_data1;
		//Create passwd
		case (hostage_num)
			0: begin
				passwd_data[0] = 0;
			end
			1: begin
				for(i = 0; i < 1; i = i + 1) begin
					passwd_data[i] = $urandom_range(0, 511);
				end
			end
			2: begin
				for(i = 0; i < 2; i = i + 1) begin
					passwd_d[8] = $urandom_range(0, 1);
					passwd_d[7:4] = $urandom_range(3, 12);
					passwd_d[3:0] = $urandom_range(3, 12);
					passwd_data[i] = passwd_d;
				end
			end
			3: begin
				for(i = 0; i < 3; i = i + 1) begin
					passwd_data[i] = $urandom_range(0, 511);
				end
			end
			4: begin
				for(i = 0; i < 4; i = i + 1) begin
					passwd_d[8] = $urandom_range(0, 1);
					passwd_d[7:4] = $urandom_range(3, 12);
					passwd_d[3:0] = $urandom_range(3, 12);
					passwd_data[i] = passwd_d;
				end
			end
		endcase
		

		for(i = 0; i < hostage_num; i = i + 1) begin
			if (in_valid1 === 1) begin
				$display ("SPEC 9 IS FAIL!");

				@(negedge clk);
				$finish;
			end
			start_out_valid2;
			down_out_valid2;
			input_data2;

			if (in_valid1 === 1 && (current_row !== 16 || current_col !== 16)) begin
				$display ("SPEC 9 IS FAIL!");

				@(negedge clk);
				$finish;
			end
		end

		start_out_valid2;
		check_ans;
		total_cycles = total_cycles + cycles;

		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;

end

task reset_task; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid1 !== 0) || (out_valid2 !== 0) || (out !== 0) || (out_data !== 0)) begin
		$display ("SPEC 3 IS FAIL!");

		#(100);
	    $finish;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task out_reset_task; begin
	if((out_valid1 !== 0) || (out_valid2 !== 0) || (out !== 0) || (out_data !== 0)) begin
		$display ("SPEC 4 IS FAIL!");

		@(negedge clk);
	    $finish;
	end
end endtask

task input_data1; begin
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	in_valid1 = 1'b1;
	for(i = 0; i < 17; i = i + 1) begin
		for (j = 0; j < 17; j = j + 1) begin
			a = $fscanf(input_file, "%d", maze_data[i][j]);
		end
	end

	hostage_num = 0;
	trap_num = 0;
	for (i = 0; i < 17; i = i + 1) begin
		for (j = 0; j < 17; j = j + 1) begin
			in = maze_data[i][j];
			if(maze_data[i][j] == 3) begin
				hostage_num = hostage_num + 1;
			end
			if(maze_data[i][j] == 2) begin
				trap_num = trap_num + 1;
			end
			if((out_valid1 !== 0) || (out_valid2 !== 0)) begin
				$display ("SPEC 5 IS FAIL!");

				@(negedge clk);
				$finish;
			end
			@(negedge clk);
		end
	end

	in_valid1 = 1'b0;
	in = 'bx;

end endtask

task input_data2; begin
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);

	in_valid2 = 1'b1;
	in_data = passwd_data[passwdcount];
	passwdcount = passwdcount + 1;

	if (out_valid2 !== 0 || out_valid2 !== 0) begin
		$display ("SPEC 5 IS FAIL!");

		@(negedge clk);
		$finish;
	end

	@(negedge clk);
	in_valid2 = 1'b0;
	in_data = 'bx;
	
end endtask

task start_out_valid2; begin
	while (out_valid2 !== 1) begin
		cycles = cycles + 1;
		if (cycles == 3000) begin						//The execution latency are over 3000 cycles
			$display ("SPEC 6 IS FAIL!");

			@(negedge clk);
			$finish;
		end
		@(negedge clk);
	end

	while (out_valid2 === 1) begin
		//$display ("*******************start out_valid2********************");
		cycles = cycles + 1;
		if (cycles == 3000) begin						//The execution latency are over 3000 cycles
			$display ("SPEC 6 IS FAIL!");

			@(negedge clk);
			$finish;
		end

		if (out_valid1 == 1) begin						//out_valid1 == out_valid2 == 1
			$display ("SPEC 5 IS FAIL!");

			@(negedge clk);
			$finish;
		end

		if (maze_data[current_row][current_col] == 0) begin		//On The Wall
			$display ("SPEC 7 IS FAIL!");

			@(negedge clk);
			$finish;
		end

		if (out_data != 0) begin
			$display ("SPEC 7 IS FAIL!");

			@(negedge clk);
			$finish;
		end

		if (maze_data[current_row][current_col] == 2) begin
			if (out == 3'd4) begin
				stall = 1;
			end
			if (stall == 0) begin					//OUT need to be STALL
				$display ("SPEC 7 IS FAIL!");

				@(negedge clk);
				$finish;
			end
		end
		else begin
			stall = 0;
		end

		case (out)
			3'd0: begin
				current_col = current_col + 1;
				if (current_col == 17) begin		//Out Of Bound
					$display ("SPEC 7 IS FAIL!");
					@(negedge clk);
					$finish;
				end
			end
			3'd1: begin
				current_row = current_row + 1;
				if (current_row == 17) begin		//Out Of Bound
					$display ("SPEC 7 IS FAIL!");

					@(negedge clk);
					$finish;
				end
			end
			3'd2: begin
				if (current_col == 0) begin			//Out Of Bound
					$display ("SPEC 7 IS FAIL!");

					@(negedge clk);
					$finish;
				end
				current_col = current_col - 1;
			end
			3'd3: begin
				if (current_row == 0) begin			//Out Of Bound
					$display ("SPEC 7 IS FAIL!");

					@(negedge clk);
					$finish;
				end
				current_row = current_row - 1;
			end
			default: begin
				current_row = current_row;
				current_col = current_col;
			end
		endcase

		@(negedge clk);
	end

end endtask

task down_out_valid2; begin
	if (out !== 0) begin
		$display ("SPEC 4 IS FAIL!");
		
		@(negedge clk);
	    $finish;
	end

	if (!(maze_data[current_row][current_col] == 3 || (current_row == 16 && current_col == 16))) begin
		$display ("SPEC 8 IS FAIL!");
		
		@(negedge clk);
	    $finish;
	end

end endtask

task check_ans; begin
	//Sorting
	for (i = 0; i < hostage_num - 1; i = i + 1) begin
		for (j = i + 1; j < hostage_num; j = j + 1) begin
			if(passwd_data[i] < passwd_data[j]) begin
				temp = passwd_data[j];
				passwd_data[j] = passwd_data[i];
				passwd_data[i] = temp;
			end
		end
	end

	//Excess-3
	if (hostage_num == 4 || hostage_num == 2) begin				//even
		for (i = 0; i < hostage_num; i = i + 1) begin
			if (passwd_data[i][8] == 0) begin		//positive
				for (j = 0; j < 4; j = j + 1) begin
					ex3_reg1[j] = passwd_data[i][j];
					ex3_reg2[j] = passwd_data[i][j+4];
				end
				
				passwd_data_even[i] = (ex3_reg1-3) + ((ex3_reg2-3) * 10);
			end
			else begin							//negative
				for (j = 0; j < 4; j = j + 1) begin
					ex3_reg1[j] = passwd_data[i][j];
					ex3_reg2[j] = passwd_data[i][j+4];
				end
				passwd_data_even[i] = - (ex3_reg1-3) - ((ex3_reg2-3) * 10);
			end
		end
	end
	else if (hostage_num == 3 || hostage_num == 1) begin		//odd
		for (i = 0; i < hostage_num; i = i + 1) begin
			passwd_data_odd[i] = passwd_data[i];
		end
	end

	//Subtrsct half of range
	if (hostage_num == 3) begin
		max = -255;
		min = 255;
		for (i = 0; i < hostage_num; i = i + 1) begin
			if (max < passwd_data_odd[i]) begin
				max = passwd_data_odd[i];
			end
			if (min > passwd_data_odd[i]) begin
				min = passwd_data_odd[i];
			end
		end

		half = (max + min) / 2;
		for (i = 0; i < hostage_num; i = i + 1) begin
			passwd_data_odd[i] = passwd_data_odd[i] - half;
		end
	end
	if (hostage_num == 2 || hostage_num == 4) begin
		max = -255;
		min = 255;
		for (i = 0; i < hostage_num; i = i + 1) begin
			if (max < passwd_data_even[i]) begin
				max = passwd_data_even[i];
			end
			if (min > passwd_data_even[i]) begin
				min = passwd_data_even[i];
			end
		end

		half = (max + min) / 2;
		for (i = 0; i < hostage_num; i = i + 1) begin
			passwd_data_even[i] = passwd_data_even[i] - half;
		end
	end

	//Cumulation
	if (hostage_num == 0) begin
		golden_result[0] = 0;
	end
	if (hostage_num == 1) begin
		golden_result[0] = passwd_data_odd[0];
	end
	if (hostage_num == 2) begin
		golden_result[0] = passwd_data_even[0];
		golden_result[1] = passwd_data_even[1];
	end
	if (hostage_num == 3) begin
		golden_result[0] = passwd_data_odd[0];
		golden_result[1] = (golden_result[0]*2 + passwd_data_odd[1]) / 3;
		golden_result[2] = (golden_result[1]*2 + passwd_data_odd[2]) / 3;
	end
	if (hostage_num == 4) begin
		golden_result[0] = passwd_data_even[0];
		golden_result[1] = (golden_result[0]*2 + passwd_data_even[1]) / 3;
		golden_result[2] = (golden_result[1]*2 + passwd_data_even[2]) / 3;
		golden_result[3] = (golden_result[2]*2 + passwd_data_even[3]) / 3;
	end

	golden_step = 0;

	while (out_valid1 !== 1) begin
		cycles = cycles + 1;
		if(cycles == 3000) begin						//The execution latency are over 3000 cycles
			$display ("SPEC 6 IS FAIL!");

			@(negedge clk);
			$finish;
		end
		@(negedge clk);
	end

	while (out_valid1 == 1) begin
		if ( out_data !== golden_result[ golden_step ] ) begin
			$display ("SPEC 10 IS FAIL!");
			
			@(negedge clk);
			$finish;
		end
		if (out_valid2 == 1) begin						//out_valid1 == out_valid2 == 1
			$display ("SPEC 5 IS FAIL!");

			@(negedge clk);
			$finish;
		end
		
		golden_step=golden_step+1;
		if (hostage_num == 0) begin
			if(golden_step > 1) begin
				$display ("SPEC 9 IS FAIL!");
				
				@(negedge clk);
				$finish;
			end
		end
		else begin
			if(golden_step > hostage_num) begin
				$display ("SPEC 9 IS FAIL!");
				
				@(negedge clk);
				$finish;
			end
		end
		@(negedge clk);
	end
	if (out_data != 0) begin
		$display ("SPEC 11 IS FAIL!");
				
		@(negedge clk);
		$finish;
	end

	if (hostage_num == 0) begin
		if (golden_step > 1) begin
			$display ("SPEC 9 IS FAIL!");

			@(negedge clk);
			$finish;
		end
	end
	else if(golden_step !== hostage_num) begin
		$display ("SPEC 9 IS FAIL!");
		
		@(negedge clk);
		$finish;
	end
end endtask

task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						                 ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask

endmodule