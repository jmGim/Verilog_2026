`timescale 1ns / 1ps



module tb_8adder();  // 시물레이션에서 입출력은 없다.
    reg [7:0] a;  // 시물레이션에서 입력은 reg
    reg [7:0] b; 
    reg cin;  // 1bit
    wire [7:0] sum;  // 시물레이션에서 출력은 wire로 선언
    wire carry_out;
    
    full_adder dut  (
        .a(a),
        .b(b),
        .cin(cin),   // 1bit
        .sum(sum),
        .carry_out(carry_out) 
    ); 
    
    initial begin
        #00 a=0; b=0; cin=0;
        #10 a=1; b=2;
        #10 a=126; b=127;
        #10 a=100; b=100;
        #10 a=63; b=64;
        for (integer i=0; i < 255; i = i+1) begin
            #10 a=i;
            
        end
        #10 $finish;
    end
    
endmodule
