`timescale 1ns/1ps
`include "InstructionMemory32.v"
`include "DataMemory32.v"
`include "HazardDetectionUnit.v"

// Program:
//   lw  $t0, 0($zero)       // 0x8C080000
//   add $t1, $t0, $t0       // 0x01084820
module MIPS_LoadUseHazard_tb;
    reg clk, MemRead2, MemRead, MemWrite;
    reg [31:0] pc, ReadAddress, WriteAddress, WriteData;
    reg [4:0] Rs1, Rt1, Rt2;
    reg [31:0] load_instruction;
    wire [31:0] instruction, ReadData;
    wire [2:0] stall;
    integer errors;

    InstructionMemory32 imem(instruction, pc, clk);
    DataMemory32 dmem(clk, MemRead, ReadAddress, ReadData, MemWrite, WriteAddress, WriteData);
    HazardDetectionUnit hazard(stall, Rs1, Rt1, Rt2, MemRead2, clk);

    initial begin
        clk = 1'b0; pc = 0; MemRead = 0; MemWrite = 0; ReadAddress = 0;
        WriteAddress = 0; WriteData = 0; MemRead2 = 0; Rs1 = 0; Rt1 = 0; Rt2 = 0; errors = 0;
        imem.memory[0] = 32'h8C08_0000; // lw $t0, 0($zero)
        imem.memory[1] = 32'h0108_4820; // add $t1, $t0, $t0
        dmem.data[0] = 32'd21;

        #1 clk = 1'b1; #1;             // fetch lw
        load_instruction = instruction;
        MemRead = 1'b1; ReadAddress = 0;
        #1 clk = 1'b0; #1;
        #1 clk = 1'b1; #1;             // rising edge reads memory for lw
        if (ReadData !== 32'd21) begin
            $display("FAIL: load did not read 21 from memory");
            errors = errors + 1;
        end

        pc = 32'd4;
        #1 clk = 1'b0; #1;
        #1 clk = 1'b1; #1;             // fetch dependent add
        Rs1 = instruction[25:21];
        Rt1 = instruction[20:16];
        Rt2 = load_instruction[20:16];
        MemRead2 = (load_instruction[31:26] == 6'h23);
        #1 clk = 1'b0; #1;             // hazard unit evaluates on falling edge

        if (stall !== 3'b000) begin
            $display("FAIL: expected load-use stall, got %b", stall);
            errors = errors + 1;
        end
        if (Rs1 !== 5'd8 || Rt1 !== 5'd8 || Rt2 !== 5'd8) begin
            $display("FAIL: instruction register fields were decoded incorrectly");
            errors = errors + 1;
        end
        if (errors == 0) $display("MIPS_LoadUseHazard_tb PASS: lw-to-add dependency correctly stalls");
        else $display("MIPS_LoadUseHazard_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
