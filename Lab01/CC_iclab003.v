module CC(
	in_n0,
	in_n1, 
	in_n2, 
	in_n3, 
    in_n4, 
	in_n5, 
	opt,
    equ,
	out_n
);
input [3:0]in_n0;
input [3:0]in_n1;
input [3:0]in_n2;
input [3:0]in_n3;
input [3:0]in_n4;
input [3:0]in_n5;
input [2:0] opt;
input equ;
output [9:0] out_n;
//==================================================================
// reg & wire
//==================================================================

reg signed [4:0] n [0:5];
reg signed [4:0] n1 [0:5];
reg signed [4:0] n2 [0:5];
reg signed [4:0] n3 [0:5];
reg [4:0] temp;
integer  i, j;
reg signed [10:0] cal;
reg [9:0] out;

always @(*) begin
	/*
	if(opt[0]) begin
		n[0] = {in_n0[3], in_n0};
		n[1] = {in_n1[3], in_n1};
		n[2] = {in_n2[3], in_n2};
		n[3] = {in_n3[3], in_n3};
		n[4] = {in_n4[3], in_n4};
		n[5] = {in_n5[3], in_n5};
	end
	else begin
		n[0] = {1'b0, in_n0};
		n[1] = {1'b0, in_n1};
		n[2] = {1'b0, in_n2};
		n[3] = {1'b0, in_n3};
		n[4] = {1'b0, in_n4};
		n[5] = {1'b0, in_n5};
	end
	*/
	
	n[0] = (opt[0])? {in_n0[3], in_n0}:{1'b0, in_n0};
	n[1] = (opt[0])? {in_n1[3], in_n1}:{1'b0, in_n1};
	n[2] = (opt[0])? {in_n2[3], in_n2}:{1'b0, in_n2};
	n[3] = (opt[0])? {in_n3[3], in_n3}:{1'b0, in_n3};
	n[4] = (opt[0])? {in_n4[3], in_n4}:{1'b0, in_n4};
	n[5] = (opt[0])? {in_n5[3], in_n5}:{1'b0, in_n5};
	
	for(i = 0; i < 6; i = i + 1) begin
		n1[i] = n[i];
	end
	
	for(i = 0; i < 5; i = i + 1) begin
		for(j = 0; j < 5; j = j + 1) begin
			if(n1[j] < n1[j+1]) begin
				temp = n1[j];
				n1[j] = n1[j+1];
				n1[j+1] = temp;
			end
		end
	end
	
	if(!opt[1]) begin
		temp = n1[5];
		n1[5] = n1[0];
		n1[0] = temp;
		
		temp = n1[4];
		n1[4] = n1[1];
		n1[1] = temp;
		
		temp = n1[3];
		n1[3] = n1[2];
		n1[2] = temp;
	end
	
	/*
	if(opt[1]) begin
		for(i = 0; i < 5; i = i + 1) begin
			for(j = 0; j < 5; j = j + 1) begin
				if(n1[j] < n1[j+1]) begin
					temp = n1[j];
					n1[j] = n1[j+1];
					n1[j+1] = temp;
				end
			end
		end
	end
	else begin
		for(i = 0; i < 5; i = i + 1) begin
			for(j = 0; j < 5; j = j + 1) begin
				if(n1[j] > n1[j+1]) begin
					temp = n1[j];
					n1[j] = n1[j+1];
					n1[j+1] = temp;
				end
			end
		end
	end
	
	*/
	
	for(i = 0; i < 6; i = i + 1) begin
		n2[i] = n1[i];
	end
	
	if(opt[2]) begin
		n2[0] = (n2[0]*2 + n2[0]) / 3;
		n2[1] = (n2[0]*2 + n2[1]) / 3;
		n2[2] = (n2[1]*2 + n2[2]) / 3;
		n2[3] = (n2[2]*2 + n2[3]) / 3;
		n2[4] = (n2[3]*2 + n2[4]) / 3;
		n2[5] = (n2[4]*2 + n2[5]) / 3;
	end
	else begin
		n2[1] = n2[1] - n2[0];
		n2[2] = n2[2] - n2[0];
		n2[3] = n2[3] - n2[0];
		n2[4] = n2[4] - n2[0];
		n2[5] = n2[5] - n2[0];
		n2[0] = 0;
	end
	
	for(i = 0; i < 6; i = i + 1) begin
		n3[i] = n2[i];
	end
	
	cal = (n3[5] * n3[1]) - (n3[5] * n3[0]);
	
	if(equ)
		if(cal[10])
			out = ~cal + 1;
		else
			out = cal;
	else
		out = ((n3[3] + n3[4]*4) * n3[5]) / 3;
		
end

assign out_n = out;

endmodule
