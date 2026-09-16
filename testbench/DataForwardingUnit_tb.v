`timescale 1ns/1ps
`include "DataForwardingUnit.v"

module DataForwardingUnit_tb;
    reg clk, RegWrite3, RegWrite4;
    reg [4:0] Rs2, Rt2, destreg3, destreg4;
    wire [1:0] forwardA, forwardB;
    integer errors;

    DataForwardingUnit dut(forwardA, forwardB, Rs2, Rt2, destreg3, destreg4, RegWrite3, RegWrite4, clk);

    task check;
        input [4:0] rs;
        input [4:0] rt;
        input [4:0] ex_dest;
        input [4:0] wb_dest;
        input ex_write;
        input wb_write;
        input [1:0] expected_a;
        input [1:0] expected_b;
        begin
            Rs2 = rs; Rt2 = rt; destreg3 = ex_dest; destreg4 = wb_dest; RegWrite3 = ex_write; RegWrite4 = wb_write;
            #1 clk = 1'b0; #1;
            if (forwardA !== expected_a || forwardB !== expected_b) begin
                $display("FAIL: forwardA=%b forwardB=%b; expected A=%b B=%b", forwardA, forwardB, expected_a, expected_b);
                errors = errors + 1;
            end
            #1 clk = 1'b1;
        end
    endtask

    initial begin
        clk = 1; RegWrite3 = 0; RegWrite4 = 0; Rs2 = 0; Rt2 = 0; destreg3 = 0; destreg4 = 0; errors = 0;
        check(5'd5, 5'd9, 5'd5, 5'd9, 1'b1, 1'b1, 2'b10, 2'b01);
        check(5'd5, 5'd9, 5'd7, 5'd5, 1'b1, 1'b1, 2'b01, 2'b00);
        check(5'd5, 5'd9, 5'd5, 5'd5, 1'b1, 1'b1, 2'b10, 2'b00);
        check(5'd5, 5'd9, 5'd5, 5'd5, 1'b0, 1'b1, 2'b01, 2'b00);
        check(5'd5, 5'd9, 5'd0, 5'd9, 1'b1, 1'b1, 2'b00, 2'b01);
        check(5'd5, 5'd9, 5'd5, 5'd9, 1'b0, 1'b0, 2'b00, 2'b00);
        if (errors == 0) $display("DataForwardingUnit_tb PASS"); else $display("DataForwardingUnit_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
