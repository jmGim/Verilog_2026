`timescale 1ns / 1ps

module data_sender(
    input clk,
    input reset,
    input start_trigger,       // dht11의 data_valid 펄스 (1클럭)
    input [7:0] humidity,
    input [7:0] temperature,
    input tx_busy,
    input tx_done,

    output reg tx_start, 
    output reg [7:0] tx_data
);

    // --- [새로 추가된 변수 1] 상태 머신 제어용 파라미터 및 변수 ---
    parameter S_IDLE_SND  = 2'b00;
    parameter S_START_TX  = 2'b01;
    parameter S_WAIT_BUSY = 2'b10;
    parameter S_WAIT_DONE = 2'b11;

    reg [1:0] r_state_snd;     // 현재 송신 상태를 관리
    reg [3:0] r_send_byte_cnt; // 0~13 까지 총 14바이트를 세는 카운터
    reg sending_flag;          // (유지) 전체 문자열을 보내는 중임을 알리는 플래그

    // --- [새로 추가된 변수 2] 나눗셈 연산을 피하기 위한 BCD 변환 ---
    wire [3:0] w_h_tens, w_h_ones, w_t_tens, w_t_ones;

    // 습도 10의 자리 / 1의 자리 (하드웨어 친화적 디코딩)
    assign w_h_tens = (humidity >= 90) ? 9 :
                      (humidity >= 80) ? 8 :
                      (humidity >= 70) ? 7 :
                      (humidity >= 60) ? 6 :
                      (humidity >= 50) ? 5 :
                      (humidity >= 40) ? 4 :
                      (humidity >= 30) ? 3 :
                      (humidity >= 20) ? 2 :
                      (humidity >= 10) ? 1 : 0;
    assign w_h_ones = humidity - (w_h_tens * 10); // 뺄셈은 합성 시 문제 없음

    // 온도 10의 자리 / 1의 자리
    assign w_t_tens = (temperature >= 90) ? 9 :
                      (temperature >= 80) ? 8 :
                      (temperature >= 70) ? 7 :
                      (temperature >= 60) ? 6 :
                      (temperature >= 50) ? 5 :
                      (temperature >= 40) ? 4 :
                      (temperature >= 30) ? 3 :
                      (temperature >= 20) ? 2 :
                      (temperature >= 10) ? 1 : 0;
    assign w_t_ones = temperature - (w_t_tens * 10);


    // --- [수정된 부분] 2차원 배열 대신 1차원 MUX 사용 ---
    // 현재 r_send_byte_cnt(0~13)에 맞춰 보낼 1바이트(8비트) 문자를 결정
    reg [7:0] w_current_char;
    always @(*) begin
        case (r_send_byte_cnt)
            4'd0:  w_current_char = 8'h48; // 'H'
            4'd1:  w_current_char = 8'h3A; // ':'
            4'd2:  w_current_char = 8'h20; // ' '
            4'd3:  w_current_char = 8'h30 + w_h_tens; // 습도 10의 자리 ASCII
            4'd4:  w_current_char = 8'h30 + w_h_ones; // 습도 1의 자리 ASCII
            4'd5:  w_current_char = 8'h2C; // ','
            4'd6:  w_current_char = 8'h20; // ' '
            4'd7:  w_current_char = 8'h54; // 'T'
            4'd8:  w_current_char = 8'h3A; // ':'
            4'd9:  w_current_char = 8'h20; // ' '
            4'd10: w_current_char = 8'h30 + w_t_tens; // 온도 10의 자리 ASCII
            4'd11: w_current_char = 8'h30 + w_t_ones; // 온도 1의 자리 ASCII
            4'd12: w_current_char = 8'h0D; // '\r'
            4'd13: w_current_char = 8'h0A; // '\n'
            default: w_current_char = 8'h00;
        endcase
    end

    // --- [수정된 부분] 엄격한 Handshake FSM (BPS 무관하게 안정적 동작) ---
    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            tx_start <= 1'b0;
            tx_data <= 8'd0;
            r_send_byte_cnt <= 4'd0;
            sending_flag <= 1'b0;
            r_state_snd <= S_IDLE_SND;
        end else begin
            case (r_state_snd)
                // 1. 대기 상태: DHT11에서 새로운 데이터가 유효(Valid)하다고 신호가 오면 시작
                S_IDLE_SND: begin
                    tx_start <= 1'b0;
                    if (start_trigger && !sending_flag) begin
                        sending_flag <= 1'b1;
                        r_send_byte_cnt <= 4'd0;
                        r_state_snd <= S_START_TX;
                    end
                end
                
                // 2. 전송 지시: MUX에서 1바이트를 꺼내 tx_data에 넣고 시작 신호를 줌
                S_START_TX: begin
                    tx_data <= w_current_char; 
                    tx_start <= 1'b1;          
                    r_state_snd <= S_WAIT_BUSY;
                end
                
                // 3. Busy 대기: UART_tx가 시작 신호를 먹고 전송을 시작(busy=1)할 때까지 대기
                S_WAIT_BUSY: begin
                    if (tx_busy) begin         
                        tx_start <= 1'b0;      // 시작 신호를 다시 0으로 내려줌
                        r_state_snd <= S_WAIT_DONE;
                    end
                end
                
                // 4. Done 대기: UART_tx가 1바이트 전송을 완료(done=1)할 때까지 대기
                S_WAIT_DONE: begin
                    if (tx_done) begin         
                        if (r_send_byte_cnt >= 4'd13) begin // 14바이트 다 보냈으면
                            sending_flag <= 1'b0;           // 전체 플래그 끄고
                            r_state_snd <= S_IDLE_SND;      // 대기 상태로 복귀
                        end else begin                      // 아직 남았으면
                            r_send_byte_cnt <= r_send_byte_cnt + 1; // 다음 글자로 넘어가서
                            r_state_snd <= S_START_TX;      // 다시 전송 지시로 이동
                        end
                    end
                end
            endcase
        end
    end
endmodule