`timescale 1ns / 1ps

//1010111
module shift_register(
    input clk,  
    input reset,   // SW15
    input btnU,   // 1을 입력
    input btnD,   // 0을 입력
    output [6:0] led
    );


    //
    // 1. btnU누르면 1 / btnD누르면 0으로 동작

    reg [6:0] sr7 = 7'b0000000;

    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            // out <= 1'b0;
            sr7 <= 7'b0000000;
        end else begin
             if (btnU) sr7 <= { sr7[6:0], 1'b1};  // shift register  
             else if (btnD) sr7 <= { sr7[6:0], 1'b0};  // shift register  
        end

    end

    assign led[6:0] = sr7[6:0];


endmodule
