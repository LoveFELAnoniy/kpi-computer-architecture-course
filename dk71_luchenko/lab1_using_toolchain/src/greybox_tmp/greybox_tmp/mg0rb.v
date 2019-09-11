//lpm_mux CBX_SINGLE_OUTPUT_FILE="ON" LPM_PIPELINE=1 LPM_SIZE=2 LPM_TYPE="LPM_MUX" LPM_WIDTH=1 LPM_WIDTHS=1 clock data result sel
//VERSION_BEGIN 13.0 cbx_mgl 2013:06:12:18:33:59:SJ cbx_stratixii 2013:06:12:18:03:33:SJ cbx_util_mgl 2013:06:12:18:03:33:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2013 Altera Corporation
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, Altera MegaCore Function License 
//  Agreement, or other applicable license agreement, including, 
//  without limitation, that your use is for the sole purpose of 
//  programming logic devices manufactured by Altera and sold by 
//  Altera or its authorized distributors.  Please refer to the 
//  applicable agreement for further details.



//synthesis_resources = lpm_mux 1 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  mg0rb
	( 
	clock,
	data,
	result,
	sel) /* synthesis synthesis_clearbox=1 */;
	input   clock;
	input   [1:0]  data;
	output   [0:0]  result;
	input   [0:0]  sel;

	wire  [0:0]   wire_mgl_prim1_result;

	lpm_mux   mgl_prim1
	( 
	.clock(clock),
	.data(data),
	.result(wire_mgl_prim1_result),
	.sel(sel));
	defparam
		mgl_prim1.lpm_pipeline = 1,
		mgl_prim1.lpm_size = 2,
		mgl_prim1.lpm_type = "LPM_MUX",
		mgl_prim1.lpm_width = 1,
		mgl_prim1.lpm_widths = 1;
	assign
		result = wire_mgl_prim1_result;
endmodule //mg0rb
//VALID FILE
