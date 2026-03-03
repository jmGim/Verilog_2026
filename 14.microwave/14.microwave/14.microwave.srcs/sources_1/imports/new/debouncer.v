`timescale 1ns / 1ps

module debouncer(
    input btn,
    input clk,
    input reset,
    output clean_btn
    );

    parameter MAX_COUNT = 1_00;

    reg [$clog2(MAX_COUNT) - 1:0] r_counter = 0; // 10ms
    reg r_clean_btn = 1'b0;
    reg r_prev_clean_btn = 1'b0;

    always @(posedge clk, posedge reset) begin
            if(reset) begin
                r_prev_clean_btn <= 0;
                r_clean_btn <= 0;
                r_counter <= 0; 
            end 
            else begin
                r_prev_clean_btn <= r_clean_btn;
                
                if(btn == r_clean_btn) begin
                    r_counter <= 0; 
                end 
                else begin
                    r_counter <= r_counter + 1;

                    if(r_counter >= MAX_COUNT - 1) begin // 10ms 디바운싱
                        r_clean_btn <= btn;
                        r_counter <= 0;
                    end
                end
            end
        end
        //assign clean_btn = r_clean_btn;
        assign clean_btn = (r_clean_btn && !r_prev_clean_btn);
endmodule
