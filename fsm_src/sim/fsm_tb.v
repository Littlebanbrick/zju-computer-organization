`timescale 1ns / 1ps

module tb_fsm();
    reg clk;
    reg reset;
    reg in;
    wire out;

    always #10 clk = ~clk;

    initial begin
        $dumpfile("a.vcd");
        $dumpvars(0, tb_fsm);
    end

    initial begin
        clk = 0;
        reset = 0;
        #20 reset = 1;

        //1110010011110010
        in = 1; #20;
        in = 1; #20;
        in = 1; #20;
        in = 0; #20;
        in = 0; #20;
        in = 1; #20;
        in = 0; #20;
        in = 0; #20;
        in = 1; #20;
        in = 1; #20;
        in = 1; #20;
        in = 1; #20;
        in = 0; #20;
        in = 0; #20;
        in = 1; #20;
        in = 0; #20;
        $finish;
    end

    fsm seq_u1(
        .clk(clk),
        .reset(reset),
        .in(in),
        .out(out)
    );
endmodule
