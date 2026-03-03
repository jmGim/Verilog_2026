`timescale 1ns / 1ps

module timer(
    input clk,
    input reset,
    input btn_add_time,
    input btn_start_stop,
    input btn_cancel,
    input door_state,

    output reg toggle,
    output reg timeout,
    output reg [9:0] running_time
    );

    localparam PAUSE = 2'b00;
    localparam RUN = 2'b01;
    localparam FINISHED = 2'b10;
    localparam CANCEL = 2'b11;

    localparam MAX_COUNT = 100_00;

    reg [1:0] mode;
    reg [1:0] r_prev_mode;
    reg [$clog2(MAX_COUNT) - 1 : 0] r_counter;
    reg [5:0] r_sec_counter; // sec max 60

    always @(posedge clk or posedge reset) begin // mode control
        if(reset) begin
            mode <= PAUSE;
            running_time <= 0;
            r_counter <= 0;
            r_sec_counter <= 0;
            r_prev_mode <= FINISHED;
            toggle <= 0;
        end
        else begin
            if(btn_add_time) begin
                if(running_time <= 10'd950) begin
                    running_time <= running_time + ((running_time % 10'd100 >= 10'd50) ? 10'd50 : 10'd10);
                end
            end

            if(door_state) begin
                toggle <= 0;
                mode <= PAUSE;
            end

            case(mode)
                RUN: begin
                    if(btn_start_stop) begin
                        toggle <= 0;
                        mode <= PAUSE;
                    end 
                    else if(btn_cancel) begin
                        mode <= CANCEL;
                    end

                    if(r_counter >= MAX_COUNT - 1) begin
                        r_counter <= 0;
                        if(running_time == 10'd0) begin
                            mode <= FINISHED;
                            r_prev_mode <= RUN;
                        end else begin
                            running_time <= running_time - ((running_time % 10'd100 == 10'd0) ? 10'd41 : 10'd1);
                        end
                    end else begin
                        r_counter <= r_counter + 1;
                    end

                    if(running_time == 0) begin
                        mode <= FINISHED;
                        r_prev_mode <= RUN;
                    end
                end

                PAUSE: begin
                    if(btn_start_stop && !door_state)begin
                        toggle <= 1;
                        mode <= RUN;
                    end 
                    else if(btn_cancel) begin
                        mode <= CANCEL; 
                    end
                end

                FINISHED: begin
                    if(r_prev_mode == RUN) begin
                        toggle <= 0;
                        timeout <= 1;
                        r_prev_mode <= FINISHED;
                    end
                    else begin
                        timeout <= 0;
                        mode <= PAUSE;
                    end
                end

                CANCEL: begin
                    mode <= PAUSE;
                    running_time <= 0;
                    r_counter <= 0;
                    r_sec_counter <= 0;
                    r_prev_mode <= FINISHED;
                    toggle <= 0;
                end
    
                default: mode <= PAUSE;
            endcase
        end
    end
endmodule