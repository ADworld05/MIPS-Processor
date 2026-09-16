`timescale 1ns/1ps
`include "RegFile32.v"

module RegFile32_tb;
    reg clk, reset, RegWrite;
    reg [31:0] WriteData;
    reg [4:0] WriteReg, ReadReg1, ReadReg2;
    wire [31:0] ReadData1, ReadData2;
    integer errors;

    RegFile32 dut(clk, reset, ReadReg1, ReadReg2, WriteData, WriteReg, RegWrite, ReadData1, ReadData2);

    always #5 clk = ~clk;

    task write_register;
        input [4:0] reg_number;
        input [31:0] value;
        begin
            WriteReg = reg_number; WriteData = value; RegWrite = 1'b1;
            @(negedge clk); #1;
        end
    endtask

    task check_reads;
        input [4:0] reg1;
        input [31:0] expected1;
        input [4:0] reg2;
        input [31:0] expected2;
        begin
            ReadReg1 = reg1; ReadReg2 = reg2; #1;
            if (ReadData1 !== expected1 || ReadData2 !== expected2) begin
                $display("FAIL: read r%0d=%h r%0d=%h; expected %h %h", reg1, ReadData1, reg2, ReadData2, expected1, expected2);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 1'b1; reset = 1'b1; RegWrite = 1'b0; WriteData = 0; WriteReg = 0; ReadReg1 = 0; ReadReg2 = 0; errors = 0;
        #1 reset = 1'b0; #1 reset = 1'b1;
        check_reads(5'd0, 32'd0, 5'd31, 32'd0);
        write_register(5'd2, 32'h1234_5678);
        write_register(5'd17, 32'hCAFE_BABE);
        check_reads(5'd2, 32'h1234_5678, 5'd17, 32'hCAFE_BABE);
        RegWrite = 1'b0; WriteReg = 5'd2; WriteData = 32'hDEAD_BEEF; @(negedge clk); #1;
        check_reads(5'd2, 32'h1234_5678, 5'd17, 32'hCAFE_BABE);
        if (errors == 0) $display("RegFile32_tb PASS"); else $display("RegFile32_tb FAIL: %0d errors", errors);
        $finish;
    end
endmodule
