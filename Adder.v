module halfAdder(sum, carry, in1, in2);
	input in1, in2;
	output sum, carry;
	xor x1(sum, in1, in2);
	and a1(carry, in1, in2);
endmodule

module oneBitFullAdder(sum, carry, in1, in2, cin);
	input in1, in2, cin;
	output sum, carry;
	wire s1, c1, c2;
	halfAdder ha1(s1, c1, in1, in2);
	halfAdder ha2(sum, c2, s1, cin);
	or o1(carry, c1, c2);
endmodule

module fourBitFullAdder(sum, carry, in1, in2, cin);
	input [3:0] in1, in2;
	input cin;
	output [3:0] sum;
	output carry;
	wire c0, c1, c2;
	oneBitFullAdder obfa1(sum[0], c0, in1[0], in2[0], cin);
	oneBitFullAdder obfa2(sum[1], c1, in1[1], in2[1], c0);
	oneBitFullAdder obfa3(sum[2], c2, in1[2], in2[2], c1);
	oneBitFullAdder obfa4(sum[3], carry, in1[3], in2[3], c2);
endmodule

module eightBitFullAdder(sum, carry, in1, in2, cin);
	input [7:0] in1, in2;
	input cin;
	output [7:0] sum;
	output carry;
	wire caux;
	fourBitFullAdder fbfa1(sum[3:0], caux, in1[3:0], in2[3:0], cin);
	fourBitFullAdder fbfa2(sum[7:4], carry, in1[7:4], in2[7:4], caux);
endmodule

module thirtytwoBitFullAdder(sum, carry, in1, in2, cin);
	input [31:0] in1, in2;
	input cin;
	output [31:0] sum;
	output carry;
	wire caux1, caux2, caux3;
	eightBitFullAdder ebfa1(sum[7:0], caux1, in1[7:0], in2[7:0], cin);
	eightBitFullAdder ebfa2(sum[15:8], caux2, in1[15:8], in2[15:8], caux1);
	eightBitFullAdder ebfa3(sum[23:16], caux3, in1[23:16], in2[23:16], caux2);
	eightBitFullAdder ebfa4(sum[31:24], carry, in1[31:24], in2[31:24], caux3);
endmodule
