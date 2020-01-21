`timescale 1ns/1ps


module lab4_alu #(parameter WIDTH = 32)(in_A, in_B, in_func, out_result, out_overflow, out_zero, shamt, clk, rst_n);

input clk, rst_n;
input  [WIDTH-1:0] in_A, in_B;
input  [4:0] in_func, shamt;
output out_overflow;
output reg out_zero;
output reg [WIDTH-1:0]  out_result;

wire [WIDTH-1:0] result_barrel_shifter;
wire [WIDTH-1:0] result_addsub;
wire [WIDTH*2-1:0] result_muldiv;
wire [WIDTH-1:0] ssat_out, dsp_out;
wire t_ovf;

//HI LO NON ARCH REGS
reg [WIDTH*2-1:0] hilo;

muldiv mul_h(
	.in_A(in_A), .in_B(in_B), .check(in_func[1:0]), .out(result_muldiv));

cinadd add(
	.opA(in_A), .opB(in_B), .addsub(in_func[0]), .result(result_addsub), .overflow(t_ovf));

lab3_barrel_shifter shift(
	.bs_opsel(in_func[2:0]), .shift_amount(shamt), .data_in(in_B), .result(result_barrel_shifter)); 

vsat ssat(in_A, in_B[4:0]-5'h1, ssat_out);

dsp dspext(in_A, in_B, in_func[2:0], dsp_out);

always @(*) begin
	 casez(in_func)
	 	5'b00???: // shift
           out_result = result_barrel_shifter;
        5'b100??: // MUL or DIV or SMLAL
	   out_result = 0;
        5'b1011?: // ADD_SUB
	   out_result = result_addsub;      
		5'b11000: // AND 
           out_result = in_A & in_B; 
        5'b11001: // OR 
           out_result = in_A | in_B;
        5'b11010: // NOR
           out_result = ~(in_A | in_B);
        5'b11011: // XOR
           out_result = in_A ^ in_B; 
        5'b11111: //slt
        	out_result = {31'b0, t_ovf};
        5'b10100: out_result = hilo[WIDTH-1:0];
        5'b10101: out_result = hilo[WIDTH*2-1:WIDTH];
        5'b11100: out_result = ssat_out;//SSAT=slti
        5'b01???: out_result = dsp_out;//dsp submodule
	default:  
	   out_result = {WIDTH{1'bz}}; 
	endcase
	out_zero = ~| out_result;
end
assign out_overflow = t_ovf & (in_func[4:1] == 4'b1011);

always @(posedge clk) begin
	if(~rst_n) begin
		hilo <= 0;
	end else if(in_func ==  5'b10010) begin
		hilo <= hilo + result_muldiv;
	end else if(in_func[4:1]==4'b1000) hilo <= result_muldiv;
end
	
endmodule


module dsp (
input [31:0] A,B,
input [2:0] func,
output reg [31:0] out
	
);

wire [3:0][7:0] p8a = A;
wire [3:0][7:0] p8b = B;
wire [1:0][15:0] p16a = A;
wire [1:0][15:0] p16b = B;



wire [8:0] padd8c [3:0];
adder #(8) adder8 [3:0] (p8a, p8b, func[0], padd8c);


wire [15:0]pmul8c [3:0];
assign pmul8c [3] = {p8a[3]*p8b[3]};
assign pmul8c [2] = {p8a[2]*p8b[2]};
assign pmul8c [1] = {p8a[1]*p8b[1]};
assign pmul8c [0] = {p8a[0]*p8b[0]};

wire [16:0] padd16c [1:0];
adder #(16) adder16 [1:0] (p16a, p16b, func[0], padd16c);

wire [31:0] pmul16c [1:0];
assign pmul16c [1] = {p16a[1]*p16b[1]}; 
assign pmul16c [0] = {p16a[0]*p16b[0]};

reg [8:0] nosat8   [3:0];
reg [16:0] nosat16 [1:0];


always @* begin
  case (func[1:0])
		2'b0: nosat8 = padd8c;
		2'b1: nosat8 = padd8c;
		2'b10: begin nosat8[3] = {(pmul8c[3][15:8]!=0), pmul8c[3][7:0]};
    nosat8[2] =  {(pmul8c[2][15:8]!=0), pmul8c[2][7:0]};
    nosat8[1] =  {(pmul8c[1][15:8]!=0), pmul8c[1][7:0]};
    nosat8[0] =  {(pmul8c[0][15:8]!=0), pmul8c[0][7:0]};
	 end
						
		2'b11: begin nosat8[3] = {(pmul8c[3][15:12]!=0), pmul8c[3][11:4]};
		nosat8[2] = {(pmul8c[2][15:12]!=0), pmul8c[2][11:4]};
		nosat8[1] = {(pmul8c[1][15:12]!=0), pmul8c[1][11:4]};
		nosat8[0] = {(pmul8c[0][15:12]!=0), pmul8c[0][11:4]};
						end
  endcase
end

always @* begin
  case (func[1:0])
		2'b0: nosat16 = padd16c;
		2'b1: nosat16 = padd16c;
		2'b10: begin nosat16[1] = {(pmul16c[1][31:16]!=0), pmul16c[1][15:0]};
						 nosat16[0] = {(pmul16c[0][31:16]!=0), pmul16c[0][15:0]};
		end
		2'b11:begin nosat16[1] = {(pmul16c[1][31:24]!=0), pmul16c[1][23:8]};
						nosat16[0] = {(pmul16c[0][31:24]!=0), pmul16c[0][23:8]};
						end
  endcase
end

wire [7:0] sat8 [3:0];
wire [15:0] sat16 [1:0];

sat #(8)  saturator8  [3:0] (nosat8, sat8);
sat #(16) saturator16 [1:0] (nosat16, sat16);

always @* begin
  casez (func[2])
		1'b0: out = {sat8[3], sat8[2], sat8[1], sat8[0]};
		1'b1: out = {sat16[1], sat16[0]};
		default:  out = {32{1'bz}}; 
  endcase
end


endmodule


module sat #(parameter WIDTH=8)(
	input [WIDTH:0] in, 
	output reg [WIDTH-1:0] out);
wire [WIDTH:0] min = -(2**(WIDTH-1));
wire [WIDTH:0] max = (2**(WIDTH-1))-1;

always @(*) begin
	if($signed(in) < $signed(min)) out = min;
	else if($signed(in) > $signed(max)) out = max;
	else out = in[WIDTH-1:0];
end

endmodule

module vsat (
	input [31:0] in, 
	input [4:0] bitnessminus1,
	output reg [31:0] out);

wire [31:0] max = 1<<(bitnessminus1)-1;// 16 bit ovf is when more 7fff = 1<<15-1 mod 2**32
wire [31:0] min = ~max; //not 7fff is ffff8000

always @(*) begin
	if($signed(in) < $signed(min)) out = min;
	else if($signed(in) > $signed(max)) out = max;
	else out = in;
end

endmodule


module adder #(parameter WIDTH = 32)(input signed [WIDTH-1:0] opA, input signed [WIDTH-1:0] opB, input addsub, output reg [WIDTH:0] resultc);
    
reg [WIDTH-1:0] temp;
reg dummy; 
always @* begin
	temp = opB ^ {WIDTH{addsub}};
end

always @* begin
  {resultc, dummy} = $signed({opA[WIDTH-1], opA, addsub}) + $signed({temp[WIDTH-1], temp, addsub});
end

endmodule
