`timescale 1ns / 1ps

module Regs_tb;

    reg clk;
    reg rst;
    reg [4:0] Rs1_addr;
    reg [4:0] Rs2_addr;
    reg [4:0] Wt_addr;
    reg [31:0] Wt_data;
    reg RegWrite;
    wire [31:0] Rs1_data;
    wire [31:0] Rs2_data;

    Regs Regs_U(
        .clk(clk),
        .rst(rst),
        .Rs1_addr(Rs1_addr),
        .Rs2_addr(Rs2_addr),
        .Wt_addr(Wt_addr),
        .Wt_data(Wt_data),
        .RegWrite(RegWrite),
        .Rs1_data(Rs1_data),
        .Rs2_data(Rs2_data)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        RegWrite = 0;
        Wt_data = 0;
        Wt_addr = 0;
        Rs1_addr = 0;
        Rs2_addr = 0;
        #100
        rst = 0;
        RegWrite = 1;
        Wt_addr = 5'b00101; // write A5A5A5A5 to x5
        Wt_data = 32'ha5a5a5a5;
        #50
        Wt_addr = 5'b01010; // write 5A5A5A5A to x10
        Wt_data = 32'h5a5a5a5a;
        #50
        RegWrite = 0;
        Rs1_addr = 5'b00101; // read x5 and x10
        Rs2_addr = 5'b01010;
        #50

        RegWrite = 1;
        Wt_addr = 5'b0;     // invalid writing for x0
        Wt_data = 32'h91789178;
        #50
        RegWrite = 0;
        Rs1_addr = 5'b0;    // read 0 for x0
        #50

        rst = 1;
        #50
        rst = 0;
        Rs1_addr = 5'b0;
        // from x0 to x31, should all be 0
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10
        Rs1_addr = Rs1_addr + 1;
        #10

        $finish();
    end

endmodule
