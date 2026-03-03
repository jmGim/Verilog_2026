`timescale 1ns / 1ps

module tick_1ms #(
    parameter TICK_Hz = 1000
) (
    input clk, 
    input reset,
    output tick // 포트에서 reg 제거 (assign 사용을 위해)
);

    localparam INPUT_FREQUENCY = 100_000_000;
    localparam TICK_COUNT = INPUT_FREQUENCY / TICK_Hz;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_tick_counter <= 0;
        end else begin
            if (r_tick_counter >= TICK_COUNT - 1) r_tick_counter <= 0;
            else r_tick_counter <= r_tick_counter + 1;
        end
    end
    
    // 카운트가 0일 때만 1이 되는 1클럭 펄스 생성
    assign tick = (r_tick_counter == 0); 
    
endmodule