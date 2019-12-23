//Code parts was taken from pan Shlikhta Oleksandr
`timescale 1ns/1ps

`define DATA_MEMORY_MIN 0
`define DATA_MEMORY_MAX 127

`define GPIO_MIN 128
`define GPIO_MAX 130

module data_control #(parameter WIDTH = 1)(addr, mem_write_in, mem_write_out, d_out_addr);

localparam ADDR_WIDTH = $clog2(WIDTH);

input [WIDTH-1:0] addr;
input mem_write_in;

output [WIDTH-1:0] mem_write_out;
output reg [ADDR_WIDTH-1:0] d_out_addr;

decod dec_0(d_out_addr, mem_write_out, mem_write_in);

always @* begin
	if(`DATA_MEMORY_MIN <= addr && addr <= `DATA_MEMORY_MAX) begin
		d_out_addr <= 0;
	end
	else if(`GPIO_MIN <= addr && addr <= `GPIO_MAX) begin
		d_out_addr <= 1;
	end
	else d_out_addr <= 31;
end
	
endmodule


module decod(addr, d_out, en);

input [4:0] addr;
input en;

output reg [31:0] d_out;

always @* begin

if(!en) d_out = 0;
else begin
	casez(addr)
		0:  d_out = 32'b00000000000000000000000000000001;
		1:  d_out = 32'b00000000000000000000000000000010;
		2:  d_out = 32'b00000000000000000000000000000100;
		3:  d_out = 32'b00000000000000000000000000001000;
		4:  d_out = 32'b00000000000000000000000000010000;
		5:  d_out = 32'b00000000000000000000000000100000;
		6:  d_out = 32'b00000000000000000000000001000000;
		7:  d_out = 32'b00000000000000000000000010000000;
		8:  d_out = 32'b00000000000000000000000100000000;
		9:  d_out = 32'b00000000000000000000001000000000;
		10: d_out = 32'b00000000000000000000010000000000;
		11: d_out = 32'b00000000000000000000100000000000;
		12: d_out = 32'b00000000000000000001000000000000;
		13: d_out = 32'b00000000000000000010000000000000;
		14: d_out = 32'b00000000000000000100000000000000;
		15: d_out = 32'b00000000000000001000000000000000; 
		16: d_out = 32'b00000000000000010000000000000000;
		17: d_out = 32'b00000000000000100000000000000000;
		18: d_out = 32'b00000000000001000000000000000000;
		19: d_out = 32'b00000000000010000000000000000000;
		20: d_out = 32'b00000000000100000000000000000000;
		21: d_out = 32'b00000000001000000000000000000000;
		22: d_out = 32'b00000000010000000000000000000000;
		23: d_out = 32'b00000000100000000000000000000000;
		24: d_out = 32'b00000001000000000000000000000000;
		25: d_out = 32'b00000010000000000000000000000000;
		26: d_out = 32'b00000100000000000000000000000000;
		27: d_out = 32'b00001000000000000000000000000000;
		28: d_out = 32'b00010000000000000000000000000000;
		29: d_out = 32'b00100000000000000000000000000000;
		30: d_out = 32'b01000000000000000000000000000000;
		31: d_out = 32'b10000000000000000000000000000000;
	endcase
	end
end
endmodule