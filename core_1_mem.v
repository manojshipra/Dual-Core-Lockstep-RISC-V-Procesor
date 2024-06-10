`timescale 1 ps / 1 ps

module core_1_mem (
    input [7:0] address,
    input clock,
    output reg [31:0] instruction
);

    // Memory declaration
    reg [31:0] instruction_mem [0:255]; 

    // Initialization (using a separate file 'instructions_init.hex' for clarity)
    initial begin
        $readmemh("instructions_init1.hex", instruction_mem);
    end

    // Read logic
    always @(posedge clock) begin
        instruction <= instruction_mem[address]; 
    end

endmodule

