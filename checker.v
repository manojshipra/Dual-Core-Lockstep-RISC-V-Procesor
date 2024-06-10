module checker(
    input clk,
    input rst,
    input [31:0] result0,  
    input [31:0] result1,  
    input [7:0] PC0,       
    input [7:0] PC1,       
    input [31:0] r10, r20, r11, r21,
    input [31:0] instruc_0,instruc_1,
    output reg error_detected
);

// Fixed-size buffers for 5 clock cycle delay
reg [31:0] result_buffer[0:4];
reg [7:0] pc_buffer[0:4];
reg [31:0] r1_buffer[0:4];
reg [31:0] r2_buffer[0:4];
reg[31:0] instruc_buffer[0:4];
integer i;


always @(posedge clk or negedge rst) begin
    if (!rst) begin
        for (i = 0; i < 5; i = i + 1) begin
            result_buffer[i] <= 0;
            pc_buffer[i] <= 0;
	    r1_buffer[i]<=0;
	    r2_buffer[i]<=0;
	    instruc_buffer[i]<=0;
        end
        error_detected <= 0;
    end else begin
     
        for (i = 4; i > 0; i = i - 1) begin
            r1_buffer[i] <= r1_buffer[i - 1];
	    r2_buffer[i] <= r2_buffer[i - 1];
            pc_buffer[i] <= pc_buffer[i - 1];
	    result_buffer[i]<=result_buffer[i-1];
	    instruc_buffer[i]<=instruc_buffer[i-1];
        end

        result_buffer[0] <= result0;
        pc_buffer[0] <= PC0;
	r1_buffer[0]<=r10;
	r2_buffer[0]<=r20;
	instruc_buffer[0]<=instruc_0;

  
        if (pc_buffer[4] === PC1 && r1_buffer[4] === r11 && r2_buffer[4] === r21) begin
    		if (result_buffer[4] !== result1 || instruc_buffer[4] !== instruc_1) begin
        		error_detected <= 1;
    		end else begin
        		error_detected <= 0;
    		end
	end

    end
end

endmodule


