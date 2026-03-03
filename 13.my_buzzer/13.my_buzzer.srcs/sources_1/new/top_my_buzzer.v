`timescale 1ns / 1ps

module top_buzzer(
    input clk, 
    input reset,
    // input btnU,  // DO
    input btnL,  // RE
    // input btnC,  // MI
    input btnR,  // SOL
    // input btnD,  // RA
    // input btnJC,  // DO Octabe

    // output [1:0] led,
    output buzzer

    );

    // wire w_btnU;
    wire w_btnL;
    // wire w_btnC;
    wire w_btnR;
    // wire w_btnD;
    // wire w_btnJC;


    // debouncer u_btnU_debouncer (
    //     .clk(clk),
    //     .reset(reset),
    //     .noisy_btn(btnU),  // raw noisy button input
    //     .clean_btn(w_btnU)
    // );

     debouncer u_btnL_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnL),  // raw noisy button input
        .clean_btn(w_btnL)
    );

    //  debouncer u_btnC_debouncer (
    //     .clk(clk),
    //     .reset(reset),
    //     .noisy_btn(btnC),  // raw noisy button input
    //     .clean_btn(w_btnC)
    // );

     debouncer u_btnR_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnR),  // raw noisy button input
        .clean_btn(w_btnR)
    );

    //  debouncer u_btnD_debouncer (
    //     .clk(clk),
    //     .reset(reset),
    //     .noisy_btn(btnD),  // raw noisy button input
    //     .clean_btn(w_btnD)
    // );

    // debouncer u_btnJC_debouncer (
    //     .clk(clk),
    //     .reset(reset),
    //     .noisy_btn(btnJC),  // raw noisy button input
    //     .clean_btn(w_btnJC)
    // );

    
    play_melody u_play_melody(
        .clk(clk), 
        .reset(reset),
        // .btnU(w_btnU),  // DO  261.63Hz
        .btnL(w_btnL),  // RE  293.66Hz
        // .btnC(w_btnC),  // MI  329.63Hz
        .btnR(w_btnR),  // SOL  392.00Hz
        // .btnD(w_btnD),  // RA  440.00Hz
        // .btnJC(w_btnJC),
        
        .buzzer(buzzer)
    );

endmodule
