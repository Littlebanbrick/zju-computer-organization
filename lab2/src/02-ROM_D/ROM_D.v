`timescale 1ns / 1ps

module ROM_D #(
    parameter AW = 10, // 1024 words
    parameter DW = 32  // 1 word = 32bits (RV-32)
)(
    input  wire [AW-1:0] a,  // read addr
    output wire [DW-1:0] spo // out data
);

    reg [DW-1:0] rom [0:(1<<AW)-1];

    integer i;
    initial begin
        for (i = 0; i < (1<<AW); i = i + 1)
            rom[i] = {DW{1'b0}};

        $readmemh("I_mem.mem", rom);
    end

    assign spo = rom[a];

endmodule
