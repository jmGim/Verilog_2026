`timescale 1ns / 1ps

module melody(
    input clk, reset,
    input door_state, btn_start_stop, btn_cancel, btn_speed_up, btn_add_time, timeout,
    output buzzer
);
    localparam DO = 22'd19, MI = 22'd15, SOL = 22'd12, RA = 22'd11, DDO = 22'd9, HIGH_BEEP = 22'd7;
    // localparam TIME_1S = 27'd100_000_000, TIME_500MS = 26'd50_000_000, TIME_250MS = 26'd25_000_000, TIME_100MS = 26'd10_000_000;
    localparam TIME_1S = 27'd100_, TIME_500MS = 26'd50_, TIME_250MS = 26'd25_, TIME_100MS = 26'd10_;


    localparam IDLE = 3'd0, OPEN = 3'd1, CLOSE = 3'd2, TIMEOUT = 3'd3, BTNCLICK = 3'd4;

    reg [2:0] r_state;
    reg [26:0] r_dur_cnt;
    reg [2:0] r_step;
    reg [21:0] r_target, r_freq_cnt;
    reg r_buzzer;
    reg r_door_prev;

    always @(*) begin
        case(r_state)
            OPEN:  case(r_step) 0: r_target = DO; 1: r_target = MI; 2: r_target = SOL; 3: r_target = DDO; default: r_target = 0; endcase
            CLOSE: case(r_step) 0: r_target = DDO; 1: r_target = SOL; 2: r_target = MI; 3: r_target = DO; default: r_target = 0; endcase
            TIMEOUT:  r_target = (r_dur_cnt < TIME_500MS) ? RA : 0; // 0.5초 소리, 0.5초 무음
            BTNCLICK: r_target = HIGH_BEEP;
            default: r_target = 0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            r_state <= IDLE; 
            r_buzzer <= 0; 
            r_door_prev <= 1'b0; 
        end else begin
            r_door_prev <= door_state;

            case(r_state)
                IDLE: begin
                    r_dur_cnt <= 0; r_step <= 0;
                    if(door_state && !r_door_prev) r_state <= OPEN;
                    else if(!door_state && r_door_prev) r_state <= CLOSE;
                    else if(timeout) r_state <= TIMEOUT;
                    else if(btn_start_stop || btn_cancel || btn_speed_up || btn_add_time) r_state <= BTNCLICK;
                end
                OPEN, CLOSE: begin
                    if(r_dur_cnt >= TIME_250MS - 1) begin
                        r_dur_cnt <= 0;
                        if(r_step == 3) r_state <= IDLE; else r_step <= r_step + 1;
                    end else r_dur_cnt <= r_dur_cnt + 1;
                end
                TIMEOUT: begin
                    if(r_dur_cnt >= TIME_1S - 1) begin
                        r_dur_cnt <= 0;
                        if(r_step == 2) r_state <= IDLE; else r_step <= r_step + 1; // 0, 1, 2 총 3번
                    end else r_dur_cnt <= r_dur_cnt + 1;
                end
                BTNCLICK: begin
                    if(r_dur_cnt >= TIME_100MS - 1) r_state <= IDLE;
                    else r_dur_cnt <= r_dur_cnt + 1;
                end
            endcase

            if(r_target > 0) begin
                if(r_freq_cnt >= r_target - 1) begin r_freq_cnt <= 0; r_buzzer <= ~r_buzzer; end
                else r_freq_cnt <= r_freq_cnt + 1;
            end else begin r_buzzer <= 0; r_freq_cnt <= 0; end
        end
    end
    assign buzzer = r_buzzer;
endmodule
