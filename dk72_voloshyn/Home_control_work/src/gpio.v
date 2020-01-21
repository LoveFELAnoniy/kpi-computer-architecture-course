
module memory #(parameter WIDTH = 32) (clk, we, addr, wd,rd, gpio_rst, gpio_ioport);
	input  clk, we, gpio_rst;
	input  [WIDTH-1:0] addr, wd;
	output reg [WIDTH-1:0] rd;
	inout [WIDTH-1:0] gpio_ioport;

	wire [WIDTH-1:0] ram_rd, ddr_out, port_out, pin_out;

	decoder #(32) dec(addr, ram_we, ddr_we, port_we, pin_we);

	dmem #('h80, WIDTH) data_mem(clk, ram_we&we, addr, wd, ram_rd);
	gpio #(WIDTH) gpio0   (clk, gpio_rst, ddr_we&we, port_we&we, wd, wd, ddr_out, port_out, pin_out, gpio_ioport);

	assign rd = (ram_we)?ram_rd : (ddr_we)?ddr_out : (port_we)?port_out : (pin_we)? pin_out : '0;



endmodule



module decoder #(parameter WIDTH = 32) (i_addr, ram_we, ddr_we, port_we, pin_we);
	input [WIDTH-1:0] i_addr;
	output wire ram_we, ddr_we, port_we, pin_we;

	assign ram_we = (i_addr<'h80);
	assign ddr_we = (i_addr=='h80);
	assign port_we = (i_addr=='h81);
	assign pin_we = (i_addr=='h82);

endmodule




module gpio #(parameter WIDTH = 32) (clk, rst, ddr_we, port_we, ddr_in, port_in, ddr_out, port_out, pin_out, ioport);
	input clk;
	input rst;
	input ddr_we, port_we;
	input [WIDTH-1:0] ddr_in, port_in;
	output [WIDTH-1:0] ddr_out, port_out, pin_out;
	inout [WIDTH-1:0] ioport;
	
	
	reg [WIDTH-1:0] ddr, port, pin, ibuffer;
	wire[WIDTH-1:0] ddrw = ddr, portw = port;
	assign port_out = port;
	assign pin_out = pin;
	assign ddr_out = ddr;

	genvar i;
	generate
		for (i = 0; i < WIDTH; i++) begin : bidir
        	assign ioport[i] = ddrw[i] ? portw[i] : 1'bz;
		end
	endgenerate


	always_ff @(posedge clk or negedge rst) begin
		if(!rst) {ddr, port, pin, ibuffer} <= '0;
		else begin 
			if (ddr_we) ddr <= ddr_in;
			if (port_we) port <= port_in;
			pin <= ibuffer;
			ibuffer <= ioport;
		end
	end

endmodule



