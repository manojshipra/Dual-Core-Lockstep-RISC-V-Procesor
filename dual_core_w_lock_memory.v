`include "tiny_risc_v.v"
`include "checker.v"
module dual_core_w_lock_memory(
	input clk, 
	input rst, 
	input start,
	output wire [1:0] done,
	output reg [1:0] lock,
	output wire [3:0] S0, S1, NS0, NS1,
	output wire [31:0] r10, r20, r11, r21,
	output wire [31:0] result0, result1,
	output wire [6:0] opcode0, opcode1,
	output wire [7:0] PC0, PC1,
	output wire [5:0] address_a, address_b,
	output wire [31:0] data_a, data_b,
	output wire wren_a, wren_b,
	output wire [31:0] q_a, q_b,
	output reg whose_turn,
	output reg finished_storing,
	output wire [1:0]need_lock,
output wire [4:0] rr11,rr12,rr21,rr22,
output wire mismatch,
output wire [31:0] instruc0,instruc1
);
// Delay start signal for core1
    reg start_core0 = 0;
    reg start_core1 = 0;
    reg [2:0] delay_counter = 0; // 3-bit counter to count up to 5
    reg delay_done = 0; // Flag to indicate delay is done

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            start_core0 <= 0;
            start_core1 <= 0;
            delay_counter <= 0;
            delay_done <= 0;
        end else if (start && !delay_done) begin
            start_core0 <= 1; // Start core0 immediately
            if (delay_counter < 5) begin
                delay_counter <= delay_counter + 1;
            end else begin
                start_core1 <= 1; // Start core1 after 5 clock cycles
                delay_done <= 1; // Prevent further delay counting
            end
        end
    end
	
	tiny_risc_v core0(clk, rst, start_core0, 1'b0, lock[0], q_a, done[0], S0, NS0, r10, r20, result0, opcode0, PC0,
							address_a,
							data_a,
							wren_a,
							need_lock[0],
							rr11,rr12,instruc0
							);

	tiny_risc_v core1(clk, rst, start_core1, 1'b1, lock[1], q_b, done[1], S1, NS1, r11, r21, result1, opcode1, PC1,
							address_b,
							data_b,
							wren_b,
							need_lock[1],
							rr21,rr22,instruc1
							);
	
	checker check(clk,rst,result0,result1,PC0,PC1,r10,r20,r11,r21,instruc0,instruc1,mismatch);




	always @(posedge clk or negedge rst)
	begin
		if (rst == 1'b0)
		begin
			whose_turn <= 1'b0;
			finished_storing <= 1'b1;
			lock <= 2'b00;
		end
		else if ((need_lock[1] == 1'b1) & (need_lock[0] == 1'b1))
		begin
			whose_turn <= 1'b0;
			lock <= whose_turn + 2'b1;
			finished_storing <= 1'b0;
		end
		else if (need_lock[0] == 1'b1)
		begin
			lock <= 2'b10; // lock core 1
			whose_turn <= 1'b1; // next time both ask for lock, lock core 0
			finished_storing <= 1'b0;
		end
		else if (need_lock[1] == 1'b1)
		begin
			lock <= 2'b01; // lock core 0
			whose_turn <= 1'b0; // next time both ask for lock, lock core 1
			finished_storing <= 1'b0;
		end
		else
		begin
			lock <= 2'b00;
		end
	end
endmodule
