`timescale 1ns / 1ps

// 100MHz → 10MHz 주파수를 만든다. 
// 100MHz 10% 조절
// 0~9까지 10번의 클럭을 세고 


module pwm_duty_control(
    input clk, 
    input reset,
    input duty_inc, 
    input duty_dec,

    output [3:0] DUTY_CYCLE,    // FND 출력 표시 0~9
    output PWM_OUT,
    output PWM_OUT_LED
    );

    reg [3:0] r_DUTY_CYCLE = 4'd5;
    reg [3:0] r_counter_PWM; 
    // edge detection register
    reg r_prev_duty_inc, r_prev_duty_dec;


    wire w_duty_inc = (duty_inc && !r_prev_duty_inc);    // rising edge 검출
    wire w_duty_dec = (duty_dec && !r_prev_duty_dec);


    // 1. duty cycle 제어 btnU, btnD
    always @ (posedge clk, posedge reset ) begin
        if (reset) begin
            r_DUTY_CYCLE <= 4'd5;    // 50% duty

        end else begin
            r_prev_duty_inc <= duty_inc;
            r_prev_duty_dec <= duty_dec;
            if (w_duty_inc && r_DUTY_CYCLE < 4'd9)  
                r_DUTY_CYCLE <= r_DUTY_CYCLE + 1;
                // if (r_DUTY_CYCLE > 999) r_DUTY_CYCLE <= 0;
            if (w_duty_dec && r_DUTY_CYCLE > 4'd1)  
                r_DUTY_CYCLE <= r_DUTY_CYCLE - 1;
            
        end
    end


    // 2. 10MHz PWM 신호 생성(0~9)
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            r_counter_PWM <= 0;
        end else begin
            if (r_counter_PWM > 4'd9) r_counter_PWM <= 0;
            else r_counter_PWM <= r_counter_PWM + 1;            
        end

    end

    assign PWM_OUT = (r_counter_PWM < r_DUTY_CYCLE) ? 1'b1 : 1'b0;
    assign PWM_OUT_LED = PWM_OUT;
    assign DUTY_CYCLE = r_DUTY_CYCLE;


endmodule
