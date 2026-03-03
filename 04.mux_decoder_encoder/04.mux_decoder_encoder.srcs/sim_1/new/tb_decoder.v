`timescale 1ns / 1ps


module tb_decoder();

      // 1. 입력 reg , 출력 wire
    reg [1:0] r_a; 
    wire [3:0] w_led;

    
    // 2. 검증할 모듈을 인스턴스화 함.
    decoder u_decoder(
        .a(r_a), 
        .led(w_led) 
    );

    // 3. test scenario 작성
    initial begin
       // 초기값 설정 
       r_a = 2'b00;
        // 결과 콘솔 출력
      $monitor("Time %0t r_a=%h, w_out=%h", $time, r_a, w_led); 

       // sel == 1 : a 출력
       
       #10; r_a=2'b00; 
       #10; r_a=2'b01;   
       #10; r_a=2'b10;   
       #10; r_a=2'b11;  
       #10; $finish;

    end

endmodule
