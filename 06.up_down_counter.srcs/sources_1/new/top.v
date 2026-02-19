`timescale 1ns / 1ps

module top(
    input clk, 
    input reset,  // switch 15번
    input [2:0] btn,  // L,C,R in the order
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    // output [15:0] led
    output led
    // output [2:0] JXADC  // 
    );

    wire [13:0] w_seg_data;
    wire [2:0] w_debounced_btn;

    

    

    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),   // 3개의 버튼 입력: btn[2:0] → 각각 btnL, btnC, btnR
        .debounced_btn(w_debounced_btn)
    );


    

    control_tower u_control_tower(
    .clk(clk), 
    .reset(reset),  // switch 15번
    .btn(w_debounced_btn),  // L,C,R in the order
    .sw(sw),
    .seg_data(w_seg_data)
    
    // .led(led)
    );


    fnd_controller u_fnd_controller(
    .clk(clk), 
    .reset(reset),  // switch 15번
    .in_data(w_seg_data),

    .an(an),
    .seg(seg)
    );

    tick_gen u_tick_gen(
        .clk(clk),
        .reset(reset),

        .led(led)
    );



    // assign JXADC = w_debounced_btn;  // 정제된 신호 출력 
    // assign led = w_debounced_btn;


endmodule
