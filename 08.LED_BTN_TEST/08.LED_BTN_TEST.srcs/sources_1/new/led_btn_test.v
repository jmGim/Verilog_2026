`timescale 1ns / 1ps

module led_btn_test(
    input clk,
    input reset,
    input btn,   
    output btn_posedge // wire 타입 (assign용)
    );

    reg r_btn_reg;

    always @(posedge clk or posedge reset) begin
        if(reset) r_btn_reg <= 1'b0;
        else      r_btn_reg <= btn;
    end

    // 현재 버튼은 1인데, 이전 클럭 버튼은 0일 때 (상승 엣지)
    assign btn_posedge = btn & ~r_btn_reg;
    
endmodule



/// 글리치 개선
// `timescale 1ns / 1ps

// module led_btn_test(
//     input clk,
//     input reset,
//     input btn,   
//     output reg btn_posedge // reg로 변경하여 글리치 방지
//     );

//     reg r_btn_sync_0;
//     reg r_btn_sync_1;
//     reg r_btn_prev;

//     always @(posedge clk or posedge reset) begin
//         if(reset) begin
//             r_btn_sync_0 <= 1'b0;
//             r_btn_sync_1 <= 1'b0;
//             r_btn_prev   <= 1'b0;
//             btn_posedge  <= 1'b0;
//         end else begin
//             // 1. 2단 동기화 (Metastability 방지)
//             r_btn_sync_0 <= btn;
//             r_btn_sync_1 <= r_btn_sync_0;
            
//             // 2. 이전 상태 저장
//             r_btn_prev <= r_btn_sync_1;
            
//             // 3. 동기식 엣지 검출 (이전엔 0이었고 지금 1인 경우)
//             if (r_btn_sync_1 == 1'b1 && r_btn_prev == 1'b0) begin
//                 btn_posedge <= 1'b1; // 딱 1클럭 동안만 High
//             end else begin
//                 btn_posedge <= 1'b0;
//             end
//         end
//     end
    
// endmodule