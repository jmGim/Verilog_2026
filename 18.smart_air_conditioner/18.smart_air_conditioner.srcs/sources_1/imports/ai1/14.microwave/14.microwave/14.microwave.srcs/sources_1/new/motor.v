`timescale 1ns / 1ps

module motor(
    input clk, reset,
    input [7:0] target,      // [수정됨] 크기 비교를 위해 8비트로 명시
    input [7:0] temperature, // [수정됨] 크기 비교를 위해 8비트로 명시
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
            if(target > temperature) begin
                r_running <= 1'b0;
                r_duty <= 4'd0;
            end else begin
                r_running <= 1'b1;
                if(r_duty == 0) r_duty <= 4'd10;
                if(r_duty >= 4'd10) r_duty <= 4'd0;
                else r_duty <= r_duty + 1'b1;
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

    // [수정됨] 1비트 출력을 위해 주석 처리되어 있던 올바른 PWM 로직 복원
    assign pwm_plate = r_running ? (r_cnt_pwm < r_duty) : 1'b0;

endmodule