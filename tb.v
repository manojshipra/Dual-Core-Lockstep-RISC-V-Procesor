`timescale 1 ps / 1 ps
`include "dual_core_w_lock_memory.v"
module tb;
	
	parameter simdelay = 20; // guaranteed 2 clocks
	parameter clock_delay = 10;
	parameter fullclk = 11;
		
	reg clk; 
	reg rst; 
	reg start;
	wire [1:0]done;
	wire [1:0]lock;
	wire [3:0]S0;
	wire [3:0]S1;
	wire [3:0]NS0;
	wire [3:0]NS1;
	wire [31:0]r10;
	wire [31:0]r20;
	wire [31:0]r11;
	wire [31:0]r21;
	wire [31:0]result0;
	wire [31:0]result1;
	wire [6:0]opcode0;
	wire [6:0]opcode1;
	wire [7:0]PC0;
	wire [7:0]PC1;
	wire [5:0]address_a;
	wire [5:0]address_b;
	wire [31:0] data_a;
	wire [31:0] data_b;
	wire wren_a;
	wire wren_b;
	wire [31:0] q_a;
	wire [31:0] q_b;
	wire whose_turn;
	wire finished_storing;
	wire [1:0] need_lock;
	wire [4:0] rr11,rr12,rr21,rr22;
	wire mismatch;
	wire[31:0] instruc_0,instruc_1;
	dual_core_w_lock_memory DUT(clk,
										rst,
										start,
										done,
										lock,
										S0,
										S1,
										NS0,
										NS1,
										r10,
										r20,
										r11,
										r21,
										result0,
										result1,
										opcode0,
										opcode1,
										PC0,
										PC1,
										address_a,
										address_b,
										data_a,
										data_b,
										wren_a,
										wren_b,
										q_a,
										q_b,
										whose_turn,
										finished_storing,
										need_lock,
										rr11,rr12,rr21,rr22,mismatch,instruc_0,instruc_1
										);
	
	initial
	begin
		
		/* start clk and reset */
		#(simdelay) rst = 1'b0; clk = 1'b0;
		#(simdelay) rst = 1'b1; /* go into normal circuit operation */ 
		#(simdelay) start = 1'b1;
		#100; // let simulation finish
	
	end

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0,tb);
	end

	
		// this generates a clock
	always
	begin
		#(clock_delay) clk = !clk;
	end
	
	//initial
	//	#1000 $stop; // This stops the simulation ... May need to be greater or less depending on your program
	/* this checks done every clock and when it goes high ends the simulation */
	always @(clk)
	begin
		if (done == 2'd3)
		begin
			$write("DONE:"); 
			$stop;
		end
	end
initial begin
#15810
			$display("x1:%0h",DUT.core0.register.reg_storage[63:32]);
			$display("x2:%0h",DUT.core0.register.reg_storage[95:64]);
			$display("x3:%0h",DUT.core0.register.reg_storage[127:96]);
			$display("x4:%0h",DUT.core0.register.reg_storage[159:128]);
			$display("x5:%0h",DUT.core0.register.reg_storage[191:160]);
			$display("x6:%0h",DUT.core0.register.reg_storage[223:192]);
			$display("x7:%0h",DUT.core0.register.reg_storage[255:224]);
			$display("x8:%0h",DUT.core0.register.reg_storage[287:256]);
			$display("x9:%0h",DUT.core0.register.reg_storage[319:288]);
			$display("x10:%0h",DUT.core0.register.reg_storage[351:320]);
			$display("x11:%0h",DUT.core0.register.reg_storage[383:352]);	
			$display("x12:%0h",DUT.core0.register.reg_storage[415:384]);
			$display("x13:%0h",DUT.core0.register.reg_storage[447:416]);
			$display("x14:%0h",DUT.core0.register.reg_storage[479:448]);
			$display("x15:%0h",DUT.core0.register.reg_storage[511:480]);
			$display("x16:%0h",DUT.core0.register.reg_storage[543:512]);
			$display("x17:%0h",DUT.core0.register.reg_storage[575:544]);
			$display("x18:%0h",DUT.core0.register.reg_storage[607:576]);
			$display("x19:%0h",DUT.core0.register.reg_storage[639:608]);
			$display("x20:%0h",DUT.core0.register.reg_storage[671:640]);
			$display("x21:%0h",DUT.core0.register.reg_storage[703:672]);
			$display("x22:%0h",DUT.core0.register.reg_storage[735:704]);
			$display("x23:%0h",DUT.core0.register.reg_storage[767:736]);
			$display("x24:%0h",DUT.core0.register.reg_storage[799:768]);
			$display("x25:%0h",DUT.core0.register.reg_storage[831:800]);
			$display("x26:%0h",DUT.core0.register.reg_storage[863:832]);
			$display("x27:%0h",DUT.core0.register.reg_storage[895:864]);
			$display("x28:%0h",DUT.core0.register.reg_storage[927:896]);
			$display("x29:%0h",DUT.core0.register.reg_storage[959:928]);
			$display("x30:%0h",DUT.core0.register.reg_storage[991:960]);
			$display("x31:%0h",DUT.core0.register.reg_storage[1023:992]);
end
initial begin
#15810
			$display("x1:%0h",DUT.core1.register.reg_storage[63:32]);
			$display("x2:%0h",DUT.core1.register.reg_storage[95:64]);
			$display("x3:%0h",DUT.core1.register.reg_storage[127:96]);
			$display("x4:%0h",DUT.core1.register.reg_storage[159:128]);
			$display("x5:%0h",DUT.core1.register.reg_storage[191:160]);
			$display("x6:%0h",DUT.core1.register.reg_storage[223:192]);
			$display("x7:%0h",DUT.core1.register.reg_storage[255:224]);
			$display("x8:%0h",DUT.core1.register.reg_storage[287:256]);
			$display("x9:%0h",DUT.core1.register.reg_storage[319:288]);
			$display("x10:%0h",DUT.core1.register.reg_storage[351:320]);
			$display("x11:%0h",DUT.core1.register.reg_storage[383:352]);	
			$display("x12:%0h",DUT.core1.register.reg_storage[415:384]);
			$display("x13:%0h",DUT.core1.register.reg_storage[447:416]);
			$display("x14:%0h",DUT.core1.register.reg_storage[479:448]);
			$display("x15:%0h",DUT.core1.register.reg_storage[511:480]);
			$display("x16:%0h",DUT.core1.register.reg_storage[543:512]);
			$display("x17:%0h",DUT.core1.register.reg_storage[575:544]);
			$display("x18:%0h",DUT.core1.register.reg_storage[607:576]);
			$display("x19:%0h",DUT.core1.register.reg_storage[639:608]);
			$display("x20:%0h",DUT.core1.register.reg_storage[671:640]);
			$display("x21:%0h",DUT.core1.register.reg_storage[703:672]);
			$display("x22:%0h",DUT.core1.register.reg_storage[735:704]);
			$display("x23:%0h",DUT.core1.register.reg_storage[767:736]);
			$display("x24:%0h",DUT.core1.register.reg_storage[799:768]);
			$display("x25:%0h",DUT.core1.register.reg_storage[831:800]);
			$display("x26:%0h",DUT.core1.register.reg_storage[863:832]);
			$display("x27:%0h",DUT.core1.register.reg_storage[895:864]);
			$display("x28:%0h",DUT.core1.register.reg_storage[927:896]);
			$display("x29:%0h",DUT.core1.register.reg_storage[959:928]);
			$display("x30:%0h",DUT.core1.register.reg_storage[991:960]);
			$display("x31:%0h",DUT.core1.register.reg_storage[1023:992]);
end
endmodule
