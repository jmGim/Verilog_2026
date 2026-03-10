`timescale 1ns / 1ps

module fnd (
    input clk,
    input reset,

    // --- [1. 통합 데이터 입력] ---
    input [13:0] current_time, 
    input [13:0] alarm_time,   
    input [7:0]  target_temp,  
    input [7:0]  current_temp, 
    input [7:0]  current_humi, 
    input [3:0]  fan_speed,    

    // --- [2. 모드 전환 버튼 (디바운싱 완료된 신호)] ---
    input btn_mode, 

    output [3:0] an,
    output [7:0] seg
);

    // --- [상승 엣지 검출기 (Rising Edge Detector)] ---
    // btn_mode는 이미 btn_debounce.v를 거쳐 노이즈가 없는 깨끗한 신호입니다.
    // 따라서 누르고 있는 동안 모드가 미친듯이 바뀌지 않도록, 
    // 0에서 1로 변하는 '순간'만 포착하여 1클럭짜리 펄스를 만듭니다.
    reg r_prev_btn;
    always @(posedge clk or posedge reset) begin
        if(reset) r_prev_btn <= 1'b0;
        else r_prev_btn <= btn_mode;
    end
    wire w_btn_rise = btn_mode & ~r_prev_btn;

    // --- [디스플레이 모드 상태 머신 (0~3 순환)] ---
    reg [1:0] r_mode;
    always @(posedge clk or posedge reset) begin
        if (reset) r_mode <= 2'd0;
        else if (w_btn_rise) r_mode <= r_mode + 1; // 버튼을 누를 때마다 모드 1 증가
    end

    // --- [모드별 FND 출력값 분배 (MUX)] ---
    reg [13:0] r_display_val;
    always @(*) begin
        case(r_mode)
            2'd0: r_display_val = current_time;                               // 예: 1129 (11h 29m)
            2'd1: r_display_val = alarm_time;                                 // 예: 1305 (13h 05m)
            2'd2: r_display_val = (target_temp * 100) + current_temp;         // 예: 2523 (타겟 25도, 현재 23도)
            2'd3: r_display_val = (current_humi * 100) + fan_speed;           // 예: 6007 (습도 60%, 팬 LOW)
            default: r_display_val = 14'd0;
        endcase
    end

    // --- [FND 구동을 위한 하위 모듈 연결] ---
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    fnd_digit_select #( .DYNAMIC_DRIVE_COUNT(100_000) ) u_fnd_digit_select(
        .clk(clk), .reset(reset), .sel(w_sel)
    );

    bin2bcd4digit u_bin2bcd4digit (
        .in_data(r_display_val), 
        .d1(w_d1), .d10(w_d10), .d100(w_d100), .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .digit_sel(w_sel),
        .d1(w_d1), .d10(w_d10), .d100(w_d100), .d1000(w_d1000),
        .an(an), .seg(seg)
    );

endmodule


module fnd_digit_select #(
    parameter DYNAMIC_DRIVE_COUNT = 100000 
)( 
    input clk, reset,
    output reg [1:0] sel
);
    // 1ms 마다 FND 자리를 이동시키는 카운터
    reg [31:0] r_1ms_counter = 0;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            sel <= 0; r_1ms_counter <= 0;
        end else begin
            if(r_1ms_counter >= DYNAMIC_DRIVE_COUNT - 1) begin 
                r_1ms_counter <= 0; sel <= sel + 1;
            end else r_1ms_counter <= r_1ms_counter + 1;
        end
    end
endmodule

module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1, d10, d100, d1000
);
    // 이진수를 10진수 각 자리로 분할
    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule

module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1, d10, d100, d1000,
    output reg [3:0] an, output reg [7:0] seg
);
    reg [3:0] bcd_data;
    
    // 현재 타이밍에 켜야 할 자리의 데이터를 가져옴
    always @(*) begin
        case(digit_sel)
            2'b00: bcd_data = d1;
            2'b01: bcd_data = d10;
            2'b10: bcd_data = d100;
            2'b11: bcd_data = d1000;
            default: bcd_data = 4'b0;
        endcase
    end

    // 데이터를 7-Segment LED 패턴으로 변환 (Active Low)
    always @(*) begin
        case(bcd_data)
            4'd0: seg = 8'b11000000; 4'd1: seg = 8'b11111001; 4'd2: seg = 8'b10100100;
            4'd3: seg = 8'b10110000; 4'd4: seg = 8'b10011001; 4'd5: seg = 8'b10010010;
            4'd6: seg = 8'b10000010; 4'd7: seg = 8'b11111000; 4'd8: seg = 8'b10000000;
            4'd9: seg = 8'b10010000; default: seg = 8'b11111111;
        endcase

        // 켤 자리(Anode) 선택 (Active Low)
        case(digit_sel)
            2'b00: an = 4'b1110; 2'b01: an = 4'b1101;
            2'b10: an = 4'b1011; 2'b11: an = 4'b0111;
            default: an = 4'b1111;
        endcase
    end
endmodule

            // if(timeout && r_blink_step == 0) begin
            //     r_blink_step <= 1; 
            //     r_blink_counter <= 0;
            // end

            // if(r_blink_step > 0) begin
            //     if(r_blink_counter >= BLINK_COUNT / 2 - 1) begin 
            //         r_blink_counter <= 0;
                    
            //         if(r_blink_step >= 6) begin
            //             r_blink_step <= 0;
            //             blink <= 0;
            //         end else begin
            //             r_blink_step <= r_blink_step + 1;
            //             blink <= ~blink;
            //         end
            //     end else r_blink_counter <= r_blink_counter + 1;
            // end


            // if(toggle) begin
            //     if(display_mode == 0) begin
            //         if(r_mode_counter >= IDLE_COUNT - 1) begin
            //             r_mode_counter <= 0;
            //             if(idle_state >= 11) begin idle_state <= 0; display_mode <= 1; end
            //             else idle_state <= idle_state + 1;
            //         end else r_mode_counter <= r_mode_counter + 1;
            //     end else begin
            //         if(r_mode_counter >= NUM_HOLD_COUNT - 1) begin
            //             r_mode_counter <= 0; display_mode <= 0;
            //         end else r_mode_counter <= r_mode_counter + 1;
            //     end
            // end else begin
            //     display_mode <= 1;
            //     idle_state <= 0;
            //     r_mode_counter <= 0;
            // end
 