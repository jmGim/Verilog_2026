`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [2:0] btn,       // 사용 안 함 (주석 처리 또는 무시)
    // input [7:0] sw,
    
    inout dht11_data,      // DHT11 입출력 핀 추가!
    
    input RsRx,

    output RsTx,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    // output uartTx,  
    // output uartRx   
);

    wire [7:0] w_rx_data;
    wire w_rx_done;
    wire [13:0] w_seg_data;
    
    wire [7:0] w_humidity;
    wire [7:0] w_temperature;
    wire w_dht_valid;

    // 사람이 개입하지 않으므로 버튼 디바운서 주석 처리
    /* wire [2:0] w_clean_btn;
    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),   
        .debounced_btn(w_clean_btn)
    );
    */

    // DHT11 센서 모듈 인스턴스화
    dht11 u_dht11(
        .clk(clk),
        .reset(reset),
        .dht11_data(dht11_data),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .data_valid(w_dht_valid)
    );

    // 제어 타워 (버튼 입력에는 0을 고정으로 넣어줌)
    control_tower u_control_tower(
        .clk(clk),
        .reset(reset),  
        .btn(3'b000),         // 버튼 신호 차단
        .sw(8'd0),            // sw 신호 차단
        .rx_data(w_rx_data),  
        .rx_done(w_rx_done),  

        .seg_data(w_seg_data),
        .led(led)
    );

    // UART 컨트롤러 (온습도 데이터 전달)
    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        .humidity(w_humidity),       // DHT11 습도 데이터
        .temperature(w_temperature), // DHT11 온도 데이터
        .dht_valid(w_dht_valid),     // 데이터 유효 트리거 전달
        .rx(RsRx),

        .tx(RsTx), 
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    assign uartTx = RsTx;  
    assign uartRx = RsRx;
    // assign led = w_seg_data;

endmodule