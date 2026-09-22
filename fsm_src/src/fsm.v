`timescale 1ns/1ns

module fsm(
    input  wire clk,
    input  wire reset,
    input  wire in,
    output wire out
);

    // states
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;
    parameter S5 = 3'b101;
    parameter S6 = 3'b110;
    parameter S7 = 3'b111;

    reg [2:0] curr_state;
    reg [2:0] next_state;

    /* write code here */
    // stage 1: reset or next state (curr_state <= next_state)

    // stage 2: next state (next_state = case ...)

    // stage 3: output (out depends on curr_state only)

    always @(posedge clk or negedge reset) begin
        if (!reset)
            curr_state <= S0;
        else
            curr_state <= next_state;
    end

    always @(*) begin
        case (curr_state)
            S0: next_state = in ? S1 : S0;
            S1: next_state = in ? S2 : S0;
            S2: next_state = in ? S3 : S0;
            S3: next_state = in ? S3 : S4;
            S4: next_state = in ? S1 : S5;
            S5: next_state = in ? S6 : S1;
            S6: next_state = in ? S2 : S7;
            S7: next_state = in ? S1 : S0;  
            default: next_state = S0;
        endcase
    end

    assign out = (curr_state == S7);

endmodule
