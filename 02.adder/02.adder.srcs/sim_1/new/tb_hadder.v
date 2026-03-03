`timescale 1ns / 1ps

module tb_hadder();

    reg i_a, i_b;
    wire o_sum, o_carry_out;

    hadder u_hadder(
        .a(i_a),
        .b(i_b),
        .sum(o_sum),
        .carry_out(o_carry_out)
    );

    initial begin
        #00 i_a = 1'b0; i_b = 1'b0;
        #10 i_a = 1'b0; i_b = 1'b1;
        #10 i_a = 1'b1; i_b = 1'b0;
        #10 i_a = 1'b1; i_b = 1'b1;
        #10 $finish;
    end

endmodule
