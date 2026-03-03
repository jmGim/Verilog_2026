`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input seg_dot,
    input mode,
    input idle,
    input [11:0] in_data,
    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;
    wire [3:0] w_idle_state;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .idle(idle),
        .sel(w_sel),
        .idle_state(w_idle_state)
    );

    bin2bcd4digit u_bin2bcd4digit (
        .in_data({2'b0, in_data}),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100), 
        .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .idle(idle),
        .idle_state(w_idle_state),
        .seg_dot(seg_dot),
        .digit_sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .an(an),
        .seg(seg)
    );
endmodule

module fnd_digit_select(
    input clk,
    input reset,
    input idle,
    output reg [1:0] sel,
    output reg [3:0] idle_state
);

    reg [16:0] r_1ms_counter;
    reg [23:0] r_idle_counter;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            sel <= 0;
            r_1ms_counter <= 0;
            idle_state <= 0;
            r_idle_counter <= 0;
        end else begin
            if(r_1ms_counter >= 17'd100_000 - 1) begin
                r_1ms_counter <= 0;
                sel <= sel + 1;
            end else begin
                r_1ms_counter <= r_1ms_counter + 1;
            end

            if(idle) begin
                if(r_idle_counter >= 24'd10_000_000 - 1) begin // idle시 100ms로 digit 선택
                    r_idle_counter <= 0;
                    if(idle_state >= 11) idle_state <= 0;
                    else idle_state <= idle_state + 1;
                end else begin
                    r_idle_counter <= r_idle_counter + 1;
                end
            end else begin
                r_idle_counter <= 0;
                idle_state <= 0;
            end
        end
    end
endmodule

module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1, d10, d100, d1000
);

    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule

module fnd_digit_display(
    input idle,
    input [3:0] idle_state,
    input seg_dot,
    input [1:0] digit_sel,
    input [3:0] d1, d10, d100, d1000,
    output reg [3:0] an,
    output reg [7:0] seg
);

    reg [3:0] bcd_data;
    reg [6:0] seg_7;

    // 숫자 선택
    always @(*) begin
        case(digit_sel)
            2'b00: bcd_data = d1;
            2'b01: bcd_data = d10;
            2'b10: bcd_data = d100;
            2'b11: bcd_data = d1000;
            default: bcd_data = 4'b0;
        endcase
    end

    // bcd -> seg
    always @(*) begin
        case(bcd_data)
            4'd0: seg_7 = 7'b1000000;
            4'd1: seg_7 = 7'b1111001;
            4'd2: seg_7 = 7'b0100100;
            4'd3: seg_7 = 7'b0110000;
            4'd4: seg_7 = 7'b0011001;
            4'd5: seg_7 = 7'b0010010;
            4'd6: seg_7 = 7'b0000010;
            4'd7: seg_7 = 7'b1111000;
            4'd8: seg_7 = 7'b0000000;
            4'd9: seg_7 = 7'b0010000;
            default: seg_7 = 7'b1111111;
        endcase
    end

    // idle 애니메이션 또는 숫자 출력 선택
    always @(*) begin

        if (idle) begin // idle == 1 숫자 off / circular 출력
            an = 4'b1111; 
            seg = 8'hFF;  
            
            case (idle_state)
                // 상단a
                4'd0: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11111110; end 
                4'd1: if(digit_sel == 2'b10) begin an = 4'b1011; seg = 8'b11111110; end
                4'd2: if(digit_sel == 2'b01) begin an = 4'b1101; seg = 8'b11111110; end
                4'd3: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111110; end
                // 우측b,c
                4'd4: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111101; end
                4'd5: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111011; end
                // 하단d
                4'd6: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11110111; end
                4'd7: if(digit_sel == 2'b01) begin an = 4'b1101; seg = 8'b11110111; end
                4'd8: if(digit_sel == 2'b10) begin an = 4'b1011; seg = 8'b11110111; end
                4'd9: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11110111; end
                // 좌측e,f
                4'd10: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11101111; end
                4'd11: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11011111; end
                default: begin an = 4'b1111; seg = 8'hFF; end
            endcase
        end else begin
            // idle == 0 숫자 표시
            case(digit_sel)
                2'b00: an = 4'b1110;
                2'b01: an = 4'b1101;
                2'b10: an = 4'b1011;
                2'b11: an = 4'b0111;
                default: an = 4'b1111;
            endcase
            seg = {(digit_sel == 2 && seg_dot) ? 1'b0 : 1'b1, seg_7};
        end
    end

endmodule