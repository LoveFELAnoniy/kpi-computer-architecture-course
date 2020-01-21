`timescale 1ns/1ps

module muldiv #(parameter WIDTH = 32)(input [WIDTH-1:0] in_A, in_B, input [1:0] check, output reg [WIDTH*2-1:0] out);

wire [WIDTH*2-1:0] mulout;
wire [WIDTH-1:0] divout, res;
assign mulout = {32'b0, in_A} * {32'b0, in_B};
assign divout = in_A / in_B;
assign res = in_A % in_B;

always @* begin
  casez (check)
		2'b00:   out = mulout;
		2'b10:   out = mulout;
		2'b01:   out = {divout,res};
		2'b11:   out = {divout,res};
		default: out = {WIDTH*2{1'bz}};
  endcase
end

endmodule
