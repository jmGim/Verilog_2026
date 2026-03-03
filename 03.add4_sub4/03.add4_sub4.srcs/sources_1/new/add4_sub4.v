`timescale 1ns / 1ps

// 4bit + 4bit => carry, 4bit sum
module add4_sub4(
        input [7:0] sw,
        input sel,    // 1 :add / 0 : sub(스위치 내리면)
        output carry_out,
        output [3:0] sum
    );


    // assign {carry_out, sum[3:0] } = sw[3:0] + sw[7:4];
    assign {carry_out, sum[3:0] } = sel ? sw[3:0] + sw[7:4] : 
                                        sw[3:0] + ~sw[7:4] + 4'b1;
    

endmodule
