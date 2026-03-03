`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/02/10 13:50:07
// Design Name: 
// Module Name: tb_gatetest
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

`timescale 1ns / 1ps
module tb_gatetest();  
    reg i_a;  // a는 FF 1bit 저장공간 memory 임/.       // testbench에서는 wire를 쓸 수 가 없음.
    reg i_b;  
            // 아무런 언급 없으면 1bit 로 인식.

    wire [4:0] o_led; // led[0]~led[4]  조합회로임 : 메모리 없음 <-> 순차회로 

    // named port mapping 방식
    tb_gatetest u_gatetest(  // u_gatetest : Instancation 인스턴스화 / DUT Design Under Test : 테스트 하고자 하는 모델 가져옴.
        .a(i_a),
        .b(i_b),  
        .led(o_led)      
    );
    // a b
    // 0 0
    // 0 1
    // 1 0
    // 1 1

    initial begin
        #00 i_a=1'b0; i_b=1'b0;
        #20 i_a=1'b0; i_b=1'b1;
        #20 i_a=1'b1; i_b=1'b0;
        #20 i_a=1'b1; i_b=1'b1; 
        #20 $finish;
    end

endmodule
