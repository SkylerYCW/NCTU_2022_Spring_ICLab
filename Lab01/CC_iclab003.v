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
reg signed [4:0] temp;
reg signed [4:0] temp1;
reg signed [4:0] temp2;
reg signed [4:0] temp3;

integer  i, j;
reg signed [10:0] cal;
reg [9:0] out;

always @(*) begin
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
	
	n1[0] = n[0];
	n1[1] = n[1];
	n1[2] = n[2];
	n1[3] = n[3];
	n1[4] = n[4];
	n1[5] = n[5];
	
	for(i = 0; i < 3; i = i + 1) begin
		for(j = 0; j < 5; j = j + 2) begin
			if(n1[j] < n1[j+1]) begin
				temp = n1[j];
				n1[j] = n1[j+1];
				n1[j+1] = temp;
			end
		end
		for(j = 1; j < 5; j = j + 2) begin
			if(n1[j] < n1[j+1]) begin
				temp = n1[j];
				n1[j] = n1[j+1];
				n1[j+1] = temp;
			end
		end
	end
	
	if(!opt[1]) begin
		temp1 = n1[5];
		n1[5] = n1[0];
		n1[0] = temp1;
		
		temp2 = n1[4];
		n1[4] = n1[1];
		n1[1] = temp2;
		
		temp3 = n1[3];
		n1[3] = n1[2];
		n1[2] = temp3;
	end
	
	n2[0] = n1[0];
	n2[1] = n1[1];
	n2[2] = n1[2];
	n2[3] = n1[3];
	n2[4] = n1[4];
	n2[5] = n1[5];
	
	if(opt[2]) begin
		n2[0] = n2[0];
		n2[1] = (n2[0]*2 + n2[1]) / 3;
		n2[2] = (n2[1]*2 + n2[2]) / 3;
		n2[3] = (n2[2]*2 + n2[3]) / 3;
		n2[4] = (n2[3]*2 + n2[4]) / 3;
		n2[5] = (n2[4]*2 + n2[5]) / 3;
	end
	
	if(!opt[2]) begin
		n2[1] = n2[1] - n2[0];
		n2[2] = n2[2] - n2[0];
		n2[3] = n2[3] - n2[0];
		n2[4] = n2[4] - n2[0];
		n2[5] = n2[5] - n2[0];
		n2[0] = 0;
	end
	
	if(!equ) begin
		out = ((n2[3] + n2[4]*4) * n2[5]) / 3;
	end
	else begin
		cal = (n2[5] * n2[1]) - (n2[5] * n2[0]);
			
		if(cal < 0)
			out = ~cal + 1;
		else
			out = cal;
	end
end

assign out_n = out;

endmodule
