`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [2:0] btn,
    input [7:0] sw,
    input RsRx,

    output RsTx,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led,
    output uartTx,  // JB1 - for Oscilloscope
    output uartRx   // JB2

    );


    wire w_tx, w_rx_data, w_rx_done;
    

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        .send_data(8'h30), // '0' : 0x30temp
        .rx(RsRx),

        .tx(RsTx), // wire
        .rx_data(w_rx_data),
        .rx_done(w_rx_done)
    );

    assign uartTx = RsTx;  // Oscilloscope Measurement
    assign uartRx = RsRx;

endmodule
