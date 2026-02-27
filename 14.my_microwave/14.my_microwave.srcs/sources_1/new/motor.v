`timescale 1ns / 1ps

module motor(
    input clk, 
    input reset,
    input btn_start_stop,  
    input btn_speedup,
    input timeout,

    output [3:0] DUTY_CYCLE,    // FND 출력 표시 0~9
    output pwm_plate

    );

    reg [3:0] r_DUTY_CYCLE = 4'd0;
    reg [3:0] r_counter_PWM;
    reg r_btn_start_stop;
    reg r_btn_speedup;

    wire w_btn_start_stop;  
    wire w_btn_speedup;


    // 1. duty cycle 제어 btnU, btnD
    always @ (posedge clk, posedge reset ) begin
        if (timeout) r_DUTY_CYCLE <= 4'd0;
        if (reset) begin
            r_DUTY_CYCLE <= 4'd0;    // 50% duty
        end else begin
            r_btn_speedup <= btn_speedup;
            if (w_btn_speedup && r_DUTY_CYCLE <= 4'd10)  
                r_DUTY_CYCLE <= r_DUTY_CYCLE + 1; 
            else if (w_btn_speedup && r_DUTY_CYCLE > 4'd10)
                r_DUTY_CYCLE <= 0; 
            
        end
    end


    // 2. 10MHz PWM 신호 생성(0~9)
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            r_counter_PWM <= 0;
        if (timeout) r_counter_PWM <= 0;
        if (!btn_start_stop) r_counter_PWM <= 0;
        end else begin
            if (r_counter_PWM > 4'd9) r_counter_PWM <= 0;
            else r_counter_PWM <= r_counter_PWM + 1;            
        end

    end

    assign DUTY_CYCLE = r_DUTY_CYCLE;
    assign pwm_plate = r_counter_PWM * 10;

endmodule
