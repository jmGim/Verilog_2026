`timescale 1ns / 1ps

module coffee_machine(
    input clk,   // 100MHz
    input reset,  // reset btn, active high
    input coin,   // 동전 투입 100원 단위
    input return_coin_btn,  // 동전반환 버튼
    input coffee_btn,
    input coffee_out,    // 커피 배출 완료

    output reg [15:0] coin_val,    // 현재의 금액 표시
    output reg seg_en,   // FND 활성화 신호
    output reg coffee_make,  // 커피 제조 시작 신호
    output reg coin_return   // 동전반환 동작 신호
    );

    parameter IDLE = 3'd0,
            COIN_IN = 3'd1,
            READY = 3'd2,
            COFFEE = 3'd3,
            COIN_OUT = 3'd4;


    parameter COFFEE_VAL = 300;  // COFFEE 가격


    reg [2:0] r_current_state = IDLE;
    reg [2:0] r_next_state;


    // coin 투입 check logic
    reg r_coin_reg;
    wire w_coin_pulse;  // edge detect

    always @ (posedge clk, posedge reset)  begin    // 10ns 마다 코인 값 읽음
        if (reset) r_coin_reg <= 0;  
        else r_coin_reg <= coin;   
    end

    assign w_coin_pulse = (coin && !r_coin_reg);   // 상승 엣지 검출  이유 ----------------?

    always @(*) begin    // 
        r_next_state = r_current_state;
        case(r_current_state) 
            IDLE : begin
                if (w_coin_pulse) r_next_state = COIN_IN;
            end
            COIN_IN : begin
                if (return_coin_btn) r_next_state = COIN_OUT;
                else if (coin_val >= COFFEE_VAL) r_next_state = READY;
            end
            READY : begin
                if (coin_val < COFFEE_VAL || return_coin_btn) 
		r_next_state = COIN_OUT; // 잔액부족 || 반환 버튼 시 반환상태로
                else if (coffee_btn) r_next_state = COFFEE;
            end
            COFFEE : begin
                if (coffee_out) r_next_state = READY;    // 커피 제조 완료 시 READY로 복귀
            end
            COIN_OUT : begin
                if (coin_val == 0) r_next_state = IDLE;    // 잔액 모두 반환 시 IDLE로
            end

            default: r_next_state = IDLE;

        endcase

    end


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_current_state = IDLE;
        end else begin
            r_current_state <= r_next_state;
        end

    end


    // 동전 증감, 차감 add sub logic 기능
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            coin_val <= 0;
            // r_current_state = 
        end else begin
            // edge 검출 통해 어떤 상태든지 동전 투입시 한 번만 가산하는 logic 추가
            if (w_coin_pulse && (r_current_state == IDLE || r_current_state == COIN_IN || r_current_state == READY)) begin
                coin_val <= coin_val + 16'd100;    // 100won 짜리 동전
            end 


            if (r_current_state == COFFEE && coffee_out) begin
                coin_val <= coin_val - COFFEE_VAL;    // 300won 차감
            end 


            if (r_current_state == COIN_OUT) begin
                coin_val <= 16'd0;
            end
        end

    end


    // output logic (조합 회로)
    always @ (*) begin
        seg_en = 0;
        coffee_make = 0; 
        coin_return = 0;
        case (r_current_state) 
            IDLE : ;
            COIN_IN : seg_en = 1;
            READY :   seg_en = 1;           
            COFFEE : begin
                seg_en = 1;
                coffee_make = 1;
                // coin_return = 0;
            end
            COIN_OUT : begin
                seg_en = 1;
                // coffee_make = 0;
                coin_return = 1;

            end

            // default: r_next_state = IDLE;
        endcase

    end
endmodule
