`timescale 1ns / 1ps

module dht11 (
    input clk,
    input reset,
    
    inout dht11_data,    // 센서 데이터 핀 하나로 입출력 모두 수행

    output [7:0] humidity,
    output [7:0] temperature,
    output data_valid   // 데이터 정상 수신 시 1클럭 펄스 발생 (UART 전송 트리거)
);

    parameter S_IDLE = 3'b000,
              S_ENQ  = 3'b001,             
              S_MCU_PULLUP_40US = 3'b010,  
              S_DHT_ACK_80US = 3'b011,     
              S_DHT_PULLUP_80US = 3'b100,  
              S_READ_DATA = 3'b101,
              S_CHECKSUM = 3'b110;         // 체크섬 검증용 상태 추가

    parameter WAIT_POSEDGE = 2'b01,
              WAIT_NEGEDGE = 2'b10;

    reg [2:0] r_state;
    reg [2:0] read_state;
    reg [9:0] r_1us_counter;
    
    reg [7:0] r_humidity;
    reg [7:0] r_temperature;
    reg r_data_valid;   // 데이터 정상 수신 시 1클럭 펄스 발생 (UART 전송 트리거)

    // 요청하신 제어용 내부 변수 선언
    reg r_io_mode;
    reg r_o_data;
    wire i_data;
    
    // inout 포트 내부 할당
    assign dht11_data = r_io_mode ? 1'bz : r_o_data;
    assign i_data = dht11_data;

    reg [6:0] r_clk_1us_cnt;        
    reg tick_1us;                   

    reg [31:0] r_wait_counter;      
    reg [5:0]  r_bit_idx;           
    reg [39:0] r_dht_data_reg;      

    // 1us Tick Generator
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

    // 메인 상태 머신
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_state <= S_IDLE;
            read_state <= WAIT_POSEDGE;
            
            r_wait_counter <= 0;
            r_1us_counter <= 0;
            r_bit_idx <= 0;
            r_dht_data_reg <= 0;
            
            r_io_mode <= 1'b1; 
            r_o_data <= 1'b1;
            
            r_humidity <= 0;
            r_temperature <= 0;
            r_data_valid <= 0;
        end else begin
            r_data_valid <= 1'b0; // 매 클럭 초기화 (1클럭 펄스 유지를 위함)
            
            if (tick_1us) begin
                case (r_state)
                    S_IDLE: begin
                        r_io_mode <= 1'b1; 
                        r_wait_counter <= r_wait_counter + 1;
                        r_bit_idx <= 0;
                        
                        // 2초마다 자동으로 온도/습도 스캔
                        if (r_wait_counter >= 32'd2_000_000) begin 
                            r_wait_counter <= 0;
                            r_state <= S_ENQ;
                        end
                    end

                    S_ENQ: begin
                        r_io_mode <= 1'b0; 
                        r_o_data <= 1'b0;  
                        r_wait_counter <= r_wait_counter + 1;
                        if (r_wait_counter >= 32'd18_000) begin 
                            r_wait_counter <= 0;
                            r_state <= S_MCU_PULLUP_40US;
                        end
                    end

                    S_MCU_PULLUP_40US: begin
                        r_io_mode <= 1'b1; 
                        if (i_data == 1'b0) r_state <= S_DHT_ACK_80US;
                    end

                    S_DHT_ACK_80US: begin
                        if (i_data == 1'b1) r_state <= S_DHT_PULLUP_80US;
                    end

                    S_DHT_PULLUP_80US: begin
                        if (i_data == 1'b0) begin
                            r_state <= S_READ_DATA;
                            read_state <= WAIT_POSEDGE;
                        end
                    end

                    S_READ_DATA: begin
                        case (read_state)
                            WAIT_POSEDGE: begin
                                if (i_data == 1'b1) begin
                                    r_1us_counter <= 0;
                                    read_state <= WAIT_NEGEDGE; 
                                end
                            end
                            WAIT_NEGEDGE: begin
                                r_1us_counter <= r_1us_counter + 1;
                                if (i_data == 1'b0) begin
                                    // 40비트 데이터 순차 저장
                                    r_dht_data_reg[39 - r_bit_idx] <= (r_1us_counter > 10'd45) ? 1'b1 : 1'b0;
                                    
                                    if (r_bit_idx >= 6'd39) begin
                                        r_state <= S_CHECKSUM; // 40비트 수신 완료 시 검증 단계로
                                    end else begin
                                        r_bit_idx <= r_bit_idx + 1;
                                        read_state <= WAIT_POSEDGE; 
                                    end
                                end
                            end
                        endcase
                    end

                    S_CHECKSUM: begin
                        // Checksum 로직: 4개의 8비트 데이터를 더한 값이 마지막 8비트(체크섬)와 일치하는지 확인
                        if ((r_dht_data_reg[39:32] + r_dht_data_reg[31:24] + r_dht_data_reg[23:16] + r_dht_data_reg[15:8]) == r_dht_data_reg[7:0]) begin
                            r_humidity <= r_dht_data_reg[39:32];
                            r_temperature <= r_dht_data_reg[23:16];
                            r_data_valid <= 1'b1; // 정상일 때만 전송 트리거 발동
                        end
                        r_state <= S_IDLE; 
                    end

                    default: r_state <= S_IDLE;
                endcase
            end
        end
    end

    assign humidity = r_humidity;
    assign temperature = r_temperature;
    assign data_valid = r_data_valid;

endmodule