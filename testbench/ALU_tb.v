`timescale 1ns/1ps
`include "ALU.v"

module ALU_tb;
    reg [31:0] in1, in2;
    reg Binvert, Cin;
    reg [1:0] Operation;
    wire [31:0] Result;
    wire Carry;
    integer errors;

    ALU dut(in1, in2, Binvert, Cin, Operation, Result, Carry);

    task check;
        input [31:0] expected_result;
        input expected_carry;
        begin
            #1;
            if (Result !== expected_result || Carry !== expected_carry) begin
                $display("FAIL: result=%h carry=%b; expected result=%h carry=%b", Result, Carry, expected_result, expected_carry);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        in1 = 32'hF0F0_AA55; in2 = 32'h0FF0_0F0F; Binvert = 0; Cin = 0; Operation = 2'b00; check(32'h00F0_0A05, 1'b0);
        Operation = 2'b01; check(32'hFFF0_AF5F, 1'b0);
        in1 = 32'h0000_0003; in2 = 32'h0000_0005; Binvert = 0; Cin = 0; Operation = 2'b10; check(32'h0000_0008, 1'b0);
        in1 = 32'hFFFF_FFFF; in2 = 32'h0000_0001; check(32'h0000_0000, 1'b1);
        in1 = 32'h0000_0009; in2 = 32'h0000_0004; Binvert = 1; Cin = 1; Operation = 2'b10; check(32'h0000_0005, 1'b1);
        if (errors == 0) $display("ALU_tb PASS"); else $display("ALU_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
