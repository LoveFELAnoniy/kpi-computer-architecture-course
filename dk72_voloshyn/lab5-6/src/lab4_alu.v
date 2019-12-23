`timescale 1ns/1ps


module ALU (A,B,operation,resault,of,zf,shamt);

parameter WIDTH = 32;

input [WIDTH-1:0]A;
input [WIDTH-1:0]B;
input [4:0]operation;
input [4:0] shamt;
output reg zf;
output reg [WIDTH-1:0] resault;
output reg of;

wire t_ovf;
wire [WIDTH-1:0] o_shift;
wire [WIDTH-1:0] o_su_ad;
wire [WIDTH-1:0] o_mu_di;
reg [WIDTH-1:0] o_alu;
wire sltb;
assign sltb = A < B;
barrel_shifter bs1(
		.data_in(B),
        .bs_opsel(operation[2:0]),
        .shift_amount(shamt),
        .result(o_shift)
         
	);

add_and_sub aad1(
	.A(A),
	.B(B),
	.result(o_su_ad),
	.instr(operation[0]),
	.over_f(t_ovf)

	);

mul_div md1 (	
	.A(A),
	.B(B),
	.oper(operation[1:0]),
	.out(o_mu_di)

	);

always @* begin
casez(operation)
	5'b00???: o_alu = o_shift;
	5'b100??: o_alu = o_mu_di;
	5'b1011?: o_alu = o_su_ad;
	5'b11000: o_alu = A & B;
	5'b11001: o_alu = A | B;
	5'b11010: o_alu = ~(A | B);
	5'b11011: o_alu = A ^ B;
	5'b11111: o_alu = {{WIDTH-1{1'b0}},sltb};
	 default: o_alu = {WIDTH,{1'bz}};
endcase 
 resault = o_alu;
 zf = ~|o_alu;
 of = t_ovf & (operation[4:1] == 4'b1011);

end

 
endmodule

module add_and_sub(
input [31:0] A, 
input [31:0] B,
input instr,
output reg [31:0] result,
 output reg over_f

);

reg [31:0] invers;
reg [33:0] temp;

always @* begin
	invers = B ^ {32{instr}};
end

always @* begin
  temp = {A, instr} + {invers, instr};
  result = temp[32:1];
  over_f = ((A[31] ^ result[31]) & (invers[31] ^ result[31]))^result[31]; // do not anderstand , deal with this
end

endmodule

module mul_div #(parameter WIDTH = 32) (A, B, oper, out); 

// most part of the module has been                                                          
// copied from Volynko's multiplucation
// and division module

input [WIDTH-1:0] A;				           
input [WIDTH-1:0] B;
input [1:0]oper;
output reg [WIDTH-1:0]out;

wire [WIDTH*2-1:0]mul;
wire [WIDTH-1:0]div;
wire [WIDTH-1:0]rest;

assign mul = A * B;
assign div = A / B;
assign rest = A % B;

always @* begin
	casez(oper)
		2'b00: out = mul[WIDTH-1:0];
		2'b10: out = mul[WIDTH*2-1:WIDTH];
		2'b01: out = div[WIDTH-1:0];
		2'b11: out = rest[WIDTH-1:0];
		default: out = {WIDTH,{1'bz}};

	endcase

end
	
endmodule 

module barrel_shifter #(parameter width = 32) (data_in,bs_opsel,shift_amount,result);

input   [31:0]data_in;
input  [2:0]bs_opsel;
input  [4:0]shift_amount;
output reg [31:0]result;  
wire arithm;

assign arithm = data_in[31] & bs_opsel[2];
wire [63:0]l_shift = {data_in, data_in} << shift_amount;
wire [63:0]r_shift = {data_in, data_in} >> shift_amount;
wire [31:0]a_r_shift = $signed({arithm,data_in}) >>> shift_amount; 

// Alexandr Shlihta
// adviced an idea 
//how to create 
//arephmetical
// shift block 

always @* begin
  casez(bs_opsel)
    3'b?00:  result = l_shift[31:0];   // SLL
    3'b010:  result = l_shift[63:32];  // SRL
    3'b?01:  result = r_shift[63:32];  // ROL
    3'b011:  result = r_shift[31:0];   // ROR   
    3'b11?:  result = a_r_shift[31:0]; // SRA
     default: result = {32{1'bz}};
  endcase

end 
		
endmodule
		











