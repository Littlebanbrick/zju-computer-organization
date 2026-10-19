`timescale 1ns / 1ps

module mux2t1_5(
    input  wire [4:0] I0,
    input  wire [4:0] I1,
    input  wire       s,
    output wire [4:0] o
);
    /* write code here */
    assign o = s ? I1 : I0;
endmodule

module mux4t1_5(
    input  wire [4:0] I0,
    input  wire [4:0] I1,
    input  wire [4:0] I2,
    input  wire [4:0] I3,
    input  wire [1:0] s,
    output reg  [4:0] o
);
    /* write code here */
    always @(*) begin
        if(s == 2'b00)  begin
            o = I0;
        end
        else if(s == 2'b01) begin
            o = I1;
        end
        else if(s == 2'b10) begin
            o = I2;
        end
        else begin
            o = I3;
        end
    end
endmodule

module mux8t1_8(
    input  wire [7:0] I0,
    input  wire [7:0] I1,
    input  wire [7:0] I2,
    input  wire [7:0] I3,
    input  wire [7:0] I4,
    input  wire [7:0] I5,
    input  wire [7:0] I6,
    input  wire [7:0] I7,
    input  wire [2:0] s,
    output reg  [7:0] o
);
    /* write code here */
    always @(*) begin
        if(s == 3'b000)  begin
            o = I0;
        end
        else if(s == 3'b001) begin
            o = I1;
        end
        else if(s == 3'b010) begin
            o = I2;
        end
        else if(s == 3'b011) begin
            o = I3;
        end
        else if(s == 3'b100) begin
            o = I4;
        end
        else if(s == 3'b101) begin
            o = I5;
        end
        else if(s == 3'b110) begin
            o = I6;
        end
        else begin
            o = I7;
        end
    end
endmodule
