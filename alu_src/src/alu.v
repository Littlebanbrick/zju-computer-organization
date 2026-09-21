`timescale 1ns / 1ps

// 操作码	运算	功能说明
// 000	AND	按位与：A & B
// 001	OR	按位或：A | B
// 010	ADD	加法，输出低 32 位结果
// 011	XOR	按位异或：A ^ B
// 100	NOR	按位或非：~(A | B)
// 101	SRL	逻辑右移，移位量仅取 B[4:0]
// 110	SUB	减法，输出低 32 位结果
// 111	SLT	有符号比较，A < B 时输出 32 位的 1，否则输出 0

module ALU(
    input  [31:0] A,
    input  [2:0]  ALU_operation,
    input  [31:0] B,
    output reg [31:0] res,
    output            zero
);
    wire [31:0] and_res;
    wire [31:0] or_res;
    wire [31:0] xor_res;
    wire [31:0] nor_res;
    wire [31:0] srl_res;
    wire [31:0] add_sub_res;
    wire compare_res;

    /* write code here */
    assign and_res =
        A & B;

    assign or_res  =
        A | B;

    assign xor_res =
        A ^ B;

    assign nor_res =
        ~(A | B);

    assign srl_res =
        A >> B[4:0];

    assign add_sub_res =
        (ALU_operation[2] == 1) ? (A + ~B + 1) : (A + B);

    assign compare_res =
        ($signed(A) < $signed(B)) ? 1'b1 : 1'b0;

    always @(*) begin
        case (ALU_operation)
            3'b000: res = and_res;     // AND
            3'b001: res = or_res;      // OR
            3'b010: res = add_sub_res; // ADD
            3'b011: res = xor_res;     // XOR
            3'b100: res = nor_res;     // NOR
            3'b101: res = srl_res;     // SRL (Shift Right)
            3'b110: res = add_sub_res; // SUB
            3'b111: res = compare_res; // SLT (signed a < signed b ?)
            default: res = 32'b0;
        endcase
    end

    /* write code here */
    assign zero =
        (res == 32'b0) ? (1'b1) : (1'b0);

endmodule