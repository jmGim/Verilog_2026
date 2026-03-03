`timescale 1ns / 1ps

module fnd (
    input clk,
    input reset,
    input [9:0] in_data,
    input timeout,
    input toggle,

    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;
    wire [3:0] w_idle_state;
    wire w_display_mode;
    wire w_blink;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .sel(w_sel),
        .idle_state(w_idle_state),
        .display_mode(w_display_mode),
        .toggle(toggle),
        .timeout(timeout),
        .blink(w_blink)
    );

    bin2bcd4digit u_bin2bcd4digit (
        .in_data(in_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100), 
        .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .idle(w_display_mode == 0),
        .idle_state(w_idle_state),
        .digit_sel(w_sel),
        .blink(w_blink),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .an(an),
        .seg(seg)
    );
endmodule

module fnd_digit_select #(
    parameter DYNAMIC_DRIVE_COUNT = 10, 
    parameter IDLE_COUNT = 5_00,
    parameter NUM_HOLD_COUNT = 50_00,
    parameter BLINK_COUNT = 100_00) ( 

    input clk, reset, toggle, timeout,
    output reg [1:0] sel,
    output reg [3:0] idle_state,
    output reg display_mode,
    output reg blink
);
    reg [$clog2(DYNAMIC_DRIVE_COUNT)-1:0] r_1ms_counter = 0;
    reg [31:0] r_mode_counter = 0;
    
    // Blink 관련 레지스터
    reg [31:0] r_blink_counter = 0;
    reg [2:0] r_blink_step = 0; 

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            sel <= 0;
            r_1ms_counter <= 0;
            idle_state <= 0;
            display_mode <= 0;
            r_mode_counter <= 0;
            r_blink_step <= 0;
            blink <= 0;
        end else begin

            if(r_1ms_counter >= DYNAMIC_DRIVE_COUNT - 1) begin 
                r_1ms_counter <= 0; sel <= sel + 1;
            end else r_1ms_counter <= r_1ms_counter + 1;


            if(timeout && r_blink_step == 0) begin
                r_blink_step <= 1; 
                r_blink_counter <= 0;
            end

            if(r_blink_step > 0) begin
                if(r_blink_counter >= BLINK_COUNT / 2 - 1) begin 
                    r_blink_counter <= 0;
                    if(r_blink_step >= 6) begin
                        r_blink_step <= 0;
                        blink <= 0;
                    end else begin
                        r_blink_step <= r_blink_step + 1;
                        blink <= ~blink;
                    end
                end else r_blink_counter <= r_blink_counter + 1;
            end


            if(toggle) begin
                if(display_mode == 0) begin
                    if(r_mode_counter >= IDLE_COUNT - 1) begin
                        r_mode_counter <= 0;
                        if(idle_state >= 11) begin idle_state <= 0; display_mode <= 1; end
                        else idle_state <= idle_state + 1;
                    end else r_mode_counter <= r_mode_counter + 1;
                end else begin
                    if(r_mode_counter >= NUM_HOLD_COUNT - 1) begin
                        r_mode_counter <= 0; display_mode <= 0;
                    end else r_mode_counter <= r_mode_counter + 1;
                end
            end else begin
                display_mode <= 1;
                idle_state <= 0;
                r_mode_counter <= 0;
            end
        end
    end
endmodule



module bin2bcd4digit(
    input [9:0] in_data,
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
    input [1:0] digit_sel,
    input [3:0] d1, d10, d100, d1000,
    input blink,
    output reg [3:0] an,
    output reg [7:0] seg
);

    reg [3:0] bcd_data;


    always @(*) begin
        case(digit_sel)
            2'b00: bcd_data = d1;
            2'b01: bcd_data = d10;
            2'b10: bcd_data = d100;
            2'b11: bcd_data = d1000;
            default: bcd_data = 4'b0;
        endcase
    end


    always @(*) begin
        if(blink) begin
            an = 4'b1111; 
            seg = 8'hFF; 
        end

        else if (idle) begin 
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
            case(bcd_data)
                4'd0: seg = 8'b11000000;
                4'd1: seg = 8'b11111001;
                4'd2: seg = 8'b10100100;
                4'd3: seg = 8'b10110000;
                4'd4: seg = 8'b10011001;
                4'd5: seg = 8'b10010010;
                4'd6: seg = 8'b10000010;
                4'd7: seg = 8'b11111000;
                4'd8: seg = 8'b10000000;
                4'd9: seg = 8'b10010000;
                default: seg = 8'b11111111;
            endcase

            case(digit_sel)
                2'b00: an = 4'b1110;
                2'b01: an = 4'b1101;
                2'b10: an = 4'b1011;
                2'b11: an = 4'b0111;
                default: an = 4'b1111;
            endcase
        end
    end
endmodule