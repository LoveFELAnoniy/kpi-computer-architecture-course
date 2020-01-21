`timescale 1ns/1ps

module test;
	reg clk, rst_n;
	wire [31:0] dbg;
	reg [7:0]wim;
	assign dbg[7:0] = wim;
	mips m1(clk, {3'b0, rst_n}, dbg[31:0]);

	initial begin
		clk=0;
		forever #1 clk = ~clk;
	end

	initial begin 
		#2 rst_n = 0;
		#8 rst_n = 1'b1;
		wim = 0;
		#20000 wim = 'h80;
		#20000 wim='hff;
		#20000 $finish;


		
	end
endmodule
