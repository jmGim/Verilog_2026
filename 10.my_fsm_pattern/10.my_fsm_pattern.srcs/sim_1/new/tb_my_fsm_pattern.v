`timescale 1ns / 1ps


module tb_my_fsm_pattern();

    reg clk;
    reg reset;
    reg din_bit;

    wire detect_out;

    // 1. test 할 module을 instance 화  
    my_fsm_pattern u_my_fsm_pattern(
    .clk(clk),
    .reset(reset),
    .din_bit(din_bit),
    .detect_out(detect_out)
    );


    // 2. clk을 생성 100MHz : 1T = 10ns (High : 5ns, Low : 5ns)
    always #5 clk = ~clk;

    // 값이 변하면 값을 출력한다. 
    initial begin 
        $monitor("time = %t state = %b , in = %b, out = %b", $time, 
        u_my_fsm_pattern.current_state, din_bit, detect_out);  // tb에 없고 instance안에 있는 변수 출력
        
    end

    // 3. test scenario
    initial begin
        clk = 0;
        reset = 1;
        din_bit = 0;

        //reset 해제
        #100 reset = 0;

        // #1 : test pattern 0110  : 10ns(1주기 마다 1bit 씩 날리기)
        @(posedge clk); din_bit = 0;
        @(posedge clk); din_bit = 1;
        @(posedge clk); din_bit = 1;
        @(posedge clk); din_bit = 0;  // st3 → st4: 여기서 detect_out =1



        // #2 0110 입력 → st4에서 다시 st4  : 10ns(1주기 마다 1bit 씩 날리기)

        @(posedge clk); din_bit = 0;
        @(posedge clk); din_bit = 1;
        @(posedge clk); din_bit = 1;
        @(posedge clk); din_bit = 0;
        
        // #3 010110  out 1이 되면 S1
        @(posedge clk); din_bit = 0; // st4 → st1 0
        @(posedge clk); din_bit = 1; // st1 → st2 01
        @(posedge clk); din_bit = 0; // st2 → st1 010 
        @(posedge clk); din_bit = 1; // st1 → st2 0101
        @(posedge clk); din_bit = 1; // st2 → st3 01011
        @(posedge clk); din_bit = 0; // st3 → st4 010110 검출


        // #4  110
        @(posedge clk); din_bit = 1;  // st4 → st2 1
        @(posedge clk); din_bit = 1;  // st2 → st3 11
        @(posedge clk); din_bit = 0;  // st3 → st4 110


        // #5  1011 0110
        @(posedge clk); din_bit = 1;  // st4 → st2 1
        @(posedge clk); din_bit = 0;  // st2 → st1 0
        @(posedge clk); din_bit = 1;  // st1 → st2 101
        @(posedge clk); din_bit = 1;  // st2 → st3 1011

        @(posedge clk); din_bit = 0;  // st3 → st4 10110  detect_out = 1
        @(posedge clk); din_bit = 1;  // st4 → st2 101101
        @(posedge clk); din_bit = 1;  // st2 → st3  1011 011
        @(posedge clk); din_bit = 0;  // st3 → st4  1011 0110  detect_out = 1


        #100 ;
        $display("Simulaion Finished");
        $finish;
        
    end

endmodule
