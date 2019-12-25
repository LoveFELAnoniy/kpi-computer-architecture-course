`timescale 1ns/1ps
module bus_mux (
	input adr,
	input [31:0] in1,
	input [31:0] in2,
	output reg [31:0] out);

always @(*)begin
	if(adr)
		out = in1;
	else
		out = in2;
end

endmodule

