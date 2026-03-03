`timescale 1ns / 1ps

module top_microwave(
    input clk,
    input reset,
    input [4:0] btn,
    input dir_motor,

    output buzzer,
    output [7:0] seg,
    output [3:0] an,
    output dir_plate,
    output pwm_plate,
    output pwm_door
    );

    wire [4:0] w_btn;
    wire w_toggle;
    wire w_timeout;
    wire [9:0] w_running_time;
    wire w_door_state;

    debouncer u_btn0_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn[0]),
        .clean_btn(w_btn[0])
    );

    debouncer u_btn1_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn[1]),
        .clean_btn(w_btn[1])
    );

    debouncer u_btn2_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn[2]),
        .clean_btn(w_btn[2])
    );

    debouncer u_btn3_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn[3]),
        .clean_btn(w_btn[3])
    );

    debouncer u_btn4_debouncer(
        .clk(clk),
        .reset(reset),
        .btn(btn[4]),
        .clean_btn(w_btn[4])
    );

    timer u_timer(
        .clk(clk),
        .reset(reset),
        .btn_add_time(w_btn[3]),
        .btn_start_stop(w_btn[1]),
        .btn_cancel(w_btn[4]),
        .door_state(w_door_state),
        .toggle(w_toggle),
        .timeout(w_timeout),
        .running_time(w_running_time)
    );

    fnd u_fnd(
        .clk(clk),
        .reset(reset),
        .in_data(w_running_time),
        .an(an),
        .seg(seg),
        .toggle(w_toggle),
        .timeout(w_timeout)
    );

    door u_door(
        .clk(clk),
        .reset(reset),
        .btn_open_close(w_btn[0]),
        .pwm_door(pwm_door),
        .door_state(w_door_state)
    );

    melody u_melody(
        .clk(clk),
        .reset(reset),
        .btn_add_time(w_btn[3]),
        .btn_start_stop(w_btn[1]),
        .btn_cancel(w_btn[4]),
        .btn_speed_up(w_btn[2]),
        .timeout(w_timeout),
        .door_state(w_door_state),
        .buzzer(buzzer)
    );

    motor u_motor(
        .clk(clk),
        .reset(reset),
        .door_state(w_door_state),
        .btn_start_stop(w_btn[1]),
        .btn_cancel(w_btn[4]),
        .btn_speed_up(w_btn[2]),
        .timeout(w_timeout),
        .pwm_plate(pwm_plate)
    );
    
    assign dir_plate = dir_motor;
endmodule
