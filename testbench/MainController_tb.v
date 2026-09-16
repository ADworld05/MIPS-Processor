`timescale 1ns/1ps
`include "MainController.v"

module MainController_tb;
    reg [5:0] Op;
    wire RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump;
    wire [1:0] ALUOp;
    integer errors;

    MainControlUnit dut(RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump, ALUOp, Op);

    task check;
        input [5:0] opcode;
        input [9:0] expected;
        begin
            Op = opcode; #1;
            if ({RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump, ALUOp} !== expected) begin
                $display("FAIL: opcode=%h controls=%b; expected=%b", Op, {RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jump, ALUOp}, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        check(6'h00, 10'b1001000010); // R-type
        check(6'h23, 10'b0111100000); // lw
        check(6'h2B, 10'b0100010000); // sw
        check(6'h04, 10'b0000001001); // beq
        check(6'h02, 10'b0000000100); // jump
        check(6'h08, 10'b0000000000); // unsupported opcode
        if (errors == 0) $display("MainController_tb PASS"); else $display("MainController_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
