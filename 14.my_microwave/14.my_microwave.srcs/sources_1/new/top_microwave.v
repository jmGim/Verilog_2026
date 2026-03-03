`timescale 1ns / 1ps

module top_microwave(
    input clk, reset,
    input btn_open_close, btn_start_stop, btn_cancel, btn_speedup, timeout,
    // output [3:0] pwm_plate,
    output buzzer
);
    // 디바운싱 와이어
    wire db_open_close, db_start_stop, db_cancel, db_speedup, db_timeout;
    
    // 엣지 펄스 와이어
    wire w_oc_pos; // Open/Close 버튼 상승 엣지
    wire w_open_trig, w_close_trig;
    wire w_start_pos, w_stop_neg;
    wire w_cancel_pos, w_speedup_pos, w_timeout_pos;

    // 1. 디바운서 인스턴스화
    debouncer u_db0(.clk(clk), .reset(reset), .noisy_btn(btn_open_close),  .clean_btn(db_open_close));
    debouncer u_db1(.clk(clk), .reset(reset), .noisy_btn(btn_start_stop),  .clean_btn(db_start_stop));
    debouncer u_db2(.clk(clk), .reset(reset), .noisy_btn(btn_cancel),      .clean_btn(db_cancel));
    debouncer u_db3(.clk(clk), .reset(reset), .noisy_btn(btn_speedup),     .clean_btn(db_speedup));
    debouncer u_db4(.clk(clk), .reset(reset), .noisy_btn(timeout),         .clean_btn(db_timeout));

    // 2. 엣지 및 토글 로직
    reg r_oc, r_start, r_cancel, r_speed, r_time;
    reg r_door_open; // 문 상태 (0: Closed, 1: Open)

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_oc <= 0; r_start <= 0; r_cancel <= 0; r_speed <= 0; r_time <= 0;
            r_door_open <= 0;
        end else begin
            r_oc <= db_open_close; r_start <= db_start_stop;
            r_cancel <= db_cancel; r_speed <= db_speedup; r_time <= db_timeout;
            
            // 버튼을 누를 때마다 문 상태 토글
            if(db_open_close && !r_oc) r_door_open <= ~r_door_open;
        end
    end

    // Open/Close 트리거 분리
    assign w_oc_pos     = (db_open_close && !r_oc);
    assign w_open_trig  = w_oc_pos && !r_door_open; // 닫힌 상태에서 누르면 Open
    assign w_close_trig = w_oc_pos && r_door_open;  // 열린 상태에서 누르면 Close

    assign w_start_pos   = (db_start_stop && !r_start);
    assign w_stop_neg    = (!db_start_stop && r_start);
    assign w_cancel_pos  = (db_cancel && !r_cancel);
    assign w_speedup_pos = (db_speedup && !r_speed);
    assign w_timeout_pos = (db_timeout && !r_time);

    // 3. 모듈 연결
    motor u_motor(
        .clk(clk), .reset(reset),
        .motor_direction(motor_direction),
        .btn_start_pos(w_start_pos && !r_door_state), // 문 닫혔을 때만 시작
        .btn_stop_neg(w_stop_neg),
        .btn_cancel(w_cancel_pos),
        .btn_speedup(w_speedup_pos),
        .timeout(w_timeout_pos || r_door_state),     // 문 열리면 정지 신호로 간주
        // .in1_in2(in1_in2),
        .PWM_OUT(PWM_OUT)
    );

    melody u_melody(
        .clk(clk), .reset(reset),
        .btn_open(w_open_trig), .btn_close(w_close_trig),
        .btn_start(w_start_pos), .btn_cancel(w_cancel_pos),
        .btn_speedup(w_speedup_pos), .timeout(w_timeout_pos),
        .buzzer(buzzer)
    );
endmodule