`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    
    input [2:0] btn,       // Basys3의 물리 버튼 3개 (L, C, R)
    inout dht11_data,      
    input RsRx,

    output RsTx,
    output [7:0] seg,      // FND 세그먼트
    output [3:0] an        // FND 애노드
);

    wire [7:0] w_rx_data;
    wire w_rx_done;
    
    // DHT11 실시간 센서 데이터
    wire [7:0] w_humidity;
    wire [7:0] w_temperature;
    wire w_dht_valid;

    // --- [사전 설정 데이터 (임시 하드코딩)] ---
    wire [13:0] PRESET_CURRENT_TIME = 14'd1129; // 11h 29m
    wire [13:0] PRESET_ALARM_TIME   = 14'd1305; // 13h 05m
    wire [7:0]  PRESET_TARGET_TEMP  = 8'd25;    // 25c
    wire [3:0]  PRESET_FAN_SPEED    = 4'd7;     // LOW (0:OFF, 7:LOW, 9:HIGH)

    // --- [1. 버튼 디바운서 연결] ---
    wire [2:0] w_clean_btn;
    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn),                  // 3개의 물리 버튼 입력
        .debounced_btn(w_clean_btn) // 채터링이 제거된 깨끗한 버튼 신호 출력
    );

    // --- [2. FND 모듈 연결] ---
    fnd u_fnd(
        .clk(clk),
        .reset(reset),
        
        // 데이터 매핑
        .current_time(PRESET_CURRENT_TIME), 
        .alarm_time(PRESET_ALARM_TIME),   
        .target_temp(PRESET_TARGET_TEMP),  
        .current_temp(w_temperature),       // DHT11 실시간 온도
        .current_humi(w_humidity),          // DHT11 실시간 습도
        .fan_speed(PRESET_FAN_SPEED),    
        
        // btn[1] (보통 Center 버튼)을 모드 전환 버튼으로 사용
        .btn_mode(w_clean_btn[1]), 

        .an(an),
        .seg(seg)
    );

    // --- [3. DHT11 및 UART 제어기 연결] ---
    dht11 u_dht11(
        .clk(clk),
        .reset(reset),
        .dht11_data(dht11_data),
        .humidity(w_humidity),
        .temperature(w_temperature),
        .data_valid(w_dht_valid)
    );

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        
        .current_time(PRESET_CURRENT_TIME), 
        .alarm_time(PRESET_ALARM_TIME),     
        .target_temp(PRESET_TARGET_TEMP),   
        .fan_speed(PRESET_FAN_SPEED),       
        .current_temp(w_temperature),       
        .current_humi(w_humidity),          
        
        .dht_valid(w_dht_valid),            
        .rx(RsRx),
        .tx(RsTx), 
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

endmodule