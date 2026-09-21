`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/25 13:14:16
// Design Name: 
// Module Name: Water_LED
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Water_LED(
   input CLK_i,
   input RSTn_i,
   output reg [15:0]LED_o
    );
   reg [31:0]C0;
   reg dir;
    
 always @(posedge CLK_i) 
    if(!RSTn_i) begin
      LED_o <= 16'b1;
      C0 <= 32'h0;
      dir <= 1'b0;
    end
    else begin
        if(C0 == 32'd5_000_000) begin
          C0 <= 32'h0;
          if(dir == 1'b0) begin
              if(LED_o == 16'b1000_0000_0000_0000) begin
                  dir <= 1'b1;
                  LED_o <= LED_o >> 1;
              end
              else
                  LED_o <= LED_o << 1;
          end
          else begin
              if(LED_o == 16'b0000_0000_0000_0001) begin
                  dir <= 1'b0;
                  LED_o <= LED_o << 1;
              end
              else
                  LED_o <= LED_o >> 1;
          end
        end
        else  begin 
          C0 <= C0 + 1'b1; 
          LED_o <= LED_o; 
        end
     end

endmodule
