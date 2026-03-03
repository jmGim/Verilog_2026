`timescale 1ns / 1ps


module gatetest(
    input wire a,
    input b,  //  wire 생략 : default wire임
            // 아무런 언급 없으면 1bit 로 인식.

    output [4:0] led // led[0]~led[4]  조합회로임 : 메모리 없음 <-> 순차회로 
        
    );

    assign led[0] = a & b;  // assign(연결하라) 은 연속할당문
    assign led[1] = a | b;  // 
    assign led[2] = ~(a & b);
    assign led[3] = ~(a | b);
    assign led[4] = a ^ b; // xor
     
endmodule
