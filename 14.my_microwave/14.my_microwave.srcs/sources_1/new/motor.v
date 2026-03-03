`timescale 1ns / 1ps

module motor(
    input clk, reset,
    input [1:0] motor_direction,
    input btn_start_pos, btn_stop_neg, btn_cancel, btn_speedup, timeout,
    // output [1:0] in1_in2,
    output PWM_OUT
);
    reg [3:0] r_DUTY_CYCLE = 4'd5;
    reg [3:0] r_counter_PWM;
    reg r_running;
    reg r_stop_ready; // 정지 대기 상태 플래그

    // 모터 드라이버 제어 (정방향 {1, 0})
    assign in1_in2 = r_running ? motor_direction : 2'b00;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_running <= 0; r_DUTY_CYCLE <= 0; r_stop_ready <= 0;
        end else begin
            if(!r_running) begin
                if(btn_start_pos) begin
                    r_running <= 1; r_DUTY_CYCLE <= 4'd5; r_stop_ready <= 0;
                end
            end else begin
                // 1. Start/Stop 특수 로직: 이후 다시 한 번 눌러 하강 엣지일 때 Stop
                if(btn_start_pos) r_stop_ready <= 1; 
                if(btn_stop_neg && r_stop_ready) begin
                    r_running <= 0; r_DUTY_CYCLE <= 0; r_stop_ready <= 0;
                end

                // 2. 가동 중 속도 조절 (최대 9) [cite: 154-155]
                if(btn_speedup) 
                    r_DUTY_CYCLE <= (r_DUTY_CYCLE >= 9) ? 9 : r_DUTY_CYCLE + 1;

                // 3. 즉시 정지 조건
                if(btn_cancel || timeout) begin
                    r_running <= 0; r_DUTY_CYCLE <= 0; r_stop_ready <= 0;
                end
            end
        end
    end

    // PWM 신호 생성 (10MHz) [cite: 178-179]
    always @(posedge clk or posedge reset) begin
        if(reset) r_counter_PWM <= 0;
        else begin
            if(r_counter_PWM >= 9) r_counter_PWM <= 0;
            else r_counter_PWM <= r_counter_PWM + 1;
        end
    end

    assign PWM_OUT =  r_DUTY_CYCLE;
endmodule