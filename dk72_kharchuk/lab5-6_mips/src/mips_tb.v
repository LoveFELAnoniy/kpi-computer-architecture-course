
// Generated by Quartus II 64-Bit Version 13.0 (Build Build 232 06/12/2013)
// Created on Thu Oct 17 02:42:09 2019

module mips_tb();

reg CLOCK_sig;
reg arst_n_sig;

wire [2:0] LEDR_sig;
wire [6:0] instr_sig;

mips mips_inst
(
	.CLOCK(CLOCK_sig) ,	// input  CLOCK_sig
	.arst_n(arst_n_sig) ,	// input  arst_n_sig
	.LEDR(LEDR_sig) ,	// output [2:0] LEDR_sig
	.instr(instr_sig) 	// output [6:0] instr_sig
);

defparam mips_inst.WIDTH = 32;

initial begin
	CLOCK_sig = 0;
	forever #2 CLOCK_sig = ~CLOCK_sig;
end

initial begin
	arst_n_sig = 0;
	#4 arst_n_sig = 1;
end

initial begin
	#600 $stop();
end

endmodule