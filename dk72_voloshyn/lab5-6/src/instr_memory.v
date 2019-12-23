`timescale 1ns/1ps

module inst_memory#( parameter width = 32 ) (addr,instr);

input [4:0]addr;
output [width-1:0]instr;

reg [width-1:0] instm [31:0] ;

initial $readmemb("/home/sad/lab5-6/instruction.dat", instm);
assign instr = instm[addr];

endmodule 
