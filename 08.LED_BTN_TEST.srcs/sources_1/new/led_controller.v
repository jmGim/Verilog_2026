`timescale 1ns / 1ps

module led_controller #(
    parameter COUNT_LIMIT = 50
)(
    input clk,
    input reset,
    input btn,   
    input tick,  
    output reg [15:0] led
);
    reg [1:0] r_mode;
    reg [31:0] r_count;
    reg [3:0] i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_mode <= 0; r_count <= 0; i <= 0; led <= 0;
        end else if (btn) begin
            r_mode <= r_mode + 1;
            r_count <= 0; i <= 0; led <= 0;
        end else if (tick) begin
            if (r_count >= COUNT_LIMIT - 1) begin
                r_count <= 0;
                case(r_mode)
                    2'b00: begin // FIRST: 단일 LED 정방향 이동
                        led <= (16'b1 << i); // i번째만 켜고 나머지는 모두 0
                        if (i == 15) i <= 0;
                        else i <= i + 1;
                    end
                    2'b01: begin // SECOND: 단일 LED 역방향 이동
                        led <= (16'b1 << (15-i)); // (15-i)번째만 켜고 나머지 0
                        if (i == 15) i <= 0;
                        else i <= i + 1;
                    end
                    2'b10: begin // THIRD: Blooming (중앙에서 퍼짐)
                        led <= (16'b1 << (7-i)) | (16'b1 << (8+i)); 
                        if (i == 7) i <= 0;
                        else i <= i + 1;
                    end
                    2'b11: begin // FOURTH: Converging (양끝에서 모임)
                        led <= (16'b1 << i) | (16'b1 << (15-i));
                        if (i == 7) i <= 0;
                        else i <= i + 1;
                    end
                endcase
            end else begin
                r_count <= r_count + 1;
            end
        end
    end
endmodule