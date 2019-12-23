`timescale 1ns/1ps

module alu_ctrl(op,funk,alu_ctrl_out);

input [5:0] op;
input [5:0] funk;

output [5:0] alu_ctrl_out;

reg [5:0] war;

assign alu_ctrl_out = war;

always @(*) begin
	if(op == 5'b0) 
		war = funk;
	else
		war = op;
	casez (war)
		6'b100100: war = 6'b010110;
		6'b100101: war = 6'b010110;
		6'b100000: war = 6'b010111;
		6'b100001: war = 6'b010111;
		default: war = war;
	endcase

end

endmodule
 
