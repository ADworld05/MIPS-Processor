`timescale 1ns/1ps
`include "DataMemory32.v"

module DataMemory32_tb;
    reg clk, MemRead, MemWrite;
    reg [31:0] ReadAddress, WriteAddress, WriteData;
    wire [31:0] ReadData;
    integer errors;

    DataMemory32 dut(clk, MemRead, ReadAddress, ReadData, MemWrite, WriteAddress, WriteData);

    task clock_pulse;
        begin
            #1 clk = 1'b1; #1 clk = 1'b0; #1;
        end
    endtask

    task check_read;
        input [31:0] address;
        input [31:0] expected;
        begin
            MemWrite = 1'b0; MemRead = 1'b1; ReadAddress = address; clock_pulse;
            if (ReadData !== expected) begin
                $display("FAIL: read address=%h data=%h; expected=%h", address, ReadData, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0; MemRead = 0; MemWrite = 0; ReadAddress = 0; WriteAddress = 0; WriteData = 0; errors = 0;
        check_read(32'd0, 32'd0);
        MemRead = 0; MemWrite = 1; WriteAddress = 32'd8; WriteData = 32'hDEAD_BEEF; clock_pulse;
        MemWrite = 1; WriteAddress = 32'd124; WriteData = 32'hCAFE_BABE; clock_pulse;
        check_read(32'd8, 32'hDEAD_BEEF);
        check_read(32'd124, 32'hCAFE_BABE);
        if (errors == 0) $display("DataMemory32_tb PASS"); else $display("DataMemory32_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
