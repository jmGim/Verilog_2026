`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    // input mode,
  
    input [9:0] in_data,
    input [1:0] motor_direction,
    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100;
    wire w_fnd4;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        // .coffee_make(coffee_make),
        .sel(w_sel),
        .fnd4(w_fnd4)

    );

    bin2bcd4digit u_bin2bcd4digit (
        .in_data(in_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100)
        // .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        // .coffee_make(coffee_make),

        .digit_sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .fnd4(w_fnd4),
        // .d1000(w_d1000),
        .motor_direction(motor_direction),
        .an(an),
        .seg(seg)
    );
endmodule

module fnd_digit_select(
    input clk,
    input reset,
    // input coffee_make,
    output reg [1:0] sel,
    output reg fnd4
);

    reg [16:0] r_1ms_counter;
    reg [8:0] r_500ms_counter;
    // reg [23:0] r_coffee_make_counter;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            sel <= 0;
            r_1ms_counter <= 0;
            r_500ms_counter <= 0;
            fnd4 <= 1'b1;

        end else begin
            if(r_1ms_counter > 17'd100_000 - 1) begin
                r_1ms_counter <= 0;
                sel <= sel + 1;
                if (r_500ms_counter > 9'd500 -1) begin
                    r_500ms_counter <= 0 ;
                    fnd4 <= ~fnd4; 
                end else r_500ms_counter <= r_500ms_counter + 1;
            end else begin
                r_1ms_counter <= r_1ms_counter + 1;
            end


//           // if(coffee_make) begin
            //     if(r_coffee_make_counter >= 24'd10_000_000 - 1) begin // coffee_make시 100ms로 digit 선택
            //         r_coffee_make_counter <= 0;
            //         if(coffee_make_state >= 11) coffee_make_state <= 0;
            //         else coffee_make_state <= coffee_make_state + 1;
            //     end else begin
            //         r_coffee_make_counter <= r_coffee_make_counter + 1;
            //     end
            // end else begin
            //     r_coffee_make_counter <= 0;
            //     coffee_make_state <= 0;
            // end
        end
    end
endmodule

module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1, d10, d100
);

    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    // assign d1000 = (in_data / 1000) % 10;
endmodule

module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1, d10, d100,
    input [1:0] motor_direction,
    input fnd4,

    output reg [3:0] an,
    output reg [7:0] seg
);

    reg [3:0] bcd_data;
    
    // reg [6:0] seg_7;

    // 숫자 선택


    always @(digit_sel, motor_direction) begin
        case(digit_sel)
            2'b00 : begin 
                bcd_data = d1;
                an = 4'b1110;   // 첫 번쨰 digit만 들어옴
            end
            2'b01 : begin
                bcd_data = d10;
                an = 4'b1101;
            end

            2'b10 : begin
                bcd_data = d100;
                an = 4'b1011;

            end
            2'b11: begin
                if (fnd4 == 1'b1) begin
                    an = 4'b1111;
                    // an = 4'b1000;
                    bcd_data = 4'd15;
                end
                else begin
                    an = 4'b0111;
                    if (motor_direction == 2'b10) 
                        bcd_data = 4'd10;
                        
                        
                    else if (motor_direction == 2'b01) 
                        bcd_data = 4'd11;
                end
            end 
            default: bcd_data = 4'd15;
        endcase
    end

    // bcd -> seg
    always @(bcd_data) begin
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
            4'd10: seg = 8'b10001110;      // b
            4'd11 : seg = 8'b10000011;      // F
            4'd15 : seg = 8'b11111111;

            default: seg = 8'b11111111;
        endcase
    end



//   // coffee_make 애니메이션 또는 숫자 출력 선택
    // always @(*) begin

    //     // if (coffee_make) begin // coffee_make == 1 숫자 off / circular 출력
    //     an = 4'b1111; 
    //     seg = 8'hFF;  
            
    //         // case (coffee_make_state)
    //         //     // 상단a
    //         //     4'd0: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11111110; end 
    //         //     4'd1: if(digit_sel == 2'b10) begin an = 4'b1011; seg = 8'b11111110; end
    //         //     4'd2: if(digit_sel == 2'b01) begin an = 4'b1101; seg = 8'b11111110; end
    //         //     4'd3: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111110; end
    //         //     // 우측b,c
    //         //     4'd4: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111101; end
    //         //     4'd5: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11111011; end
    //         //     // 하단d
    //         //     4'd6: if(digit_sel == 2'b00) begin an = 4'b1110; seg = 8'b11110111; end
    //         //     4'd7: if(digit_sel == 2'b01) begin an = 4'b1101; seg = 8'b11110111; end
    //         //     4'd8: if(digit_sel == 2'b10) begin an = 4'b1011; seg = 8'b11110111; end
    //         //     4'd9: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11110111; end
    //         //     // 좌측e,f
    //         //     4'd10: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11101111; end
    //         //     4'd11: if(digit_sel == 2'b11) begin an = 4'b0111; seg = 8'b11011111; end
    //         //     default: begin an = 4'b1111; seg = 8'hFF; end
    //         // endcase
    //     // end else begin
    //         // coffee_make == 0 숫자 표시
    //         case(digit_sel)
    //             2'b00: an = 4'b1110;
    //             2'b01: an = 4'b1101;
    //             2'b10: an = 4'b1011;
    //             2'b11: an = 4'b0111;
    //             default: an = 4'b1111;
    //         endcase
    //         seg =  seg_7;
    //     end
    // end

endmodule