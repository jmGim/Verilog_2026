module top #(
    parameter SIM_TICK_Hz = 1000,
    parameter SIM_CNT_LIMIT = 50,
    parameter SIM_DEBOUNCE_LIMIT = 1_000_000 // 파라미터 추가 [cite: 86]
)(
    input clk,
    input reset,
    input [2:0] btn,
    output [7:0] seg,
    output [3:0] an
);
    // 1비트 wire는 [2:0] 또는 [12:0] 등으로 명확히 너비 지정 필요
    wire [2:0] w_debounced_btn;
    wire [2:0] w_btn_negedge;  // 3비트로 수정 
    wire [12:0] w_coin_val;    // 1비트에서 13비트로 수정 
    wire w_tick;               // w_tick으로 일치 
    wire w_coffee_make;

    btn_debouncer #(
        .DEBOUNCE_LIMIT(SIM_DEBOUNCE_LIMIT)
    ) u_btn_debouncer (
        .clk(clk), .reset(reset), .btn(btn),
        .debounced_btn(w_debounced_btn)
    );

    tick_1ms #(.TICK_Hz(SIM_TICK_Hz)) u_tick_1ms (
        .clk(clk), .reset(reset), .tick(w_tick)
    );

    coffee_btn_detector u_coffee_btn_detector(
        .clk(clk), .reset(reset), .btn(w_debounced_btn), // 디바운싱 된 버튼 사용
        .btn_negedge(w_btn_negedge) // [2:0]으로 출력됨
    );

    coffee_machine_controller #(.COUNT_LIMIT(SIM_CNT_LIMIT)) u_coffee_machine_controller(
        .clk(clk), .reset(reset), 
        // .btn(w_btn_negedge), // 실제 제어는 엣지 검출 신호를 사용함
        .tick(w_tick), // w_tick으로 연결 수정 
        .btn_negedge(w_btn_negedge),
      
        .coin_val(w_coin_val), // 13비트 데이터 수신 
        .coffee_make(w_coffee_make)
    );

    fnd_controller u_fnd_controller(
        .clk(clk), .reset(reset),
        .in_data(w_coin_val[12:0]), // coin_val 데이터를 FND로 직접 전달 
        .motor_direction(motor_direction),

        .an(an), .seg(seg)
    );
endmodule