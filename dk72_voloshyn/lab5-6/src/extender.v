`timescale 1ns/1ps

module extender(instr, sign_ext);

input [15:0] instr;
output [31:0] sign_ext;

assign sign_ext = {{16{instr[15]}}, instr[15:0]};

endmodule 

