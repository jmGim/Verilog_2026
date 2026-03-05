`timescale 1ns / 1ps


module data_sender(
    input clk,
    input reset,
    // input start_trigger,
    input [7:0] send_data,  // 1byte
    input tx_busy,
    input tx_done,
    input [2:0] btn,
    

    output reg tx_start, 
    output reg [7:0] tx_data
    );

    // reg [6:0] r_send_byte_cnt = 7'd0;
    reg [2:0] ff1;
    reg [2:0] ff2;
    reg send_step;

    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            tx_start <= 1'b0;
            // r_send_byte_cnt <= 7'd0;
            ff1 <= 3'd0;
            ff2 <= 3'd0;
        end else begin
            ff1 <= btn;
            ff2 <= ff1;
            if (ff2[0] && !tx_busy) begin
                tx_start <= 1'b1;
                tx_data <= send_data;
            end else begin
                tx_start <= 1'b0;
            end
        end
    end
endmodule
