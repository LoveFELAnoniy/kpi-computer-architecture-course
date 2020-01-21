//SOME ELEMENTS TAKEN FROM Oleh Matiusha


`timescale 1ns/1ps


module mips #(parameter WIDTH = 32)(input CLOCK_27, input [3:0] KEY, inout [WIDTH-1:0] test);


	wire clk, arstn, regfile_we, dmem_we, of, zf, ctl_regdst, ctl_extop, ctl_alusrc, ctl_j, ctl_beq, ctl_bne, ctl_memtoreg;
	assign clk = CLOCK_27;
	assign arstn = KEY[0];
	wire [WIDTH-1:0] pc_out, pc_in, instr_out, op_a, op_b, reg_w, dmem_in, dmem_addr, dmem_out, alu_out, signext_out, reg_b, next_pc;


	wire [4:0] rs, rd, rt, shamt, reg_dst, alu_func;
	wire [5:0] opcode, func;
	wire [15:0] imm16;
	wire [25:0] imm26;

	assign {opcode, rs, rt, rd, shamt, func} = instr_out;
	assign imm16 = instr_out[15:0];
	assign imm26 = instr_out[25:0];


	register #(WIDTH) pc(clk, 1'b1, pc_in, pc_out, arstn); //PC

	imem #(WIDTH*2, WIDTH) instr_mem({2'b0,pc_out[31:2]}, instr_out);//byte aligned


	assign reg_dst = (ctl_regdst) ? rt : rd;
	regfile #(WIDTH,WIDTH) register_file(clk, regfile_we, arstn, rs, rt, reg_dst, reg_w, op_a, reg_b); 

	signext sign_extender(imm16, signext_out,ctl_extop );

	assign op_b = (ctl_alusrc) ? signext_out : reg_b; 
	lab4_alu alu(op_a, op_b, alu_func, alu_out, of, zf, shamt, clk, arstn);

	memory #(WIDTH) data_mem(clk, dmem_we, alu_out, reg_b, dmem_out, arstn, test);
	assign reg_w = (ctl_memtoreg) ? dmem_out : alu_out;

	next_pc nextpc(pc_out, imm26, ctl_beq, ctl_bne, ctl_j, zf, pc_in);


	alu_ctl alucontrol(opcode, func, alu_func);

	main_ctl mc(opcode, ctl_regdst, regfile_we, ctl_extop, ctl_alusrc, ctl_j, ctl_beq, ctl_bne, dmem_we, ctl_memtoreg);

endmodule



module main_ctl (opcode, ctl_regdst, ctl_regwrite, ctl_extop, ctl_alusrc, ctl_j, ctl_beq, ctl_bne, ctl_memwrite, ctl_memtoreg);
	input [5:0] opcode;
	output ctl_regdst, ctl_regwrite, ctl_extop, ctl_alusrc, ctl_j, ctl_beq, ctl_bne, ctl_memwrite, ctl_memtoreg;

	reg [8:0] ctl_vec;
	always @(opcode) begin
	casez(opcode)
		6'b000000: ctl_vec = 9'b011000000; //R
		6'b001000: ctl_vec = 9'b111100000; //addi
		6'b001001: ctl_vec = 9'b111100000;//mulli = addiu
		6'b001011: ctl_vec = 9'b111100000;//divi = sltiu
		6'b001100: ctl_vec = 9'b110100000;//andi
		6'b001101: ctl_vec = 9'b110100000;//ori
		6'b001110: ctl_vec = 9'b110100000;//xori
		6'b100011: ctl_vec = 9'b111100001;//lw
		6'b101011: ctl_vec = 9'b101100010;//sw
		6'b001010: ctl_vec = 9'b111100000;//slti
		6'b000010: ctl_vec = 9'b000010000;//j
		6'b000100: ctl_vec = 9'b000001000;//beq
		6'b000101: ctl_vec = 9'b000000100;//bne
		6'b100100: ctl_vec = 9'b110100000;//ssat
		default : ctl_vec = 9'bz;/* default */
	endcase
end
assign {ctl_regdst, ctl_regwrite, ctl_extop, ctl_alusrc, ctl_j, ctl_beq, ctl_bne, ctl_memwrite, ctl_memtoreg} = ctl_vec;

endmodule



module alu_ctl (opcode, funct, aluctl);
	input [5:0] opcode, funct;
	output reg [4:0] aluctl;
always @(opcode, funct) begin
	casez (opcode)
		6'b000000: begin 
			case (funct)
				6'b100000: aluctl = 5'b10110;//add
				6'b100010: aluctl = 5'b10111;//sub
				6'b011000: aluctl = 5'b10000;//MULT
				6'b011010: aluctl = 5'b10001;//DIV
				6'b100100: aluctl = 5'b11000;//and
				6'b100101: aluctl = 5'b11001;//or
				6'b100110: aluctl = 5'b11011;//xor
				6'b100111: aluctl = 5'b11010;//nor
				6'b000000: aluctl = 5'b00000;//sll
				6'b000100: aluctl = 5'b00000;//sllv
				6'b000010: aluctl = 5'b00010;//srl
				6'b000110: aluctl = 5'b00010;//srlv
				6'b000111: aluctl = 5'b00111;//srav
				6'b000011: aluctl = 5'b00111;//sra
				6'b101010: aluctl = 5'b11111;//slt
				6'b010000: aluctl = 5'b10101;//MFHI
				6'b010010: aluctl = 5'b10100;//MFLO
				//DSP subset
				6'b011001: aluctl = 5'b10010;//SMLAL=MULTU

				6'b100001: aluctl = 5'b01000;//PADDS8 = addu
				6'b001100: aluctl = 5'b01001;//PSUBS8
				6'b001110: aluctl = 5'b01010;//PMULS8
				6'b101011: aluctl = 5'b01011;//PMULFS8
				6'b001000: aluctl = 5'b01100;//PADDS16 
				6'b001001: aluctl = 5'b01101;//PSUBS16
				6'b001010: aluctl = 5'b01110;//PMULS16
				6'b001011: aluctl = 5'b01111;//PMULSF16  //NET OPKODOV TAK CHTO ETI INSTRUKCII RABOTATb NE BUDUT


				default : aluctl = 5'bz;/* default */
			endcase
		end
		6'b001000: aluctl = 5'b10110; //addi
		6'b001001: aluctl = 5'b10000;//mulli = addiu
		6'b001011: aluctl = 5'b10001;//divi = sltiu
		6'b001100: aluctl = 5'b11000;//andi
		6'b001101: aluctl = 5'b11001;//ori
		6'b001110: aluctl = 5'b11011;//xori
		6'b100011: aluctl = 5'b10110;//lw
		6'b101011: aluctl = 5'b10110;//sw
		6'b001010: aluctl = 5'b11111;//slti
		6'b000010: aluctl = 5'b10110;//j
		6'b000100: aluctl = 5'b10111;//beq
		6'b000101: aluctl = 5'b10111;//bne
		//DSP
		6'b100100: aluctl = 5'b11100;//SSAT=lbu
		default : aluctl = 5'bz;/* default */
	endcase
end
endmodule



module signext #(parameter WIDTH = 32)(a,y,ctl);
	input ctl;
	input  [15:0] a;
	output  [WIDTH-1:0] y;

	assign y = {{16{a[15]&ctl}}, a};

endmodule



//width hard coded due to instruction set unscalability
module next_pc #(parameter WIDTH = 32)(pc, imm26, beq, bne, j, z, newpc);
	input [WIDTH-1:0] pc; 
	input [25:0] imm26;
	input beq, bne, j, z;
	output wire [WIDTH-1:0] newpc;

	wire [WIDTH-1:0] imm26_se, add_out;
	
	assign imm26_se = ((beq & z) | (bne & !z)) ? {{14{imm26[15]}}, imm26[15:0], 2'b0} : 0;

	assign add_out = pc+imm26_se+32'h4;

	assign newpc = (j) ? {pc[WIDTH-1:28], imm26, 2'b0} : add_out;

endmodule
