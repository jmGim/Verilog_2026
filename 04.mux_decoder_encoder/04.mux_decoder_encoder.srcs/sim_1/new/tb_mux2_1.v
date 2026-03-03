// `timescale 1ns / 1ps


// module tb_mux2_1();

//     // 1. 입력 reg , 출력 wire
//     reg r_a; 
//     reg r_b;
//     reg r_sel;
//     wire w_out;

    
//     // 2. 검증할 모듈을 인스턴스화 함.
//     mux2_1 u_mux2_1(
//         .a(r_a), 
//         .b(r_b), 
//         .sel(r_sel),
//         .out(w_out) 
//     );

//     // 3. test scenario 작성
//     initial begin
//        // 초기값 설정 
//        r_a = 0; r_b = 0 ; r_sel = 0;
//         // 결과 콘솔 출력
//         $monitor("Time %0t r_a=%b, r_b=%b w_out=%b", $time, r_sel, r_a, r_b, w_out); 

//        // sel == 1 : a 출력
//        // sel == 0 : b 출력
//        #10; r_sel = 1; r_a=1; r_b=0;  // w_out = 1
//        #10; r_sel = 0; r_a=1; r_b=0;  // w_out = 0

//        #10; r_sel = 1; r_a=0; r_b=1;  // w_out = 0
//        #10; r_sel = 0; r_a=0; r_b=1;  // w_out = 1
//        #10; $finish;

//     end

// endmodule











// module tb_mux2_1();

//     // 1. 입력 reg , 출력 wire
//     reg [3:0] r_a; 
//     reg [3:0] r_b;
//     reg r_sel;
//     wire [3:0] w_out;

    
//     // 2. 검증할 모듈을 인스턴스화 함.
//     mux2_1 u_mux2_1(
//         .a(r_a), 
//         .b(r_b), 
//         .sel(r_sel),
//         .out(w_out) 
//     );

//     // 3. test scenario 작성
//     initial begin
//        // 초기값 설정 
//        r_a = 4'hA; r_b = 4'h3; r_sel = 0;
//         // 결과 콘솔 출력
//     $monitor("Time %0t r_a=%h, r_b=%h  w_out=%h", $time, r_sel, r_a, r_b, w_out); 

//        // sel == 1 : a 출력
       
//        #10; r_sel = 1; r_a=4'hE; r_b=4'h7;  // w_out = E
//        #10; r_sel = 1; r_a=4'hF; r_b=4'hA;  // w_out = F
        
//         // sel == 0 : b 출력
//        #10; r_sel = 0; r_a=4'h7; r_b=4'hA;  // w_out = A
//        #10; r_sel = 0; r_a=0; r_b=1;  // w_out = 1
//        #10; $finish;

//     end

// endmodule







// module tb_mux2_1();

  
// endmodule