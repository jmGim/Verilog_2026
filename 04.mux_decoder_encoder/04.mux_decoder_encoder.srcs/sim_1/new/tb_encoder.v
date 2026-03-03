`timescale 1ns / 1ps


module tb_encoder();

    reg [3:0] r_d;
    wire [1:0] w_a;

    encoder u_encoder(
        .d(r_d), 
        .a(w_a) 
    );

    // 3. test scenario 작성
    initial begin
       // 초기값 설정 
       r_d = 4'b0000;
        // 결과 콘솔 출력
      $monitor("Time %0t r_a=%h, w_out=%h", $time, r_d, w_a); 

       // sel == 1 : a 출력
       
       #10; r_d=4'b0001; 
       #10; r_d=4'b0010;   
       #10; r_d=4'b0100;   
       #10; r_d=4'b1000;  
       #10; $finish;

    end

endmodule
