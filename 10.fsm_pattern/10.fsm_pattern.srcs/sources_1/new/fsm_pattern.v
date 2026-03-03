`timescale 1ns / 1ps

module fsm_pattern(
    input wire clk,
    input wire reset,
    input wire in,
    output reg out
    );


    // 상태 정의

    parameter S0 = 3'b000,
                S1 = 3'b001,
                S2 = 3'b010,
                S3 = 3'b011,
                S4 = 3'b101,
                S5 = 3'b110,
                S6 = 3'b111;
                // S1 = 3'b001,

    reg [2:0] current_state = S0;
    reg [2:0] next_state;


    // ------------ -----------------
    // 1. Next State Logic (조합 회로 )
    // 현재 상태(current_state)와 입력(in)을 보고 
    // 다음(next_state)에 어디로 갈지 결정
    // 
    // ------------ -----------------

    always @ (*) begin
        case (current_state)
            S0: next_state = (in) ? S1 : S0;
            S1: next_state = (in) ? S1 : S2;
            S2: next_state = (in) ? S3 : S0;
            S3: next_state = (in) ? S1 : S4;
            S4: next_state = (in) ? S5 : S0;
            S5: next_state = (in) ? S6 : S0;
            S6: next_state = (in) ? S1 : S0;

            default : next_state = S0;   // Latch 방지를 위함. 

        endcase
        
        
    end




    // ------------ -----------------
    // 2. State Register (순차 회로 )
    // 현재 상태 update 하는 회로(D FF)
    // clk의 상승에지에 맞춰 상태 천이
    // ------------ -----------------
    always @ (posedge clk, posedge reset) begin
        if(reset) current_state <= S0;
        else current_state <= next_state;
    end


    // ------------ -----------------
    // 3. Output Logic (조합 회로 )
    // Melay Machine : 현재상태 + 입력에 따라서 출력이 결정
    // Moore Machine : 입력 조건 없이 현재 상태 , 즉 Current_State 만으로 출력을 결정  LED 켜기
    // ------------ -----------------

    always @ (*) begin
        out = 1'b0; // 기본값 설정 : Latch 방지 위함
        case (current_state)
            S6 : begin 
                if (in == 1) out = 1'b1;  // 1010111을 만났으므로 LED ON
                else out = 1'b0;
            end
            default: out = 1'b0;

        endcase

    end

endmodule
