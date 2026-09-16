`timescale 1ns/1ps
`include "ALUController.v"

module ALUController_tb;
    reg [5:0] FuncField;
    reg [1:0] ALUOp;
    wire [2:0] Operation;
    integer errors;

    ALUControlUnit dut(Operation, FuncField, ALUOp);

    task check;
        input [1:0] op_in;
        input [5:0] funct_in;
        input [2:0] expected;
        begin
            ALUOp = op_in; FuncField = funct_in; #1;
            if (Operation !== expected) begin
                $display("FAIL: ALUOp=%b funct=%h operation=%b; expected=%b", ALUOp, FuncField, Operation, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        check(2'b00, 6'h00, 3'b010); // lw/sw: add
        check(2'b01, 6'h00, 3'b110); // beq: subtract
        check(2'b10, 6'h20, 3'b010); // add
        check(2'b10, 6'h22, 3'b110); // subtract
        check(2'b10, 6'h24, 3'b000); // and
        check(2'b10, 6'h25, 3'b001); // or
        if (errors == 0) $display("ALUController_tb PASS"); else $display("ALUController_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
