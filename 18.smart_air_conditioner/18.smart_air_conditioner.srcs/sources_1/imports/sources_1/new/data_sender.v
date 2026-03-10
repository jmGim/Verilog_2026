`timescale 1ns / 1ps

module data_sender(
    input clk,
    input reset,
    input start_trigger,      // DHT11의 data_valid 펄스
    input tx_busy,            // uart_tx 상태
    
    // --- [입력 데이터들] ---
    input [13:0] current_time,
    input [13:0] alarm_time,
    input [7:0]  target_temp,
    input [7:0]  current_temp,
    input [7:0]  current_humi,
    input [3:0]  fan_speed,
    
    // --- [출력 (uart_tx로 넘겨줄 보존된 데이터)] ---
    output reg tx_start, 
    output reg [13:0] tx_current_time,
    output reg [13:0] tx_alarm_time,
    output reg [7:0]  tx_target_temp,
    output reg [7:0]  tx_current_temp,
    output reg [7:0]  tx_current_humi,
    output reg [3:0]  tx_fan_speed
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_start <= 1'b0;
            tx_current_time <= 14'd0;
            tx_alarm_time   <= 14'd0;
            tx_target_temp  <= 8'd0;
            tx_current_temp <= 8'd0;
            tx_current_humi <= 8'd0;
            tx_fan_speed    <= 4'd0;
        end else begin
            // UART 전송 모듈이 대기 상태일 때 트리거가 들어오면 데이터 캡처 및 시작
            if (start_trigger && !tx_busy) begin
                tx_start <= 1'b1;
                tx_current_time <= current_time;
                tx_alarm_time   <= alarm_time;
                tx_target_temp  <= target_temp;
                tx_current_temp <= current_temp;
                tx_current_humi <= current_humi;
                tx_fan_speed    <= fan_speed;
            end else begin
                tx_start <= 1'b0; // 1클럭 펄스 유지
            end
        end
    end
endmodule