`timescale 1ns / 1ps

module mux2t1_tb;

    // Inputs
    reg  [4:0] I0;
    reg  [4:0] I1;
    reg        s;

    // Output
    wire [4:0] o;

    // Instantiate the Unit Under Test (UUT)
    mux2t1_5 uut (
        .I0(I0),
        .I1(I1),
        .s (s),
        .o (o)
    );

    initial begin
        /* write code here */
        I0 = 5'b00000;  I1 = 5'b11111;  s = 1'b0;
        #10;
        s = 1'b1;
        #10;
        $finish;
    end

endmodule
