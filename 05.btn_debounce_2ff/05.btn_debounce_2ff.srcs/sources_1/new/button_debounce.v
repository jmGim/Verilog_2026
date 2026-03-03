`timescale 1ns / 1ps


module button_debounce(
    input i_clk, 
    input i_reset,
    input i_btn,
    output o_clean_btn  // 노이즈 제거된 것
    );

    wire w_o_clk;
    wire w_Q1, w_Q2, w_Q2_bar;
    
    clock_80Hz u_clock_80Hz ( 
        .i_clk(i_clk),   // 100MHz  
        .i_reset(i_reset),  // reset switch
        .o_clk(w_o_clk)  // 80Hz
    );


    D_FF u1_D_FF(
        .i_clk(w_o_clk), // 80Hz
        .i_reset(i_reset),
        .D(i_btn),
        .Q(w_Q1)
        // .Qbar()  // 필요없을 때 지정 안해도 됨
    );

    D_FF u2_D_FF(
        .i_clk(w_o_clk), // 80Hz
        .i_reset(i_reset),
        .D(w_Q1),
        .Q(w_Q2)
        // .Qbar()  // 필요없을 때 지정 안해도 됨
    );


    assign w_Q2_bar = ~w_Q2;
    assign o_clean_btn = w_Q1 & w_Q2_bar;

endmodule
