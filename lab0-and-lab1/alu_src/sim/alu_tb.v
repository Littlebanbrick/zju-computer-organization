`timescale 1ns / 1ps

module ALU_tb;
    reg [31:0] A, B;
    reg [2:0] ALU_operation;
    wire [31:0] res;
    wire zero;

    ALU ALU_u(
        .A(A),
        .B(B),
        .ALU_operation(ALU_operation),
        .res(res),
        .zero(zero)
    );

    initial begin
        A = 32'hCAFEBABE;
        B = 32'hDEADBEEF;
        ALU_operation = 3'b000; // AND: CAACBAAE
        #10;
        ALU_operation = 3'b001; // OR : DEFFBEFF
        #10;
        ALU_operation = 3'b010; // ADD: A9AC79AD
        #10;
        ALU_operation = 3'b011; // XOR: 14530451
        #10;
        ALU_operation = 3'b100; // NOR: 21004100
        #10;
        ALU_operation = 3'b101; // SRL: 000195FD
        #10;
        ALU_operation = 3'b110; // SUB: EC50FBCF
        #10;
        ALU_operation = 3'b111; // SLT: 1
        #10;
        A = 32'h00000000;
        B = 32'h00000001;
        ALU_operation = 3'b111; // 1
        #10
        A = 32'h80000001;
        B = 32'h00000000;
        ALU_operation = 3'b111; // 1
        #10
        A = 32'h76543210;
        B = 32'h01234567;
        ALU_operation = 3'b111; // 0
        #10
        A = 32'hFEDCBA98;
        B = 32'h89ABCDEF;
        ALU_operation = 3'b111; // 0
        #10
        A = 32'hFACEFACE;
        B = 32'hFACEFACE;
        ALU_operation = 3'b110; // 0, zero = 1
        #10
        $finish;
    end
endmodule