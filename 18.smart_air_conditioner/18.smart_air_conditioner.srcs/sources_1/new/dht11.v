`timescale 1ns / 1ps

module dht11 (
    input clk,
    input reset,
    
    inout dht11_data,

    output reg [7:0] humidity,
    output reg [7:0] temperature,
    output reg data_valid   
);

    parameter S_IDLE            = 3'd0;
    parameter S_REQ_LOW_18MS    = 3'd1;
    parameter S_WAIT_ACK_20US   = 3'd2;
    parameter S_ACK_LOW_80US    = 3'd3;
    parameter S_ACK_HIGH_80US   = 3'd4;
    parameter S_READ_DATA       = 3'd5;
    parameter S_CHECKSUM        = 3'd6;

    parameter S_WAIT_POSEDGE = 1'b0;
    parameter S_WAIT_NEGEDGE = 1'b1;

    reg [2:0] r_state;
    reg r_read_state;
    reg [5:0] r_bit_cnt;
    reg [21:0] r_wait_cnt;     // 최대 3초 (3,000,000 us) 대기용
    reg [39:0] r_dht_data_reg;
    
    // --- [1. 멈추지 않는 1us 타이머 생성 (100MHz 기준)] ---
    reg [6:0] r_clk_1us_cnt;        
    reg tick_1us;                   
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_clk_1us_cnt <= 0;
            tick_1us <= 0;
        end else begin
            if (r_clk_1us_cnt >= 7'd99) begin 
                r_clk_1us_cnt <= 0;
                tick_1us <= 1'b1;
            end else begin 
                r_clk_1us_cnt <= r_clk_1us_cnt + 1;
                tick_1us <= 1'b0;
            end
        end
    end

    // --- [2. Inout 핀 제어 (Open-Drain 방식)] ---
    reg dht_drive;
    // dht_drive가 1이면 MCU가 LOW로 강제로 끌어내림, 0이면 선을 놓음(High-Z)
    assign dht11_data = dht_drive ? 1'b0 : 1'bz; 

    // 입력 신호 동기화 및 엣지(Edge) 검출 (글리치 방지)
    reg d1_data, d2_data;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            d1_data <= 1'b1;
            d2_data <= 1'b1;
        end else begin
            d1_data <= dht11_data; 
            d2_data <= d1_data;
        end
    end
    wire falling_edge = (d2_data == 1'b1 && d1_data == 1'b0);
    wire rising_edge  = (d2_data == 1'b0 && d1_data == 1'b1);

    // --- [3. 메인 FSM] ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_state <= S_IDLE;
            r_read_state <= S_WAIT_POSEDGE;
            dht_drive <= 1'b0; // 초기값은 0 (High-Z)
            r_wait_cnt <= 0; 
            r_bit_cnt <= 0; 
            r_dht_data_reg <= 0;
            humidity <= 0; 
            temperature <= 0;
            data_valid <= 0;
        end else begin
            data_valid <= 1'b0; // 매 클럭마다 초기화 (1클럭 펄스 유지용)
            
            // [핵심] Enable 없이 무조건 카운트 증가. 
            // 상태가 바뀔 때(이벤트 발생 시) 0으로 리셋하여 시간을 측정함.
            if (tick_1us) begin
                r_wait_cnt <= r_wait_cnt + 1; 
            end

            case (r_state)
                S_IDLE: begin
                    dht_drive <= 1'b0; // 선을 놓음 (High-Z)
                    if (r_wait_cnt >= 22'd3_000_000) begin // 3초 대기
                        r_wait_cnt <= 0; // 상태 전환 시 카운터 리셋
                        r_state <= S_REQ_LOW_18MS; 
                    end
                end

                S_REQ_LOW_18MS: begin
                    dht_drive <= 1'b1; // MCU가 LOW 출력 (Start 신호)
                    if (r_wait_cnt >= 22'd20_000) begin // 20ms 유지
                        r_wait_cnt <= 0;
                        dht_drive <= 1'b0; // MCU가 선을 놓음
                        r_state <= S_WAIT_ACK_20US;
                    end
                end

                S_WAIT_ACK_20US: begin
                    if (falling_edge) begin // DHT11이 응답하여 LOW로 끌어내림
                        r_wait_cnt <= 0;
                        r_state <= S_ACK_LOW_80US;
                    end else if (r_wait_cnt > 22'd100) begin // 타임아웃 (에러 방지)
                        r_wait_cnt <= 0;
                        r_state <= S_IDLE;
                    end
                end

                S_ACK_LOW_80US: begin
                    if (rising_edge) begin // DHT11이 HIGH로 올림 (80us 통과)
                        r_wait_cnt <= 0;
                        r_state <= S_ACK_HIGH_80US;
                    end else if (r_wait_cnt > 22'd150) begin // 타임아웃
                        r_wait_cnt <= 0;
                        r_state <= S_IDLE;
                    end
                end

                S_ACK_HIGH_80US: begin
                    if (falling_edge) begin // 데이터 전송 시작 (다시 LOW)
                        r_wait_cnt <= 0;
                        r_bit_cnt <= 0;
                        r_read_state <= S_WAIT_POSEDGE;
                        r_state <= S_READ_DATA;
                    end else if (r_wait_cnt > 22'd150) begin // 타임아웃
                        r_wait_cnt <= 0;
                        r_state <= S_IDLE;
                    end
                end

                S_READ_DATA: begin
                    case (r_read_state) 
                        S_WAIT_POSEDGE : begin
                            if (rising_edge) begin // 50us LOW 구간 끝
                                r_wait_cnt <= 0; // HIGH 구간 길이를 재기 위해 리셋
                                r_read_state <= S_WAIT_NEGEDGE;
                            end else if (r_wait_cnt > 22'd100) begin
                                r_wait_cnt <= 0;
                                r_state <= S_IDLE;
                            end
                        end

                        S_WAIT_NEGEDGE : begin
                            if (falling_edge) begin // HIGH 구간 끝
                                // HIGH 길이에 따라 0, 1 판별 후 Shift Register에 저장
                                r_dht_data_reg <= {r_dht_data_reg[38:0], (r_wait_cnt > 22'd45) ? 1'b1 : 1'b0};
                                r_bit_cnt <= r_bit_cnt + 1;
                                r_wait_cnt <= 0; // 다음 비트를 위해 리셋
                                
                                if (r_bit_cnt >= 6'd39) begin
                                    r_state <= S_CHECKSUM;
                                end else begin
                                    r_read_state <= S_WAIT_POSEDGE;
                                end
                            end else if (r_wait_cnt > 22'd150) begin // 1이 너무 길면 오류
                                r_wait_cnt <= 0;
                                r_state <= S_IDLE;
                            end
                        end 
                    endcase
                end

                S_CHECKSUM: begin
                    // 데이터 무결성 검증
                    if ((r_dht_data_reg[39:32] + r_dht_data_reg[31:24] + r_dht_data_reg[23:16] + r_dht_data_reg[15:8]) == r_dht_data_reg[7:0]) begin
                        humidity <= r_dht_data_reg[39:32];
                        temperature <= r_dht_data_reg[23:16];
                        data_valid <= 1'b1; // 완벽한 데이터일 때만 UART 트리거!
                    end
                    r_wait_cnt <= 0;
                    r_state <= S_IDLE; 
                end
                
                default: r_state <= S_IDLE;
            endcase
        end
    end
endmodule