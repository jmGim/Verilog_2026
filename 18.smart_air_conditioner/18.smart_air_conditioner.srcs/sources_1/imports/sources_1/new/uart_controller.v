`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    
    // DHT11 관련 입력 추가
    input [7:0] humidity,
    input [7:0] temperature,
    input dht_valid, 
    
    input rx,

    output tx, 
    output [7:0] rx_data,
    output rx_done
);

    wire w_tx_busy;
    wire w_tx_done;
    wire w_tx_start;
    wire [7:0] w_tx_data;

    // tick_generator 삭제됨 (DHT11이 자체적으로 2초 주기로 동작하므로 불필요)

    data_sender u_data_sender(
        .clk(clk),
        .reset(reset),
        .start_trigger(dht_valid),  // DHT11의 정상 데이터 송신 펄스
        .humidity(humidity),        
        .temperature(temperature),  
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done),

        .tx_start(w_tx_start), 
        .tx_data(w_tx_data)
    );

    uart_tx #( .BPS(9600) ) u_uart_tx(
        .clk(clk),
        .reset(reset),
        .tx_data(w_tx_data),
        .tx_start(w_tx_start),
        
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