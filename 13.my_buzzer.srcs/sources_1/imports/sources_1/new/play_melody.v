`timescale 1ns / 1ps

module play_melody(
    input clk, 
    input reset,
    input btnU, btnL, btnC, btnR, btnD, btnJC, 
    output buzzer
);

    // 주파수 파라미터 
    localparam DO  = 22'd191_112;
    localparam MI  = 22'd151_685;
    localparam SOL = 22'd127_551;
    localparam DDOSHARP = 22'd90_252;

    localparam KHz1 = 22'd50_000;
    localparam KHz2 = 22'd25_000;
    localparam KHz3 = 22'd16_667;
    localparam KHz4 = 22'd12_500;

    localparam TIME_70MS = 27'd70_000_000; // 70ms @ 100MHz

    // 상태 정의
    localparam IDLE = 2'd0, STATE_R = 2'd1, STATE_L = 2'd2;

    reg [1:0]  r_state;         // 현재 상태
    reg [21:0] r_freq_cnt;      // 주파수 생성용 카운터
    reg [25:0] r_duration_cnt;  // 70ms 음 길이용 카운터
    reg [1:0]  r_note_step;     // 4단계 음 인덱스
    reg [21:0] r_target_limit;  // 현재 출력 주파수 값
    reg        r_buzzer_frequency;    // 부저 출력 레지스터

    // 현재 상태와 단계에 따른 주파수 선택 (조합 논리)
    always @(*) begin
        case (r_state)
            STATE_R: begin
                case (r_note_step)
                    2'd0: r_target_limit = DO;
                    2'd1: r_target_limit = MI;
                    2'd2: r_target_limit = SOL;
                    2'd3: r_target_limit = DDOSHARP;
                    default: r_target_limit = DO;
                endcase
            end
            STATE_L: begin
                case (r_note_step)
                    2'd0: r_target_limit = KHz1;
                    2'd1: r_target_limit = KHz2;
                    2'd2: r_target_limit = KHz3;
                    2'd3: r_target_limit = KHz4;
                    default: r_target_limit = KHz1;
                endcase
            end
            default: r_target_limit = 22'd0;
        endcase
    end

    // 메인 FSM 및 카운터 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_state        <= IDLE;
            r_freq_cnt     <= 0;
            r_duration_cnt <= 0;
            r_note_step    <= 0;
            r_buzzer_frequency   <= 0;
        end else begin
            case (r_state)
                IDLE: begin
                    r_freq_cnt     <= 0;
                    r_duration_cnt <= 0;
                    r_note_step    <= 0;
                    r_buzzer_frequency   <= 0;
                    
                    // 버튼이 눌리면 해당 상태로 진입 (재생 시작)
                    if (btnR)      r_state <= STATE_R;
                    else if (btnL) r_state <= STATE_L;
                end

                STATE_R, STATE_L: begin
                    // 1. 주파수 생성 (부저 떨림)
                    if (r_freq_cnt >= r_target_limit - 1) begin
                        r_freq_cnt   <= 0;
                        r_buzzer_frequency <= ~r_buzzer_frequency;
                    end else begin
                        r_freq_cnt   <= r_freq_cnt + 1;
                    end

                    // 2. 음 지속 시간 및 단계 제어
                    if (r_duration_cnt >= TIME_70MS - 1) begin
                        r_duration_cnt <= 0;
                        if (r_note_step == 2'd3) begin
                            // 4단계(0,1,2,3)를 모두 마쳤으므로 정지
                            r_state <= IDLE;
                        end else begin
                            r_note_step <= r_note_step + 1;
                        end
                    end else begin
                        r_duration_cnt <= r_duration_cnt + 1;
                    end
                end
            endcase
        end
    end

    assign buzzer = r_buzzer_frequency;

endmodule