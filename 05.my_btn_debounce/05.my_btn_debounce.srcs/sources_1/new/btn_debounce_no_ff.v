`timescale 1ns / 1ps

module btn_debounce_no_ff(
    input i_clk,   // 100MHz  
    input i_reset,
    input i_btnC,
    output reg r_led_toggle = 1'b0

    // output reg o_clk,    // 100Hz, always 문에서는 reg로 출력해야함.  
    // output [1:0] led
    );
    parameter integer DEBOUNCE_CNT= 0;

    reg btn_status;
    reg [$clog2(1_000_000)-1:0] r_counter = 0;  // 1,000,000 저장 할 수 있는 size
    
    
    always @ (posedge i_clk, posedge i_reset) begin

        if(i_reset) begin   // 비동기 reset 0 → 1(버튼 누르면 reset)
            r_counter <= 0;   // non blocking 방식 : 동시 수행
            r_led_toggle <= 0;
            // o_clk <= 0;
        end else begin 
            if (i_btnC == btn_status) begin   // 100Hz 1주기 10ms 
                r_counter <= 0;
                // r_led_toggle <= 1'b0;
                
            end else begin
                if(r_counter < DEBOUNCE_CNT -1) begin
                    r_counter <= r_counter + 1;
                end
                else begin
                    btn_status <= i_btnC;
                    r_counter <= 0;
                    r_led_toggle <= ~r_led_toggle;
                end
            end
        end

    end
    // assign led[0] = r_led_toggle;




endmodule




