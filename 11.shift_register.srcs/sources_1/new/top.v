`timescale 1ns / 1ps


module top#(
    parameter SIM_TICK_Hz = 1000,
    parameter SIM_CNT_LIMIT = 50,
    parameter SIM_DEBOUNCE_LIMIT = 1_000_000 // 파라미터 추가 [cite: 86]
    )(
        input clk,
        input reset,
        input btnU, btnD,
        output [6:0] led
        
    );

    wire w_debounced_btnU;
    wire w_debounced_btnD;
    wire [1:0] w_btn_posedge;


    btn_debouncer #(
        .DEBOUNCE_LIMIT(SIM_DEBOUNCE_LIMIT)
    ) u_btn_debouncer (
        .clk(clk), .reset(reset), .btn({btnD, btnU}),
        .debounced_btn({w_debounced_btnD, w_debounced_btnU})
    );

    btn_click_detector u_btn_click_detector(
        .clk(clk), .reset(reset), .btn({w_debounced_btnD, w_debounced_btnU}), // 디바운싱 된 버튼 사용
        .btn_posedge(w_btn_posedge) // [2:0]으로 출력됨
    );

    shift_register u_shift_register(
        .clk(clk),  
        .reset(reset),   // SW15
        .btnU(w_btn_posedge[0]),   // 1을 입력
        .btnD(w_btn_posedge[1]),   // 0을 입력
        .led(led)
    );


    // btn_click_detector u_btn_click_detector(
    //     .clk(clk), .reset(reset), .btn(w_debounced_btn), // 디바운싱 된 버튼 사용
    //     .btn_negedge(w_btn_posedge) // [2:0]으로 출력됨
    // );

endmodule
