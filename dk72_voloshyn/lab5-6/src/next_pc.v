`timescale 1ns/1ps 

module next_pc(pc_src,increm,zero,j,bne,beq,pc_out,imm26);

input  [25:0] imm26;
input  [31:0] increm;
input  beq,bne,zero,j;

output reg [31:0] pc_out;
output pc_src;

wire [31:0] Branches;

assign Branches = {{16{imm26[15]}},imm26[15:0]};
assign pc_src = j || (bne && ~zero) || (beq && zero) ; 

always@(*)begin
if((bne && ~zero) || (beq && zero))begin
		pc_out = increm + Branches; 
	end else if(j) begin
		pc_out = {increm[31:26],imm26[25:0]};
	end else
		pc_out = 32'bz;
end

endmodule

