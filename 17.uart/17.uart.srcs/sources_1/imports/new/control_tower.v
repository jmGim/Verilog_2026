`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset,  // sw[15]
    input [2:0] btn,   // btn[0]: btnL btn[1]: btnC btn[2]: btnR
    input [7:0] sw,
    input [7:0] rx_data,  // UART 8bit data
    input rx_done,  // 1byte data arrive → 1

    output [13:0] seg_data,
    output reg [15:0] led
    );
    // mode define 
    parameter UP_COUNTER = 3'b01;
    parameter DOWN_COUNTER = 3'b10;
    parameter SLIDE_SW_READ = 3'b11;

    reg r_prev_btnL=0;
    reg [2:0] r_mode=3'b000;
    reg [19:0] r_counter; // 10ms 를 재기 위한 counter 10ns * 1000000
    reg [13:0] r_ms10_counter;  // 10ms가 될때 마다 1 증가  9999 


    reg [55:0] char_buffer; // 2바이트 저장 공간

    parameter [47:0] led0on = {8'h6E, 8'h6F, 8'h30, 8'h64, 8'h65, 8'h6C };
    parameter [55:0] led0off = {8'h66, 8'h66, 8'h6F, 8'h30, 8'h64, 8'h65, 8'h6C };



        // control_tower.v 수정 및 추가 부분

    // 1. 문자열 파라미터 정의 (ASCII 값으로 정정 및 비트 수 지정)
    // "led0on"  : l(6C), e(65), d(64), 0(30), o(6F), n(6E) -> 6 bytes (48 bits)
    // "led0off" : l(6C), e(65), d(64), 0(30), o(6F), f(66), f(66) -> 7 bytes (56 bits)
    // parameter [47:0] LED0ON  = {8'h6C, 8'h65, 8'h64, 8'h30, 8'h6F, 8'h6E}; 
    // parameter [55:0] LED0OFF = {8'h6C, 8'h65, 8'h64, 8'h30, 8'h6F, 8'h66, 8'h66};

    // 2. Circular Queue용 변수 추가
    // reg [7:0] queue [0:7];    // 8칸짜리 1바이트 큐
    reg [7:0] queue [7:0];    // 8칸짜리 1바이트 큐

    reg [2:0] cq_ptr = 0;     // 쓰기 포인터

    // 3. 비교를 위한 가상 윈도우 (큐의 내용을 일렬로 나열)
    // 순환 큐의 현재 포인터 기준으로 직전 7글자를 조합하여 문자열을 만듭니다.
    wire [55:0] cq_string; 
    assign cq_string = { queue[(cq_ptr-7)%8], queue[(cq_ptr-6)%8], 
                        queue[(cq_ptr-5)%8], queue[(cq_ptr-4)%8], 
                        queue[(cq_ptr-3)%8], queue[(cq_ptr-2)%8], 
                        queue[(cq_ptr-1)%8] };

    // 4. 로직 구현 (rx_done 시점에 동작)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cq_ptr <= 0;
            led[0] <= 0;
            // 큐 초기화 (옵션)
            queue[0] <= 0; queue[1] <= 0; queue[2] <= 0; queue[3] <= 0;
            queue[4] <= 0; queue[5] <= 0; queue[6] <= 0; queue[7] <= 0;
        end else if (rx_done) begin
            // 큐에 데이터 저장 및 포인터 이동
            // if (((cq_ptr + 1) % 8 ) == 0 )
            //     led[7:0] = 1;

            queue[cq_ptr] <= rx_data; 
            cq_ptr <= cq_ptr + 1;

            // 문자열 전체 비교 (cq_string의 상위/하위 비트를 이용)
            // led0on 비교 (마지막 6글자 확인)
            if (cq_string[47:0] == led0on) begin
                led[0] <= 1'b1;
            end 
            // led0off 비교 (마지막 7글자 확인)
            else if (cq_string == led0off) begin
                led[0] <= 1'b0;
            end
        end
    end

    // mode check 
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_mode <=0;
            r_prev_btnL <=0;
        end else begin
            // if (btn[0] && !r_prev_btnL)
            //     r_mode = (r_mode == SLIDE_SW_READ ) ? UP_COUNTER : r_mode + 1;
            // if (rx_done && rx_data ==8'h4D) begin
            //     led[0] <= ~led[0];
            // end
            // if (rx_done && rx_data) begin
            //     char_buffer <= {char_buffer[47:0], rx_data};
            // end
            
            // if ( char_buffer == 56'h6C6564306F6E20) led[0] <= 1;
            // else if ( char_buffer == 56'h6C6564306F6666) led[0] <= 0;
        end
        r_prev_btnL <= btn[0];
    end 

   

// up counter
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter <=0; 
            r_ms10_counter <=0;
        end else if (r_mode == UP_COUNTER) begin  // 1. add logic 
            if (r_counter >= 20'd1_000_000-1) begin  // 10ms
                r_counter <=0;
                if (r_ms10_counter >= 9999)  // 9999도달시 0
                    r_ms10_counter <= 0;
                else r_ms10_counter <= r_ms10_counter + 1;
                // led[13:0] <= r_ms10_counter;
            end else begin
                r_counter <= r_counter + 1;
            end
        end else if (r_mode == DOWN_COUNTER) begin  // 2. sub logic 
            if (r_counter == 20'd1_000_000-1) begin  // 10ms
                r_counter <= 0;
                if (r_ms10_counter == 0)  // 0도달시 9999
                    r_ms10_counter <= 9999;
                else r_ms10_counter <= r_ms10_counter - 1;
                // led[13:0] <= r_ms10_counter;
            end else begin
                r_counter <= r_counter + 1;
            end
        end  else begin   // 3. SLIDE_SW_READ or IDLE mode 
            r_counter <=0; 
            r_ms10_counter <=0;
        end 
    end

    //--- led mode display 
    always @(r_mode) begin   // r_mode가 변경 될때 실행
        case (r_mode)
            UP_COUNTER: begin 
                // led[15:14] <= UP_COUNTER;
            end 
            DOWN_COUNTER: begin
                // led[15:14] <= DOWN_COUNTER;
            end 
            SLIDE_SW_READ: begin  
                // led[15:14] <= SLIDE_SW_READ;
            end 
            default: 
                 led[15:14] <= 2'b00;
        endcase
    end 

    assign seg_data = (r_mode == UP_COUNTER) ? r_ms10_counter :
                    (r_mode == DOWN_COUNTER) ? r_ms10_counter : sw;
    // assign led = seg_data;
endmodule
