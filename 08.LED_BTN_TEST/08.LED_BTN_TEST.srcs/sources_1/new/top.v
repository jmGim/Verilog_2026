`timescale 1ns / 1ps

module top #(
    parameter SIM_TICK_Hz = 1000,    // 보드용: 1000, 시뮬용: 더 큰 값
    parameter SIM_CNT_LIMIT = 50     // 보드용: 50 (50ms), 시뮬용: 2~5
)(
    input clk,
    input reset,
    input btn,            // 1비트로 변경
    output [15:0] led
);

    // 모듈 간 연결 와이어
    wire w_debounced_btn;
    wire w_btn_posedge;
    wire w_tick;

    // 1. 디바운서
    btn_debouncer #(
        .DEBOUNCE_LIMIT(1_000_000)   // 시뮬레이션 시 이 값도 작게 조절 가능
    ) u_btn_debouncer (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .debounced_btn(w_debounced_btn)
    );

    // 2. 1ms Tick 생성 (top의 SIM_TICK_Hz 반영)
    tick_1ms #(
        .TICK_Hz(SIM_TICK_Hz)
    ) u_tick_1ms (
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    // 3. 엣지 검출기
    led_btn_test u_led_btn_test (
        .clk(clk),
        .reset(reset),
        .btn(w_debounced_btn),
        .btn_posedge(w_btn_posedge)
    );

    // 4. LED 제어기 (top의 SIM_CNT_LIMIT 반영)
    led_controller #(
        .COUNT_LIMIT(SIM_CNT_LIMIT)
    ) u_led_controller (
        .clk(clk),
        .reset(reset),
        .btn(w_btn_posedge),
        .tick(w_tick),
        .led(led)
    );

endmodule