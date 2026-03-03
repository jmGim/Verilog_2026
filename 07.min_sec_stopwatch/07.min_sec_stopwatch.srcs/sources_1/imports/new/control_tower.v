`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset,
    input tick,
    input [2:0] btn,
    output [12:0] seg_data, 
    output [1:0] mode,
    output idle
    );

    parameter WATCH = 2'b00;
    parameter STOPWATCH = 2'b01;
    parameter PAUSE = 2'b10;
    parameter RESET = 2'b11;

    reg [1:0] r_prev_mode, r_mode;
    reg [28:0] r_counter;
    reg [5:0] r_sec_counter, r_min_counter;
    reg r_idle;

    reg [2:0] r_btn_reg;
    wire [2:0] w_btn_posedge;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_btn_reg <= 3'b0;
        end else begin
            r_btn_reg <= btn;
        end
    end

    assign w_btn_posedge = btn & ~r_btn_reg;

    always @(posedge clk or posedge reset) begin // mode control
        if(reset) begin
            r_prev_mode <= WATCH; // 기본 watch
            r_mode <= WATCH;
        end else begin
            case(r_mode)
                WATCH: begin
                    if(w_btn_posedge[0]) begin
                        r_mode <= STOPWATCH;
                    end else if(w_btn_posedge[1])begin
                        r_prev_mode <= WATCH; 
                        r_mode <= PAUSE; 
                    end else if(w_btn_posedge[2]) begin
                        r_mode <= RESET;
                    end
                end

                STOPWATCH: begin
                    if(w_btn_posedge[0])begin
                        r_mode <= WATCH;
                    end else if(w_btn_posedge[1]) begin
                        r_prev_mode <= STOPWATCH;
                        r_mode <= PAUSE; 
                    end else if(w_btn_posedge[2]) begin
                        r_mode <= RESET;
                    end
                end

                PAUSE: begin
                    if(w_btn_posedge[1])begin
                        r_mode <= r_prev_mode;
                    end else if(w_btn_posedge[2])begin
                        r_mode <= RESET;
                    end
                end

                RESET: r_mode <= PAUSE;
    
                default: r_mode <= WATCH;
                
            endcase
        end
    end

    // STOPWATCH의 경우 100ms, WATCH의 경우 1s
    wire [28:0] w_max_count = (r_mode == STOPWATCH) ? 29'd10_000_000 : 29'd100_000_000;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_counter <= 0;
            r_sec_counter <= 0;
            r_min_counter <= 0;
            r_idle <= 0;
        end else begin
            if(w_btn_posedge[0] || w_btn_posedge[1] || w_btn_posedge[2]) begin
                r_counter <= 0;                
            end

            case(r_mode)
                WATCH, STOPWATCH: begin
                    r_idle <= 0;
                    if(r_counter >= w_max_count - 1) begin
                        r_counter <= 0;
                        if(r_sec_counter >= 59) begin

                            r_sec_counter <= 0;
                            r_min_counter <= (r_min_counter >= 59) ? 0 : r_min_counter + 1;
                        end else begin
                            r_sec_counter <= r_sec_counter + 1;
                        end
                    end else begin
                        r_counter <= r_counter + 1;
                    end
                end
                
                PAUSE: begin
                    if(r_counter >= 29'd500_000_000 - 1) begin
                        r_idle <= 1; 
                    end else begin
                        r_idle <= 0;
                        r_counter <= r_counter + 1;
                    end
                end

                default: begin // reset
                    r_counter <= 0;
                    r_sec_counter <= 0;
                    r_min_counter <= 0;
                    r_idle <= 0;
                end
            endcase
        end
    end

    assign mode = r_mode;
    assign idle = r_idle;
    assign seg_data = (r_min_counter * 100) + r_sec_counter;

endmodule