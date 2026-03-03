`timescale 1ns / 1ps

module min_sec_stopwatch(
    input clk,
    input reset,        // sw[15]
    input [2:0] btn,    // btn[0]: btnL, btn[1]: btnC, btn[2]: btnR
    output [7:0] seg,
    output [3:0] an
    );

    wire [2:0] w_debounced_btn;
    wire [11:0] w_seg_data;
    wire w_seg_dot;
    wire w_idle;

    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),   // 3개의 버튼 입력: btn[2:0] → 각각 btnL, btnC, btnR
        .debounced_btn(w_debounced_btn)
    );

    control_tower u_control_tower(
        .clk(clk),
        .reset(reset),
        .btn(w_debounced_btn),
        .seg_data(w_seg_data),
        .idle(w_idle)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .in_data(w_seg_data),
        .an(an),
        .seg(seg[7:0]),
        .seg_dot(w_seg_dot),
        .idle(w_idle)
    );

    blink u_blink(
        .clk(clk),
        .reset(reset),
        .seg_dot(w_seg_dot)
    );

endmodule
