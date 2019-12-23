`timescale 1ns/1ps

module control_unit(
	op,
	beq,
	bne,
	 j,
	 MemWrite,
	 MemtoReg, 
 	RegDst,
	 RegWr,
	 ExtOp,
	 ALUSrc

,);
input [5:0]op;
output reg beq,bne,j,MemWrite,MemtoReg;
output reg RegDst,RegWr,ExtOp,ALUSrc; 
reg [8:0]v;

always @(*) begin

casez(op)
/*
the idea of using vector 
has been advised by Matiusha Oleg
*/ 
6'b000000: v = 9'b010000000; 	//R
6'b010110: v = 9'b111100000; 	//addi
6'b010111: v = 9'b111100000; 	//addi
6'b111111: v = 9'b111100000;	//slti
6'b011000: v = 9'b110100000;	//andi
6'b011001: v = 9'b110100000;	//ori
6'b011011: v = 9'b110100000;	//xori
6'b100100: v = 9'b111100001;
6'b100101: v = 9'b101100010;
6'b100011: v = 9'b000010000;
6'b100000: v = 9'b000001000;
6'b100001: v = 9'b000000100;
default: v = 9'bz;

endcase 

{RegDst, RegWr, ExtOp, ALUSrc, j, beq, bne, MemWrite, MemtoReg} = v;

end 

endmodule

