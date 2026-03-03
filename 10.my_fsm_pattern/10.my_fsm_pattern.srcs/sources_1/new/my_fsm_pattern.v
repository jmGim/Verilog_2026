`timescale 1ns / 1ps


module my_fsm_pattern(
    input wire clk,
    input wire reset,
    input wire din_bit,
    output reg detect_out
    );


    // 상태 정의

    parameter start = 3'b000,
                st1 = 3'b001,
                st2 = 3'b010,
                st3 = 3'b011,
                st4 = 3'b101;

    reg [2:0] current_state = start;
    reg [2:0] next_state;

    // ------------ -----------------
    // 1. Next State Logic (조합 회로 )
    // 현재 상태(current_state)와 입력(din_bit)을 보고 
    // 다음(next_state)에 어디로 갈지 결정
    // 
    // ------------ -----------------

    always @ (*) begin
        case (current_state)
            start: next_state = (din_bit) ? start : st1;
            st1: next_state = (din_bit) ? st2 : st1;
            st2: next_state = (din_bit) ? st3 : st1;
            st3: next_state = (din_bit) ? start : st4;
            st4: next_state = (din_bit) ? st2 : st1;
            
            default : next_state = start;   // Latch 방지를 위함. 

        endcase
    end


    // ------------ -----------------
    // 2. State Register (순차 회로 )
    // 현재 상태 update 하는 회로(D FF)
    // clk의 상승에지에 맞춰 상태 천이
    // ------------ -----------------
    always @ (posedge clk, posedge reset) begin
        if(reset) current_state <= start;
        else current_state <= next_state;
    end



    // ------------ -----------------
    // 3. Output Logic (조합 회로 )
    // Melay Machine : 현재상태 + 입력에 따라서 출력이 결정
    // Moore Machine : 입력 조건 없이 현재 상태 , 즉 Current_State 만으로 출력을 결정  LED 켜기
    // ------------ -----------------

    always @ (*) begin
        detect_out = 1'b0; // 기본값 설정 : Latch 방지 위함
        case (current_state)
            st3 : begin 
                if (din_bit == 0) detect_out = 1'b1;  
                else detect_out = 1'b0;
            end
            default: detect_out = 1'b0;
        endcase
    end

endmodule
