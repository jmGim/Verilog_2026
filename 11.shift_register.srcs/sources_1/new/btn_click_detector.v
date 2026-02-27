`timescale 1ns / 1ps



module btn_click_detector(
    input clk,
    input reset,
    input [1:0] btn,   
    output [1:0] btn_posedge // wire 타입 (assign용)
    );

    reg [1:0] r_btn_reg;

    always @(posedge clk or posedge reset) begin
        if(reset) r_btn_reg <= 2'b0;
        else      r_btn_reg <= btn;
    end

    // 현재 버튼은 1인데, 이전 클럭 버튼은 0일 때 (상승 엣지)
    assign btn_posedge = btn & ~r_btn_reg;
    

    
endmodule
