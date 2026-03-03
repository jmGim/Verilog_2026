`timescale 1ns / 1ps

module motor(
    input clk, reset,
    input door_state, btn_start_stop, btn_cancel, btn_speed_up, timeout,
    output pwm_plate
);
    reg [3:0] r_duty = 4'd10;
    reg [3:0] r_cnt_pwm;
    reg r_running;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_running <= 1'b0;
            r_duty <= 4'd10;
        end else begin
            if(door_state || btn_cancel || timeout) begin
                r_running <= 1'b0;
                r_duty <= 4'd0;
            end else begin
                if(btn_start_stop && !door_state) begin
                    r_running <= 1'b1;
                    if(r_duty == 0) r_duty <= 4'd10;
                end

                if(r_running && btn_speed_up) begin
                    if(r_duty >= 4'd10) r_duty <= 4'd0;
                    else r_duty <= r_duty + 1'b1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if(reset) r_cnt_pwm <= 4'd0;
        else begin
            if(r_cnt_pwm >= 4'd9) r_cnt_pwm <= 4'd0;
            else r_cnt_pwm <= r_cnt_pwm + 1'b1;
        end
    end

    // assign pwm_plate = r_running ? (r_cnt_pwm < r_duty) : 1'b0;
    assign pwm_plate = r_duty;

endmodule
