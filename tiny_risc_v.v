`include "core_0_mem.v"
`include "core_1_mem.v"
`include "alu.v"
`include "register_file.v"
`include "instruction_parser.v"
`include "main_memory.v"
module tiny_risc_v(
input clk, 
input rst, 
input start,
input core_num,
input lock,
input [31:0]gq,
output reg done,
output reg [3:0]S,
output reg [3:0]NS,
output reg [31:0]r1, r2,
output wire [31:0]result,
output wire [6:0]opcode,
output reg [7:0]PC,
output reg [5:0]gaddress,
output reg [31:0]gdata,
output reg gwren,
output reg need_lock,
output reg [4:0] rr1,rr2,
output reg[31:0] instruction
);
/* FSM signals and parameters */
//reg [2:0] S;
//reg [2:0] NS;
parameter START = 4'd0;
parameter FETCH = 4'd1;
parameter EXECUTE = 4'd2;
parameter WRITEBACK = 4'd3;
parameter WRITEREG = 4'd4;
parameter WRITEMEM = 4'd5;
parameter DONE = 4'd6;

// parser signals
//reg [31:0]instruction;
//wire [6:0] opcode;
wire [4:0] s1, s2, de, i5;
wire [6:0] funct7, i7;
wire [2:0] funct3;
wire [11:0] i12;
wire [19:0] address;

//memory signal
reg [2:0]double;
//reg [7:0]PC;

//alu signal
//reg [31:0]r1, r2;
reg [7:0]alu_control;
//wire [31:0]result;

reg [31:0]in1, in2;
reg [7:0]aluc;
wire [31:0]out;

reg [31:0]aluin1, aluin2;
reg [7:0]alucon;
wire [31:0]aluout;

//register signal
reg we;
//reg [4:0]rr1, rr2, 
reg [4:0] wr;
reg [31:0] wd;
wire [31:0]rd1, rd2;

//wait signalS
reg readwait;
reg [2:0]writewait;
reg [1:0]memwait;

//memory signals
reg [7:0]mem_lo;
reg [31:0]mem_in;
reg mem_en;
wire [31:0]mem_out_0;
wire [31:0]mem_out_1;

//global memory signals
reg [5:0]address_a, address_b;
reg [31:0]data_a, data_b;
reg wren_a, wren_b;
wire [31:0]q_a, q_b;
wire [31:0]unread_a, unread_b;

core_0_mem mem_0(mem_lo, clk, mem_out_0);	
core_1_mem mem_1(mem_lo, clk, mem_out_1);
instruction_parser iparse (opcode, s1, s2, de, i5, funct7, i7, funct3, i12, address, instruction);
alu my_alu0(r1, r2, alu_control, result);
alu my_alu1(in1, in2, aluc, out);
alu my_alu2(aluin1, aluin2, alucon, aluout);

register_file register(clk, rst, we, rr1, rr2, wr, wd, rd1, rd2);

