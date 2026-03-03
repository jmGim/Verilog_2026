`timescale 1ns / 1ps

module blink(
    input clk,
    input reset,
    output seg_dot
    );

    reg [24:0] r_counter;
    reg r_seg_dot;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_seg_dot <= 0;
        end else begin
            if(r_counter >= 25'd25_000_000 - 1) begin
                r_counter <= 0;
                r_seg_dot <= ~r_seg_dot;
            end else begin
                r_counter <= r_counter + 1;
            end
        end
    end
    
    assign seg_dot = r_seg_dot;
endmodule
