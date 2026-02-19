`timescale 1ns / 1ps

module fnd_controller(
    input clk, 
    input reset,  // switch 15번
    input [13:0] in_data,

    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] d1, d10, d100, d1000;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .sel(w_sel)    // 1ms 마다 00 01 10 11 로 바뀜
    );

    bin2bcd4digit u_bin2bcd4digit (
        .in_data(in_data),
        .d1(d1),
        .d10(d10),
        .d100(d100),
        .d1000(d1000)
    );


    fnd_digit_display u_fnd_digit_display(
        .digit_sel(w_sel),
        .d1(d1),
        .d10(d10),
        .d100(d100),
        .d1000(d1000),

        .an(an),
        .seg(seg)
    );



endmodule





// -----------------------------------------------------------------------------------
//// 1ms 머더 fnd를 dusokay 허가 위해 digit 1자리씩 선택 하는 logic
// 4ms 까지 잔상효과 있음. 그 이상의 시간 지연을 주면 깜빡임 현상 발생 주의 

module fnd_digit_select (
    input clk,
    input reset,
    output reg [1:0] sel    // 1ms 마다 00 01 10 11 로 바뀜
);

// 1ms counter 필요
    reg [$clog2(100_000):0] r_1ms_counter=0;

    always @ (posedge clk, posedge reset) begin
        if (reset) begin
            r_1ms_counter <=0;
            sel <= 0;
        end else begin
            if (r_1ms_counter == 100_000-1) begin
                r_1ms_counter <= 0;
                sel <= sel + 1;
            end else begin
                r_1ms_counter <= r_1ms_counter + 1;
            end
        end

    end
endmodule


//-=------------------------------------------
// inout [13:0] in_data : 14 bit fnd 에 9999까지 표현 하기 위한 bin size 
// 0~9999 천/백/십/일 자리 숫자  
// mux 그림   
//-=------------------------------------------

module bin2bcd4digit (
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);

    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule



module fnd_digit_display (
    input [1:0] digit_sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,

    output reg [3:0] an,
    output reg [7:0] seg
);

    reg [3:0] bcd_data;


    always @(digit_sel) begin   // digit_sel 값이 바뀔 때 언제나 실행. 

        case (digit_sel) 
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

            2'b11 : begin
                bcd_data = d1000;
                an = 4'b0111;

            end
        
            default :begin
                bcd_data = 4'b0000;
                an = 4'b1111;
            end


        endcase

    end


    always @ (bcd_data) begin
        case (bcd_data)
            4'd0 : seg = 8'b11000000;
            4'd1 : seg = 8'b11111001;
            4'd2 : seg = 8'b10100100;
            4'd3 : seg = 8'b10110000;
            4'd4 : seg = 8'b10011001;
            4'd5 : seg = 8'b10010010;
            4'd6 : seg = 8'b10000010;
            4'd7 : seg = 8'b11111000;
            4'd8 : seg = 8'b10000000;
            4'd9 : seg = 8'b10010000;
            default : seg = 8'b11111111;

        endcase
    end
endmodule

