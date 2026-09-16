`timescale 1ns/1ps
`include "HazardDetectionUnit.v"

module HazardDetectionUnit_tb;
    reg clk, MemRead2;
    reg [4:0] Rs1, Rt1, Rt2;
    wire [2:0] stall;
    integer errors;

    HazardDetectionUnit dut(stall, Rs1, Rt1, Rt2, MemRead2, clk);

    task check;
        input read_enable;
        input [4:0] rs;
        input [4:0] rt;
        input [4:0] load_dest;
        input [2:0] expected;
        begin
            MemRead2 = read_enable; Rs1 = rs; Rt1 = rt; Rt2 = load_dest;
            #1 clk = 1'b0; #1;
            if (stall !== expected) begin
                $display("FAIL: MemRead=%b Rs=%0d Rt=%0d loadRt=%0d stall=%b; expected=%b", MemRead2, Rs1, Rt1, Rt2, stall, expected);
                errors = errors + 1;
            end
            #1 clk = 1'b1;
        end
    endtask

    initial begin
        clk = 1; MemRead2 = 0; Rs1 = 0; Rt1 = 0; Rt2 = 0; errors = 0;
        check(1'b1, 5'd8, 5'd3, 5'd8, 3'b000);
        check(1'b1, 5'd8, 5'd3, 5'd3, 3'b000);
        check(1'b1, 5'd8, 5'd3, 5'd4, 3'b111);
        check(1'b0, 5'd8, 5'd3, 5'd8, 3'b111);
        if (errors == 0) $display("HazardDetectionUnit_tb PASS"); else $display("HazardDetectionUnit_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
