`timescale 1ns / 1ps


module tb_shift_register();
    
    reg clk;  
    reg reset;   // SW15
    reg btnU;   // 1을 입력
    reg btnD;   // 0을 입력
    wire [15:0] led;
    


    // 1. test 할 module을 btnUstance 화

    shift_register u_shift_register(
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .out(out)
    );

    // 2. clk을 생성 100MHz : 1T = 10ns (High : 5ns, Low : 5ns)
    always #5 clk = ~clk;

    // 값이 변하면 값을 출력한다. 
    initial begin 
        $monitor("time = %t state = %b , btnU = %b, out = %b", $time, u_shift_register.sr7, btnU, out);  // tb에 없고 btnUstance안에 있는 변수 출력
        
    end


    // 3. test scenario


    initial begin
        clk = 0;
        reset = 1;
        btnU = 0;

        //reset 해제
        #100 reset = 0;

        // #1 : test pattern 1010111  : 10ns(1주기 마다 1bit 씩 날리기)
        @(posedge clk); btnU = 1;
        @(posedge clk); btnU = 0;
        @(posedge clk); btnU = 1;
        @(posedge clk); btnU = 0;
        @(posedge clk); btnU = 1;
        @(posedge clk); btnU = 1;
        // S6 → S1: 여기서 out =1
        @(posedge clk); btnU = 1;


        // #2 011 입력 → S1  : 10ns(1주기 마다 1bit 씩 날리기)

        @(posedge clk); btnU = 0; // S1 → S2 10
        @(posedge clk); btnU = 1; // S2 → S3 101
        @(posedge clk); btnU = 1; // S3 → S1 1010
        
       // #3 010111 out 1이 되면 S1
        @(posedge clk); btnU = 0; // S1 → S2 10
        @(posedge clk); btnU = 1; // S2 → S3 101
        @(posedge clk); btnU = 0; // S3 → S4 1010 
        @(posedge clk); btnU = 1; // S4 → S5 10101
        @(posedge clk); btnU = 1; // S5 → S6 101011
        @(posedge clk); btnU = 1; // S6 → S1 101011 검출
        #100 ;
        $display("Simuulaion Finished");
        $finish;
        

    end


endmodule


