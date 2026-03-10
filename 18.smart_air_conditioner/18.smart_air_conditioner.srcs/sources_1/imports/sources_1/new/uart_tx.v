`timescale 1ns / 1ps

module uart_tx #(
    parameter BPS = 9600
)(
    input clk,
    input reset,

    input [13:0] current_time, 
    input [13:0] alarm_time,   
    input [7:0]  target_temp,  
    input [7:0]  current_temp, 
    input [7:0]  current_humi, 
    input [3:0]  fan_speed,    

    input tx_start,            

    output reg tx,
    output reg tx_busy,
    output reg tx_done
);

    parameter integer DIVIDER_CNT = 100_000_000 / BPS;

    parameter S_IDLE       = 3'd0;
    parameter S_LOAD_CHAR  = 3'd1;
    parameter S_START_BIT  = 3'd2;
    parameter S_DATA_8BITS = 3'd3;
    parameter S_STOP_BIT   = 3'd4;
    parameter S_NEXT_CHAR  = 3'd5;

    reg [2:0] r_state;
    reg [2:0] r_bit_cnt;
    reg [7:0] r_data_reg;
    reg [6:0] r_char_idx; 
    
    reg [15:0] r_baud_cnt;
    reg r_baud_tick;

    // --- [1. 안전한 데이터 분리 연산 (타이밍 위반 방지)] ---
    // (100으로 나누는 것은 상수 최적화로 인해 안전함)
    wire [4:0] ct_h = current_time / 100;
    wire [5:0] ct_m = current_time % 100;
    wire [4:0] at_h = alarm_time / 100;
    wire [5:0] at_m = alarm_time % 100;

    // BCD 매핑 (/10과 %10을 대체하는 고속 Combinational 로직)
    wire [3:0] cth_10 = (ct_h >= 20) ? 2 : (ct_h >= 10) ? 1 : 0;
    wire [3:0] cth_1  = ct_h - (cth_10 * 10);
    wire [3:0] ctm_10 = (ct_m >= 50) ? 5 : (ct_m >= 40) ? 4 : (ct_m >= 30) ? 3 : (ct_m >= 20) ? 2 : (ct_m >= 10) ? 1 : 0;
    wire [3:0] ctm_1  = ct_m - (ctm_10 * 10);

    wire [3:0] ath_10 = (at_h >= 20) ? 2 : (at_h >= 10) ? 1 : 0;
    wire [3:0] ath_1  = at_h - (ath_10 * 10);
    wire [3:0] atm_10 = (at_m >= 50) ? 5 : (at_m >= 40) ? 4 : (at_m >= 30) ? 3 : (at_m >= 20) ? 2 : (at_m >= 10) ? 1 : 0;
    wire [3:0] atm_1  = at_m - (atm_10 * 10);

    wire [7:0] tt_adj = (target_temp > 99) ? 99 : target_temp;
    wire [3:0] tt_10  = (tt_adj >= 90) ? 9 : (tt_adj >= 80) ? 8 : (tt_adj >= 70) ? 7 : (tt_adj >= 60) ? 6 : (tt_adj >= 50) ? 5 : (tt_adj >= 40) ? 4 : (tt_adj >= 30) ? 3 : (tt_adj >= 20) ? 2 : (tt_adj >= 10) ? 1 : 0;
    wire [3:0] tt_1   = tt_adj - (tt_10 * 10);

    wire [7:0] t_adj = (current_temp > 99) ? 99 : current_temp;
    wire [3:0] t_10  = (t_adj >= 90) ? 9 : (t_adj >= 80) ? 8 : (t_adj >= 70) ? 7 : (t_adj >= 60) ? 6 : (t_adj >= 50) ? 5 : (t_adj >= 40) ? 4 : (t_adj >= 30) ? 3 : (t_adj >= 20) ? 2 : (t_adj >= 10) ? 1 : 0;
    wire [3:0] t_1   = t_adj - (t_10 * 10);

    wire [7:0] h_adj = (current_humi > 99) ? 99 : current_humi;
    wire [3:0] h_10  = (h_adj >= 90) ? 9 : (h_adj >= 80) ? 8 : (h_adj >= 70) ? 7 : (h_adj >= 60) ? 6 : (h_adj >= 50) ? 5 : (h_adj >= 40) ? 4 : (h_adj >= 30) ? 3 : (h_adj >= 20) ? 2 : (h_adj >= 10) ? 1 : 0;
    wire [3:0] h_1   = h_adj - (h_10 * 10);

    wire [7:0] fan_char_1 = (fan_speed == 4'd9) ? 8'h48 : (fan_speed == 4'd7) ? 8'h4C : 8'h4F;
    wire [7:0] fan_char_2 = (fan_speed == 4'd9) ? 8'h49 : (fan_speed == 4'd7) ? 8'h4F : 8'h46;
    wire [7:0] fan_char_3 = (fan_speed == 4'd9) ? 8'h47 : (fan_speed == 4'd7) ? 8'h57 : 8'h46;
    wire [7:0] fan_char_4 = (fan_speed == 4'd9) ? 8'h48 : 8'h20;  

    // --- [2. 통합 출력 문자열 생성기] ---
    reg [7:0] w_current_char;
    always @(*) begin
        case(r_char_idx)
            7'd0: w_current_char=8'h63; 7'd1: w_current_char=8'h75; 7'd2: w_current_char=8'h72; 7'd3: w_current_char=8'h72; 7'd4: w_current_char=8'h65; 7'd5: w_current_char=8'h6E; 7'd6: w_current_char=8'h74; 7'd7: w_current_char=8'h20; 
            7'd8: w_current_char=8'h74; 7'd9: w_current_char=8'h69; 7'd10: w_current_char=8'h6D; 7'd11: w_current_char=8'h65; 7'd12: w_current_char=8'h3A; 7'd13: w_current_char=8'h20; 
            7'd14: w_current_char= cth_10 + 8'h30; 7'd15: w_current_char= cth_1 + 8'h30; 7'd16: w_current_char=8'h68; 7'd17: w_current_char=8'h20; 
            7'd18: w_current_char= ctm_10 + 8'h30; 7'd19: w_current_char= ctm_1 + 8'h30; 7'd20: w_current_char=8'h6D; 7'd21: w_current_char=8'h0D; 7'd22: w_current_char=8'h0A;

            7'd23: w_current_char=8'h61; 7'd24: w_current_char=8'h6C; 7'd25: w_current_char=8'h61; 7'd26: w_current_char=8'h72; 7'd27: w_current_char=8'h6D; 7'd28: w_current_char=8'h20; 
            7'd29: w_current_char=8'h74; 7'd30: w_current_char=8'h69; 7'd31: w_current_char=8'h6D; 7'd32: w_current_char=8'h65; 7'd33: w_current_char=8'h3A; 7'd34: w_current_char=8'h20; 
            7'd35: w_current_char= ath_10 + 8'h30; 7'd36: w_current_char= ath_1 + 8'h30; 7'd37: w_current_char=8'h68; 7'd38: w_current_char=8'h20; 
            7'd39: w_current_char= atm_10 + 8'h30; 7'd40: w_current_char= atm_1 + 8'h30; 7'd41: w_current_char=8'h6D; 7'd42: w_current_char=8'h0D; 7'd43: w_current_char=8'h0A;

            7'd44: w_current_char=8'h74; 7'd45: w_current_char=8'h61; 7'd46: w_current_char=8'h72; 7'd47: w_current_char=8'h67; 7'd48: w_current_char=8'h65; 7'd49: w_current_char=8'h74; 7'd50: w_current_char=8'h20; 
            7'd51: w_current_char=8'h74; 7'd52: w_current_char=8'h65; 7'd53: w_current_char=8'h6D; 7'd54: w_current_char=8'h70; 7'd55: w_current_char=8'h3A; 7'd56: w_current_char=8'h20; 
            7'd57: w_current_char= tt_10 + 8'h30; 7'd58: w_current_char= tt_1 + 8'h30; 7'd59: w_current_char=8'h63; 7'd60: w_current_char=8'h0D; 7'd61: w_current_char=8'h0A;

            7'd62: w_current_char=8'h63; 7'd63: w_current_char=8'h75; 7'd64: w_current_char=8'h72; 7'd65: w_current_char=8'h72; 7'd66: w_current_char=8'h65; 7'd67: w_current_char=8'h6E; 7'd68: w_current_char=8'h74; 7'd69: w_current_char=8'h20; 
            7'd70: w_current_char=8'h74; 7'd71: w_current_char=8'h65; 7'd72: w_current_char=8'h6D; 7'd73: w_current_char=8'h70; 7'd74: w_current_char=8'h3A; 7'd75: w_current_char=8'h20; 
            7'd76: w_current_char= t_10 + 8'h30; 7'd77: w_current_char= t_1 + 8'h30; 7'd78: w_current_char=8'h63; 7'd79: w_current_char=8'h0D; 7'd80: w_current_char=8'h0A;

            7'd81: w_current_char=8'h63; 7'd82: w_current_char=8'h75; 7'd83: w_current_char=8'h72; 7'd84: w_current_char=8'h72; 7'd85: w_current_char=8'h65; 7'd86: w_current_char=8'h6E; 7'd87: w_current_char=8'h74; 7'd88: w_current_char=8'h20; 
            7'd89: w_current_char=8'h68; 7'd90: w_current_char=8'h75; 7'd91: w_current_char=8'h6D; 7'd92: w_current_char=8'h69; 7'd93: w_current_char=8'h3A; 7'd94: w_current_char=8'h20; 
            7'd95: w_current_char= h_10 + 8'h30; 7'd96: w_current_char= h_1 + 8'h30; 7'd97: w_current_char=8'h25; 7'd98: w_current_char=8'h0D; 7'd99: w_current_char=8'h0A;

            7'd100: w_current_char=8'h66; 7'd101: w_current_char=8'h61; 7'd102: w_current_char=8'h6E; 7'd103: w_current_char=8'h20; 
            7'd104: w_current_char=8'h73; 7'd105: w_current_char=8'h70; 7'd106: w_current_char=8'h65; 7'd107: w_current_char=8'h65; 7'd108: w_current_char=8'h64; 7'd109: w_current_char=8'h3A; 7'd110: w_current_char=8'h20; 
            7'd111: w_current_char=fan_char_1; 7'd112: w_current_char=fan_char_2; 7'd113: w_current_char=fan_char_3; 7'd114: w_current_char=fan_char_4; 
            7'd115: w_current_char=8'h0D; 7'd116: w_current_char=8'h0A;

            default: w_current_char = 8'h00;
        endcase
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            r_baud_cnt <= 0; 
            r_baud_tick <= 0;
        end else begin
            if (r_baud_cnt >= DIVIDER_CNT - 1) begin 
                r_baud_cnt <= 0; 
                r_baud_tick <= 1;
            end else begin
                r_baud_cnt <= r_baud_cnt + 1; 
                r_baud_tick <= 0;
            end
        end
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            r_state <= S_IDLE; 
            r_char_idx <= 0; 
            r_bit_cnt <= 0;
            r_data_reg <= 0; 
            tx_done <= 0; 
            tx_busy <= 0; 
            tx <= 1;
        end else begin
           case (r_state) 
                S_IDLE: begin 
                    tx_done <= 0;
                    if (tx_start) begin
                        r_char_idx <= 0;
                        tx_busy <= 1'b1;
                        r_state <= S_LOAD_CHAR;
                    end
                end
                S_LOAD_CHAR: begin
                    r_data_reg <= w_current_char;
                    r_bit_cnt <= 0;
                    r_state <= S_START_BIT;
                end
                S_START_BIT:begin
                    if (r_baud_tick) begin
                        tx <= 1'b0; 
                        r_state <= S_DATA_8BITS;
                    end
                end 
                S_DATA_8BITS: begin 
                    if (r_baud_tick) begin
                       tx <= r_data_reg[r_bit_cnt]; 
                       if (r_bit_cnt == 3'd7) r_state <= S_STOP_BIT;
                       else r_bit_cnt <= r_bit_cnt + 1;
                    end
                end
                S_STOP_BIT: begin 
                    if (r_baud_tick) begin
                        tx <= 1'b1;  
                        r_state <= S_NEXT_CHAR;
                    end
                end
                S_NEXT_CHAR: begin
                    if (r_char_idx >= 7'd116) begin
                        tx_done <= 1; 
                        tx_busy <= 0; 
                        r_state <= S_IDLE;
                    end else begin
                        r_char_idx <= r_char_idx + 1; 
                        r_state <= S_LOAD_CHAR;
                    end
                end
                default : r_state <= S_IDLE;
            endcase
        end
    end
endmodule