reg [31:0] data_in;     // Data input for writing
wire [31:0] data_out;
reg en;
main_memory mm(clk,rst,1'b1,mem_en,mem_lo, mem_in,data_out);

wire[12:0] immediate={instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
wire[20:0] jal_offset={instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
/* S update always block */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= START;
	else
		S <= NS;
end

/* NS transitions always block */
always @(*)
begin
	case (S)
		START: begin
			if(start == 1'b1)
					NS = FETCH;
			else
					NS = START;
		end
		FETCH: begin
			if((double != 3'd7) | (lock == 1'b1)) NS = FETCH;
			else
			NS = EXECUTE;
		end
		EXECUTE: begin
			if (lock == 1'b1)
				NS = EXECUTE;
			else if ((opcode == 7'b1100011) | (opcode == 7'b1000000) | (opcode == 7'b0100000)) //branch
				NS = WRITEBACK;
			else if ((opcode == 7'b1100111) & (i12 == 12'd0) & (funct3 == 3'd0) & (de == 5'd0)) //jr
				NS = WRITEBACK;
			else if ((opcode == 7'b0100011) | (opcode == 7'b0000011) | (opcode == 7'b1111110) | (opcode == 7'b1111111)) //load or store
				NS = WRITEMEM;
			else
				NS = WRITEREG;
		end
		WRITEREG: begin
			if((writewait != 3'd7) | (lock == 1'b1)) NS = WRITEREG;
			else NS = WRITEBACK;
		end
		WRITEMEM: begin
			if((memwait != 2'd3) | (lock == 1'b1)) NS = WRITEMEM;
			else NS = WRITEBACK;
		end
		WRITEBACK:
		begin
			if (lock == 1'b1)
				NS = WRITEBACK;
			else if(PC == 8'd28)
				NS = DONE;
			else
				NS = FETCH;
		end
		DONE:
		begin
			NS = DONE;
		end
		default: NS = DONE;
	endcase
end

/* clocked control signals always block */
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		done <= 1'b0;
		instruction <= 32'd0;
		r1 <= 32'd0;//Alu signals
		r2 <= 32'd0;
		alu_control <= 8'hFF;
		in1 <= 32'd0;
		in2 <= 32'd0;
		aluc <= 8'hFF;
		aluin1 <= 32'd0;
		aluin2 <= 32'd0;
		alucon <= 8'hFF;
		we <= 1'b0;//register signals
		rr1 <= 5'd0;
		rr2 <= 5'd0;
		wr <= 5'd0;
		wd <= 32'd0;
		PC <= 8'b00000000;
		double <= 2'd0;//wait signals
		readwait <= 1'd0;
		writewait <= 1'b0;
		writewait <= 2'd0;
		mem_lo <= 8'd0;//memory signals
		mem_in <= 32'd0;
		mem_en <= 1'b0;
		gaddress <= 6'd0;
		gdata <= 32'd0;
		gwren <= 1'b0;
		need_lock <= 1'b0;
		en=1'b0;
		
	end
	else
	begin
		case (S)
			START: begin
				done <= 1'b0;
				instruction <= 32'd0;
				r1 <= 32'd0;
				r2 <= 32'd0;
				alu_control <= 8'hFF;
				we <= 1'b0;
				rr1 <= 5'd0;
				rr2 <= 5'd0;
				wr <= 5'd0;
				wd <= 32'hFFFFFFFF;
				PC <= 8'd0;
				double <= 2'd0;
				readwait <= 1'd0;
				writewait <= 1'b0;
				memwait <= 2'd0;
				mem_lo <= PC;//memory signals
				mem_in <= 32'd0;
				mem_en <= 1'b0;
				gaddress <= 6'd0;
				gdata <= 32'd0;
				gwren <= 1'b0;
				need_lock <= 1'b0;
				en=1'b0;
			end
			FETCH: begin
			mem_lo <= PC;
			we <= 1'b0;//register signals
			rr1 <= 5'd0;
			rr2 <= 5'd0;
			wr <= 5'd0;
			wd <= 32'd0;
			if(core_num) 
				instruction <= mem_out_1;
			else
				instruction <= mem_out_0;
			double<=double+3'd1;
			case (opcode)
				7'b0110011: //OP
				begin
					rr1 <= s1;
					rr2 <= s2;
					wr <= de;
					r1 <= rd1;
					r2 <= rd2;
				end
				7'b0010011: //OP-IMM
				begin
					rr1 <= s1;
					wr <= de;
					r1 <= rd1;
					case (funct3)
						3'b000: //ADDI
						begin
							r2 <= $signed(i12);
						end
						3'b001: //SLLI
						begin
							r2 <= $signed(i5);
						end
						3'b010: // SLTI
						begin
							r2 <= $signed(i12);
						end
						3'b011: // SLTIU
						begin
							r2 <= $signed(i12);
						end
						3'b100: // XORI
						begin
							r2 <= $signed(i12);
						end
						3'b101: // SRLI or SRAI
						begin
							if (funct7 == 7'b0000000) //SRLI
							begin
								r2 <= $signed(i5);
							end
							else // SRAI
							begin
								r2 <= $signed(i5);
							end
						end
						3'b110: // ORI
						begin
							r2 <= $signed(i12);
						end
						3'b111: // ANDI
						begin
							r2 <= $signed(i12);
						end
					endcase
				end
				7'b0110111: //LUI
				begin
					wr <= de;
					r2 <= $signed(address);
				end
				7'b0010111: //AUIPC
				begin
					wr <= de;
					r1 <= PC;
					r2 <= $signed(address);
				end
				7'b0000011: //LW
				begin
					//rr1 <= s1;
					//r1 <= rd1;
					r1<=s1;
					r2 <= $signed(i12);
					wr <= de;
					
				end
				7'b0100011: //SW
				begin
					//rr1 <= s1;
					rr1<=s2;
					rr2 <= s2;
					//r1 <= rd1;
					r1<=s1;
					r2 <= $signed({i7,i5});//rd2;
					//mem_in <= rd2;
					mem_in<=rd1;

				end
				7'b1101111: //JAL
				begin
					wr <= de;
					r1 <= PC;
					r2 <= 32'd1;
					in1 <= PC;
					in2 <= $signed(address);
				end
				7'b1100111: //JR or JALR
				begin
					if ((i12 == 12'd0) & (funct3 == 3'd0) & (de == 5'd0)) //JR
					begin
						rr1 <= s1; //jump to rd1
					end
					else //JALR
					begin
						rr1 <= s1;
						r1 <= rd1;
						r2 <= $signed(i12);
						wr <= de;
						in1 <= PC;
						in2 <= 32'd1;
					end
				end
				7'b1100011: //BRANCH
				begin	
					case (funct3)
						3'b000: //BEQ
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if equal take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //if not take result of alu2								
						end
						3'b001: //BNE
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if NOT equal take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //else take result of alu2								
						end
						3'b100: //BLT
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if less than take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //if not take result of alu2							
						end
						3'b101: //BGE
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if bigger or equal take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //if not take result of alu2							
						end
						3'b110: //BLTU
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if less than take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //if not take result of alu2							
						end
						3'b111: //BGEU
						begin
							rr1 <= s1;
							rr2 <= s2;
							r1 <= rd1;
							r2 <= rd2;
							in1 <= PC;
							in2 <= $signed(i7); //if bigger or equal take result of alu1
							aluin1 <= PC;
							aluin2 <= 32'd1; //if not take result of alu2							
						end
					endcase
				end
				7'b1111110: //GLW
				begin
					rr1 <= s1;
					r1 <= rd1;
					r2 <= $signed(i12);
					wr <= de;
				end
				7'b1111111: //GSW
				begin
					rr1 <= s1;
					rr2 <= s2;
					r1 <= rd1;
					r2 <= $signed(i7);
					gdata <= rd2;
				end
				7'b1000000: //ask for lock
				begin
					need_lock <= 1'b1;
				end
				7'b0100000: //unlock
				begin
					need_lock <= 1'b0;
				end
			endcase
		end
		EXECUTE: begin
			case (opcode)
			7'b0110011: //OP
			begin
				case (funct3)
					3'b000: //ADD SUB
					begin
						if (funct7 == 7'b0000000)
						begin
							alu_control <= 8'd0;
						end
						else if (funct7 == 7'b0100000)
						begin
							alu_control <= 8'd1;
						end
						else
						begin
							alu_control <= 8'd10;
						end
					end
					3'b001: //SLL
					begin
						alu_control <= 8'd9;
					end
					3'b010: // SLT
					begin
						alu_control <= 8'd5;
					end
					3'b011: // SLTU
					begin
						alu_control <= 8'd6;
					end
					3'b100: // XOR
					begin
						alu_control <= 8'd4;
					end
					3'b101: // SRL or SRA
					begin
						if (funct7 == 7'b0000000) //SRL
						begin
							alu_control <= 8'd8;
						end
						else // SRA
							alu_control <= 8'd7;
					end
					3'b110: // OR
					begin
						alu_control <= 8'd3;
					end
					3'b111: // AND
					begin
						alu_control <= 8'd2;
					end
				endcase
			end
			7'b0010011: //OP-IMM
			begin
				case (funct3)
					3'b000: //ADDI
					begin
						alu_control <= 8'd0;
					end
					3'b001: //SLLI
					begin
						alu_control <= 8'd9;
					end
					3'b010: // SLTI
					begin
						alu_control <= 8'd5;
					end
					3'b011: // SLTIU
					begin
						alu_control <= 8'd6;
					end
					3'b100: // XORI
					begin
						alu_control <= 8'd4;
					end
					3'b101: // SRLI or SRAI
					begin
						if (i7 == 7'b0000000) //SRLI
						begin
							alu_control <= 8'd8;
						end
						else // SRAI
						begin
							alu_control <= 8'd7;
						end
					end
					3'b110: // ORI
					begin
						alu_control <= 8'd3;
					end
					3'b111: // ANDI
					begin
						alu_control <= 8'd2;
					end
				endcase
			end
			7'b0110111: //LUI
			begin
				alu_control <= 8'd11;
			end
			7'b0010111: //AUIPC
			begin
				alu_control <= 8'd12;
			end
			7'b0000011: //LW
			begin
				alu_control <= 8'd13;
				mem_lo <= result;
			end
			7'b0100011: //SW
			begin
				alu_control <= 8'd14;
				mem_lo <= result;
			end
			7'b1101111: //JAL
			begin
				alu_control <= 8'd0;
				aluc <= 8'd0;
			end
			7'b1100111: //JR, JALR
			begin
				if ((i12 == 12'd0) & (funct3 == 3'd0) & (de == 5'd0)) //JR
					alu_control <= 8'd0;
				else //JALR
				begin
					alu_control <= 8'd0;
					aluc <= 8'd0;
				end
			end
			7'b1100011: //BRANCH
			begin	
				case (funct3)
					3'b000: //BEQ
					begin
						alu_control <= 8'd18;
						aluc <= 8'd0;
						alucon <= 8'd0;
					end
					3'b001: //BNE
					begin
						alu_control <= 8'd19;
						aluc <= 8'd0;
						alucon <= 8'd0;								
					end
					3'b100: //BLT
					begin
						alu_control <= 8'd20;
						aluc <= 8'd0;
						alucon <= 8'd0;								
					end
					3'b101: //BGE
					begin
						alu_control <= 8'd21;
						aluc <= 8'd0;
						alucon <= 8'd0;								
					end
					3'b110: //BLTU
					begin
						alu_control <= 8'd22;
						aluc <= 8'd0;
						alucon <= 8'd0;								
					end
					3'b111: //BGEU
					begin
						alu_control <= 8'd23;
						aluc <= 8'd0;
						alucon <= 8'd0;								
					end
				endcase
			end
			7'b1111110: //GLW
			begin
				alu_control <= 8'd0;
				gaddress <= result;
			end
			7'b1111111: //GSW
			begin
				alu_control <= 8'd0;
				gaddress <= result;
			end
			endcase
			end
			WRITEREG: begin
				writewait<=writewait+3'd1;
				if(opcode == 7'b1100111) //jalr
				begin
					wd <= $signed(out);
					we <= 1'b1;
				end
				else
				begin
					we <= 1'b1;
					wd <= $signed(result);
				end
			end
			WRITEMEM: begin
				memwait <=memwait+3'd1;
				if(opcode == 7'b0000011) //lw
				begin
					if(core_num) 
						//wd <= mem_out_1;
						wd<=data_out;
					else
						wd<=data_out;
						//wd <= mem_out_0;
					we <= 1'b1;
				end
				else if(opcode == 7'b0100011) //sw
				begin
					mem_en <= 1'b1;
				end
				else if(opcode == 7'b1111110) //GLW
				begin
					wd <= gq;
					we <= 1'b1;
				end
				else if(opcode == 7'b1111111) //GSW
				begin
					gwren <= 1'b1;
				end
			end
			WRITEBACK:
			begin
				case (opcode)
					7'b1101111: //JAL
					begin
						PC <= PC+(jal_offset/4);
					end
					7'b1100111:	
					begin
						if((i12 == 12'd0) & (funct3 == 3'd0) & (de == 5'd0)) //JR
							PC <= rd1;
						else //JALR
							PC <= result;
					end
					7'b1100011: //branch
					begin
						case (funct3)
							3'b000: //BEQ
							begin
								if(result[0]) //if equal take result from alu1
									PC <= PC+(immediate/4);
								else //if not increment like normal
									PC <= aluout;
							end
							3'b001: //BNE
							begin
								if(result[0]) //if NOT equal take result from alu1
									PC <= PC+(immediate/4);
								else //else take result from alu2
									PC <= aluout;
							end
							3'b100: //BLT
							begin
								if(result[0]) //if less take result from alu1
									PC <= PC+(immediate/4);
								else //if not increment like normal
									PC <= aluout;
							end
							3'b101: //BGE
							begin
								if(result[0]) //if bigger or equal take reault from alu1
									PC <= PC+(immediate/4);
								else //if not take result from alu2
									PC <= PC+aluout;
							end
							3'b110: //BLTU
							begin
								if(result[0]) //if less take result from alu1
									PC <= PC+(immediate/4);
								else //if not increment like normal
									PC <= aluout;
							end
							3'b111: //BGEU
							begin
								if(result[0]) //if bigger or equal take reault from alu1
									PC <= PC+(immediate/4);
								else //if not take result from alu2
									PC <= aluout;
							end
						endcase
					end
					default: PC <= PC + 8'd1; 
				endcase
				mem_en <= 1'b0;
				gwren <= 1'b0;
				double <= 1'd0;
				we <= 1'b0;
			end
			DONE:
			begin
				done <= 1'b1;
				instruction <= 32'd0;
			end
		endcase
	end
end
endmodule
