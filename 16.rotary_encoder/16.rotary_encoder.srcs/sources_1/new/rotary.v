`timescale 1ns / 1ps


module rotary(
    input clk,
    input reset,    
    input clean_s1,
    input clean_s2,
    input clean_key,

    output [15:0] led
    );

    reg [1:0] r_direction = 2'b00;  // cw : 01, ccw : 10
    reg [1:0] r_prev_state = 2'b00;  // 11 이전에 01 인지 아니면 10이었는 지
    reg [1:0] r_current_state = 2'b00;
    reg [7:0]  r_counter = 8'h00;


    // s1, s2 
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            r_direction = 2'b00;  // cw : 01, ccw : 10
            r_prev_state = 2'b00;  // 11 이전에 01 인지 아니면 10이었는 지
            r_current_state = 2'b00;
            r_counter = 8'h00;
        end else begin
            r_prev_state <= r_current_state;
            r_current_state <= {clean_s1, clean_s2};

            case ({r_prev_state, r_current_state})     
                4'b0010, 4'b1011, 4'b1101, 4'b0100: begin    // CW : 00 - 10 - 11 - 01 
                    if (r_counter < 8'hff) begin  // overflow
                        r_counter <= r_counter + 1;
                    r_direction <= 2'b01;  // CW
                    end else begin
                        r_counter <= 0;
                    end
                end
                
                4'b0001, 4'b0111, 4'b1110, 4'b1000: begin     // CCW : 00 - 01 - 11 - 10
                    if (r_counter > 8'h00) begin  // underflow
                        r_counter <= r_counter - 1;
                    r_direction <= 2'b10;  // CW
                    end else begin
                        r_counter <= 0;
                    end
                end  

                default : begin
                    r_direction <= 2'b00;   // 상태변화 없을 떄 LED OFF
                    // r_prev_state <= 2'b00;
                    // r_current_state <= 2'b00;
                end

            endcase
        end

    end


    reg r_led_toggle = 1'b0;
    reg r_prev_key = 1'b0;
    
    // key 값
    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            r_led_toggle <= 1'b0;
            r_prev_key <= 1'b0;
        end else begin
            r_prev_key <= clean_key;
            if(!r_prev_key && clean_key) begin
                r_led_toggle <= !r_led_toggle;
            end
        end

    end

    assign led[15:14] = r_direction;
    assign led[13] = r_led_toggle;
    assign led[12:8] = 5'b00000;
    assign led[7:0] = r_counter;

endmodule
