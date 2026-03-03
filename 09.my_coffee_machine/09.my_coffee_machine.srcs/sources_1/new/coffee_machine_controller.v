`timescale 1ns / 1ps

module coffee_machine_controller#(
    parameter COUNT_LIMIT = 50,
    parameter WAIT_5S = 5000 // 1ms tick * 5000 = 5초
)(
    input clk, reset, tick,
    input [2:0] btn_negedge,  
    output reg [13:0] coin_val,
    output [2:0] current_state,
    output coffee_make
);
    parameter IDLE = 3'd0, COIN_IN = 3'd1, RETURN_COIN = 3'd2, 
              COFFEE_OUT = 3'd3, MAKING = 3'd4;
    parameter COFFEE_VAL = 300;

    reg [2:0] r_current_state;
    reg [12:0] r_wait_count;
    reg r_coffee_make;

    assign current_state = r_current_state;
    assign coffee_make = r_coffee_make;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_current_state <= IDLE;
            coin_val <= 0;
            r_coffee_make <= 0;
            r_wait_count <= 0;
        end else begin
            case(r_current_state)
                IDLE : begin
                    r_coffee_make <= 0;
                    if(btn_negedge[0]) begin // 동전 투입
                        coin_val <= coin_val + 14'd100;
                        r_current_state <= IDLE;
                    end else if(btn_negedge[1]) begin // 잔돈 반환
                        coin_val <= 0;
                        r_current_state <= IDLE;
                    end else if(btn_negedge[2]) begin // 커피 추출 버튼
                        if(coin_val >= COFFEE_VAL) begin
                            coin_val <= coin_val - COFFEE_VAL;
                            r_current_state <= MAKING; // 5초 대기 상태 진입
                            r_wait_count <= 0;
                        end
                    end
                end

                MAKING : begin
                    r_coffee_make <= 1; // 애니메이션 활성화
                    if (tick) begin
                        if (r_wait_count >= WAIT_5S - 1) begin
                            r_wait_count <= 0;
                            r_current_state <= IDLE;
                        end else begin
                            r_wait_count <= r_wait_count + 1;
                        end
                    end
                end
                default: r_current_state <= IDLE;
            endcase
        end
    end
endmodule