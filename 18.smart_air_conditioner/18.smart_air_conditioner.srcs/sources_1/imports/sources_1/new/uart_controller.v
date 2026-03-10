`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    
    // --- [top.v 로부터 받는 데이터] ---
    input [13:0] current_time, 
    input [13:0] alarm_time,   
    input [7:0]  target_temp,  
    input [7:0]  current_temp, 
    input [7:0]  current_humi, 
    input [3:0]  fan_speed,    
    
    input dht_valid, // 2초 주기 전송 트리거
    input rx,

    output tx, 
    output [7:0] rx_data,
    output rx_done
);

    wire w_tx_busy;
    wire w_tx_done;
    wire w_tx_start;
    
    // data_sender -> uart_tx 연결용 wire
    wire [13:0] w_tx_current_time;
    wire [13:0] w_tx_alarm_time;
    wire [7:0]  w_tx_target_temp;
    wire [7:0]  w_tx_current_temp;
    wire [7:0]  w_tx_current_humi;
    wire [3:0]  w_tx_fan_speed;

    data_sender u_data_sender(
        .clk(clk),
        .reset(reset),
        .start_trigger(dht_valid),
        .tx_busy(w_tx_busy),
        
        .current_time(current_time),
        .alarm_time(alarm_time),
        .target_temp(target_temp),
        .current_temp(current_temp),
        .current_humi(current_humi),
        .fan_speed(fan_speed),
        
        .tx_start(w_tx_start), 
        .tx_current_time(w_tx_current_time),
        .tx_alarm_time(w_tx_alarm_time),
        .tx_target_temp(w_tx_target_temp),
        .tx_current_temp(w_tx_current_temp),
        .tx_current_humi(w_tx_current_humi),
        .tx_fan_speed(w_tx_fan_speed)
    );

    uart_tx #( .BPS(9600) ) u_uart_tx(
        .clk(clk),
        .reset(reset),
        .tx_start(w_tx_start),
        
        .current_time(w_tx_current_time),
        .alarm_time(w_tx_alarm_time),
        .target_temp(w_tx_target_temp),
        .current_temp(w_tx_current_temp),
        .current_humi(w_tx_current_humi),
        .fan_speed(w_tx_fan_speed),
        
        .tx(tx),
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done)
    );

    uart_rx #( .BPS(9600) ) u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(rx_data),
        .rx_done(rx_done)
    );
endmodule