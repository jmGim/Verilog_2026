`timescale 1ns / 1ps

module melody(
    input clk, reset,
    input btn_open, btn_close, btn_start, btn_cancel, btn_speedup, timeout,
    output buzzer
);
    localparam DO = 22'd191_112, MI = 22'd151_685, SOL = 22'd127_551, RA = 22'd113_636, DDO = 22'd95_056, DDOSHARP = 22'd90_252;
    localparam TIME_500MS = 26'd50_000_000;

    localparam IDLE = 3'd0, OPEN = 3'd1, CLOSE = 3'd2, TIMEOUT = 3'd3, BTNCLICK = 3'd4;

    reg [2:0] r_state;
    reg [25:0] r_dur_cnt;
    reg [2:0] r_step;
    reg [21:0] r_target, r_freq_cnt;
    reg r_buzzer;

    always @(*) begin
        case(r_state)
            OPEN:  case(r_step) 0: r_target = DO; 1: r_target = MI; 2: r_target = SOL; 3: r_target = DDOSHARP; default: r_target = 0; endcase
            CLOSE: case(r_step) 0: r_target = DDOSHARP; 1: r_target = SOL; 2: r_target = MI; 3: r_target = DO; default: r_target = 0; endcase
            TIMEOUT:  r_target = (r_step[0] == 0) ? RA : 0;
            BTNCLICK, IDLE: r_target = (r_state == BTNCLICK) ? SOL : 0;
            default: r_target = 0;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin r_state <= IDLE; r_buzzer <= 0; end
        else begin
            case(r_state)
                IDLE: begin
                    r_dur_cnt <= 0; r_step <= 0;
                    if(btn_open) r_state <= OPEN;
                    else if(btn_close) r_state <= CLOSE;
                    else if(timeout) r_state <= TIMEOUT;
                    else if(btn_start || btn_cancel || btn_speedup) r_state <= BTNCLICK;
                end
                OPEN, CLOSE: begin
                    if(r_dur_cnt >= TIME_500MS - 1) begin
                        r_dur_cnt <= 0;
                        if(r_step == 3) r_state <= IDLE; else r_step <= r_step + 1;
                    end else r_dur_cnt <= r_dur_cnt + 1;
                end
                TIMEOUT: begin
                    if(r_dur_cnt >= TIME_500MS - 1) begin
                        r_dur_cnt <= 0;
                        if(r_step == 5) r_state <= IDLE; else r_step <= r_step + 1;
                    end else r_dur_cnt <= r_dur_cnt + 1;
                end
                BTNCLICK: begin
                    if(r_dur_cnt >= TIME_500MS - 1) r_state <= IDLE;
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