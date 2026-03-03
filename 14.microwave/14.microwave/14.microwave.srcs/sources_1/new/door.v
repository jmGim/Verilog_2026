`timescale 1ns / 1ps

module door (
    input clk,
    input reset,
    input btn_open_close, 
    output reg pwm_door,
    output reg door_state
);
    always @(posedge btn_open_close or posedge reset) begin
        if (reset) begin
            door_state <= 1'b0;
        end
        else begin
            door_state <= ~door_state;
        end
    end

    reg [20:0] r_counter;
    wire [20:0] duty = door_state ? 21'd200_000 : 21'd100_000; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_counter <= 21'd0;
            pwm_door <= 1'b0;
        end else begin
            if(r_counter >= 21'd1_999_) begin   // 999_999
                r_counter <= 21'd0;
            end
            else begin
                r_counter <= r_counter + 1'b1;
            end

            pwm_door <= (r_counter < duty) ? 1'b1 : 1'b0;
        end
    end

endmodule
