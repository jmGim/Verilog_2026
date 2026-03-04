`timescale 1ns / 1ps


module tick_generator #(
    parameter INPUT_FREQUENCY = 100_000_000, // 100MHz
    parameter TICK_Hz = 1000  // 구형파 변화 1000번 : 1KHz
    
    )( 
        input clk,
        input reset,
        output reg tick
    );

  
    parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz;    // 100_000

    // 1mm bit를 카운트하는 변수 필요
    reg [$clog2(TICK_COUNT) - 1 : 0] r_tick_counter = 0;  // 16bit


    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            tick <= 0;
            r_tick_counter <= 0;

        end else begin
            if (r_tick_counter >= TICK_COUNT - 1) begin
                r_tick_counter <= 0;
                tick <= 1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tick <= 1'b0;
            end
        end
    end  

endmodule
