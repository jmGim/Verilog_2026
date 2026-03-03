`timescale 1ns / 1ps


// Sim 속도를 높이기 위해 DEBOUNCE_LIMIT 을 2us 로 수정
module tb_top_rotary();

    reg clk;
    reg reset;    
    reg s1;
    reg s2;
    reg key;

    wire [15:0] led;

    top_rotary u_top_rotary(
    .clk(clk),
    .reset(reset),    
    .s1(s1),
    .s2(s2),
    .key(key),

    .led(led)
    );

    // 100MHz clock 생성
    always #5 clk = ~clk;

    // 일괄 50ns * 3 noise 만듬
    task make_btn_noise(input integer sw);  // 0 : s1, 1 : s2
        begin 
            repeat(3) begin
                if(sw == 0) s1 = ~s1; 
                else if (sw == 1) s2 = ~s2;
                else key = ~key;
                #50;  // Chattering width = 50ns 
            end
        end
    endtask

    initial begin
        clk = 0; reset = 0; s1 = 0; s2 = 0; key = 0;
        #100;
        reset = 0;
        #100;
        $dispaly("CW TEST start ......");

        // Making Noise
        make_btn_noise(0);
        s1 = 1;  // CW 00 -> 10 
        #3000  // 200cycle ( 10us * 200) : noise 보다 긴 3000ns 대기
        make_btn_noise(0);
    end

endmodule
