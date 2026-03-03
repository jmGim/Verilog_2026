`timescale 1ns / 1ps


module clock_80Hz(
    input i_clk,   // 100MHz  
    input i_reset,
    output reg o_clk    // 80Hz, always 문에서는 reg로 출력해야함.  
    );
    // reg[23:0] r_counter = 0;  // 10ns * 1,250,000 = 12.5ms
    //  8 --> 1000 --> reg [3:0] r_counter
    reg [$clog2(1250000)-1:0] r_counter = 0;  // 1,250,000 저장 할 수 있는 ㅅsize

    // 10ns clk가 오거나 i_reset버튼을 누르면 항상 수행
    always @ (posedge i_clk, posedge i_reset) begin

        if(i_reset) begin   // 비동기 reset 0 → 1(버튼 누르면 reset)
            r_counter <= 0;   // non blocking 방식 : 동시 수행
            o_clk <= 0;
        end else begin 
            if (r_counter == (1_250_000/2)-1 ) begin   // 80Hz 1주기 12.5ms 
                r_counter <= 0;
                o_clk <= ~o_clk;
            end else begin 
                r_counter <= r_counter + 1;
            end     
        end

    end

endmodule
