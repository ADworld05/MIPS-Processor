`timescale 1ns/1ps
`include "InstructionMemory32.v"
`include "RegFile32.v"
`include "MainController.v"
`include "ALUController.v"
`include "ALU.v"

// Program at address 0: add $t2, $t0, $t1
// Machine code: 0x01095020
module MIPS_AddProgram_tb;
    reg clk, reset, loading_registers;
    reg [31:0] pc, setup_data;
    reg [4:0] setup_register;
    wire [31:0] instruction, read_data1, read_data2, alu_result;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump, alu_carry;
    wire [1:0] ALUOp;
    wire [2:0] ALUOperation;
    wire [4:0] write_register;
    wire [31:0] write_data;
    wire register_write;
    integer errors;

    InstructionMemory32 imem(instruction, pc, clk);
    MainControlUnit control(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump, ALUOp, instruction[31:26]);
    ALUControlUnit alu_control(ALUOperation, instruction[5:0], ALUOp);
    ALU execute(read_data1, read_data2, ALUOperation[2], ALUOperation[1], ALUOperation[1:0], alu_result, alu_carry);

    assign write_register = loading_registers ? setup_register : instruction[15:11];
    assign write_data = loading_registers ? setup_data : alu_result;
    assign register_write = loading_registers ? 1'b1 : RegWrite;
    RegFile32 registers(clk, reset, instruction[25:21], instruction[20:16], write_data,
                        write_register, register_write, read_data1, read_data2);

    always #5 clk = ~clk;

    task load_register;
        input [4:0] register_number;
        input [31:0] value;
        begin
            setup_register = register_number;
            setup_data = value;
            @(negedge clk); #1;
        end
    endtask

    initial begin
        clk = 1'b1; reset = 1'b1; pc = 0; loading_registers = 1'b1;
        setup_register = 0; setup_data = 0; errors = 0;
        imem.memory[0] = 32'h0109_5020; // add $t2, $t0, $t1

        #1 reset = 1'b0; #1 reset = 1'b1;
        load_register(5'd8, 32'd12);  // $t0 = 12
        load_register(5'd9, 32'd30);  // $t1 = 30

        loading_registers = 1'b0;
        @(posedge clk); #1;           // fetch and decode the add instruction
        if (instruction !== 32'h0109_5020 || read_data1 !== 32'd12 || read_data2 !== 32'd30) begin
            $display("FAIL: instruction fetch or register reads are incorrect");
            errors = errors + 1;
        end
        @(negedge clk); #1;           // write ALU result into $t2

        if (registers.q[10] !== 32'd42) begin
            $display("FAIL: $t2=%d; expected 42", registers.q[10]);
            errors = errors + 1;
        end
        if (errors == 0) $display("MIPS_AddProgram_tb PASS: 12 + 30 = 42 in $t2");
        else $display("MIPS_AddProgram_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
