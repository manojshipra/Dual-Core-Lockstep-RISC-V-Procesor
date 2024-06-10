
`timescale 1ns / 1ps

module main_memory(
    input wire clk,                 // Clock input
    input wire reset_n,             // Active-low asynchronous reset
    input wire en,                  // Enable signal
    input wire we,                  // Write enable
    input wire [7:0] address,       // Memory address
    input wire [31:0] data_in,      // Data input for writing
    output reg [31:0] data_out      // Data output for reading
);

    parameter SIZE = 256; // Memory size as number of 32-bit words

    // Memory array declaration
    reg [31:0] mem_array [0:SIZE-1];

    // Memory read and write operations with reset
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 32'd0;  // Reset data output to 0
        end
        else if (en) begin
            if (we) begin
                // Write operation
                mem_array[address] <= data_in;
            end else begin
                // Read operation
                data_out <= mem_array[address];
            end
        end
    end

endmodule

