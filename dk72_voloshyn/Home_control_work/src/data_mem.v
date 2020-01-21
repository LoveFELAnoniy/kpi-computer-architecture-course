//SOME ELEMENTS TAKEN FROM Oleh Matiusha

`timescale 1ns/1ps

module dmem #(parameter capacity = 128, WIDTH = 32) (clk, we, addr, wd,rd);


	input  clk, we;
	input  [WIDTH-1:0] addr, wd;
	output reg [WIDTH-1:0] rd;

	localparam addr_width = $clog2(capacity);

	wire [addr_width-1:0] addr_stripped = addr[0+:addr_width];

	reg [WIDTH-1:0] RAM [capacity-1:0];

	initial begin 
	integer i;
		for (i = 0; i < capacity; i=i+1) begin
			RAM[i]= {WIDTH{1'b0}};
		end
		$readmemh("/home/sad/Desktop/lab_7_gpio/fw/initrd.dat", RAM);
	end
	

	always @(posedge clk)
		if (we) RAM[addr_stripped] <= wd;
		
	always @(negedge clk) rd <= RAM[addr_stripped];

endmodule
