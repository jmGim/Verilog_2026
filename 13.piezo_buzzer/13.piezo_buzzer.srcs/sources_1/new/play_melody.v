`timescale 1ns / 1ps


module play_melody(
    input clk, 
    input reset,
    input btnU,  // DO  261.63Hz
    input btnL,  // RE  293.66Hz
    input btnC,  // MI  329.63Hz
    input btnR,  // SOL  392.00Hz
    input btnD,  // RA  440.00Hz
    input btnJC, 

    output buzzer

    );

    // input clk : 100MHz
    // output frequency 

    // ( 100MHz / 원하는 주파수 ) /2  : duty 50%
    localparam DO = 22'd191_112;    // 50% duty 
    localparam RE = 22'd179_265;
    localparam MI = 22'd151_685;
    localparam SOL = 22'd127_551;
    localparam RA = 22'd113_636;
    localparam DDO = 22'd95_056;

    reg [21:0] r_clk_cnt[5:0];  // 2차원 array
    reg [5:0] r_buzzer_frequency;    // 소리 명령
    wire [5:0] btn_arr = {btnJC, btnD, btnR, btnC, btnL, btnU};

    integer i;  // signed 32bits   /  reg [31:0] unsigned 32bits


    always @ (posedge clk, posedge reset) begin
        if(reset) begin
            for (i=0; i < 6; i = i + 1) begin
                r_clk_cnt[i] = 22'd0;
                r_buzzer_frequency[i] <= 1'b0;
            end
        end else begin

            // DO btnU
            if (!btn_arr[0]) begin
                r_clk_cnt[0] <= 0;
                r_buzzer_frequency[0] <= 1'b0;
            end else if(r_clk_cnt[0] >= DO-1 )begin
                r_clk_cnt[0] <= 0;
                r_buzzer_frequency[0] <= ~r_buzzer_frequency[0];                            
            end else r_clk_cnt[0] <= r_clk_cnt[0] + 1;
            
            // RE btnL
            if (!btn_arr[1]) begin
                r_clk_cnt[1] <= 0;
                r_buzzer_frequency[1] <= 1'b0;
               
            end else if(r_clk_cnt[1] >= RE-1 )begin
                r_clk_cnt[1] <= 0;
                r_buzzer_frequency[1] <= ~r_buzzer_frequency[1];                            
            end else r_clk_cnt[1] <= r_clk_cnt[1] + 1;

            // MI btnC
            if (!btn_arr[2]) begin
                r_clk_cnt[2] <= 0;
                r_buzzer_frequency[2] <= 1'b0;
            end else if(r_clk_cnt[2] >= MI-1 )begin
                r_clk_cnt[2] <= 0;
                r_buzzer_frequency[2] <= ~r_buzzer_frequency[2];                            
            end else r_clk_cnt[2] <= r_clk_cnt[2] + 1;

            // SOL btnR
            if (!btn_arr[3]) begin
                r_clk_cnt[3] <= 0;
                r_buzzer_frequency[3] <= 1'b0;
            end else if(r_clk_cnt[3] >= SOL-1 )begin
                r_clk_cnt[3] <= 0;
                r_buzzer_frequency[3] <= ~r_buzzer_frequency[3];                            
            end else r_clk_cnt[3] <= r_clk_cnt[3] + 1;

            // RA btnD
            if (!btn_arr[4]) begin
                r_clk_cnt[4] <= 0;
                r_buzzer_frequency[4] <= 1'b0;
            end else if(r_clk_cnt[4] >= RA-1 )begin
                r_clk_cnt[4] <= 0;
                r_buzzer_frequency[4] <= ~r_buzzer_frequency[4];                            
            end else r_clk_cnt[4] <= r_clk_cnt[4] + 1;

            // DDO btnU
            if (!btn_arr[5]) begin
                r_clk_cnt[5] <= 0;
                r_buzzer_frequency[5] <= 1'b0;
            end else if(r_clk_cnt[5] >= DDO-1 )begin
                r_clk_cnt[5] <= 0;
                r_buzzer_frequency[5] <= ~r_buzzer_frequency[5];                            
            end else r_clk_cnt[5] <= r_clk_cnt[5] + 1;
        end
    end



    // assign buzzer = r_buzzer_frequency[4] |
    //                  r_buzzer_frequency[3] |
    //                   r_buzzer_frequency[2] |
    //                    r_buzzer_frequency[1] |
    //                     r_buzzer_frequency[0] ;
    assign buzzer = |r_buzzer_frequency ;

    // Verilog 축약 or 연산자  → |r_buzzer_frequency
    // 결과 0(false) : 5개 비트가 모두 0일 때 결과가 0
    // 결과 1(true) : 5개 비트 중 어느 하나라도 1일 때 결과가 1

endmodule

