`timescale 1ns / 1ps

module tb_fnd();

    // 1. 입력 및 출력 변수 선언
    reg clk;
    reg reset;
    
    // FND에 표시될 데이터들
    reg [7:0] t_temp;
    reg [7:0] t_humid;
    reg [13:0] t_trc_time;
    reg [7:0] t_is_editing_target_temp;
    
    // 제어 버튼들
    reg t_btnL;
    reg t_btnC;
    reg t_btnR;

    // FND 출력 핀들
    wire [3:0] w_an;
    wire [7:0] w_seg;

    // 2. FND 모듈 인스턴스화
    fnd u_fnd (
        .clk(clk),
        .reset(reset),
        .temp(t_temp),
        .humid(t_humid),
        .trc_time(t_trc_time),
        .is_editing_target_temp(t_is_editing_target_temp),
        .btnL(t_btnL),
        .btnC(t_btnC),
        .btnR(t_btnR),
        .an(w_an),
        .seg(w_seg)
    );

    // 3. 100MHz 클럭 생성 (1주기 10ns)
    always #5 clk = ~clk;

    // 4. 시뮬레이션 시나리오
    initial begin
        // --- 초기화 ---
        clk = 0;
        reset = 1;
        t_btnL = 0; t_btnC = 0; t_btnR = 0;
        
        // 사용자가 확인한 데이터 세팅
        t_temp = 8'd23;                       // 온도 23
        t_humid = 8'd6;                       // 습도 6 (FND에는 '0623'으로 표시될 것)
        t_trc_time = 14'd1234;                // 시간 1234
        t_is_editing_target_temp = 8'd28;     // 타겟 온도 28
        
        #100;
        reset = 0;
        
        // --- 시나리오 1: 기본 모드 (온습도 0623 표시) ---
        $display("[%0t] 시나리오 1: 초기 상태 (온습도 화면 대기)", $time);
        // FND가 내부적으로 각 자리를 스캔(Multiplexing)할 수 있도록 1밀리초 대기
        #1_000_000; 

        // --- 시나리오 2: btnC 입력 (시간 화면 1234) ---
        $display("[%0t] 시나리오 2: btnC 입력 (시간 화면 전환)", $time);
        t_btnC = 1; #20; t_btnC = 0; // 버튼 짧게 누름 (펄스)
        #1_000_000; 
        
        // --- 시나리오 3: btnR 입력 (타겟 온도 28) ---
        $display("[%0t] 시나리오 3: btnR 입력 (타겟 온도 설정 화면 전환)", $time);
        t_btnR = 1; #20; t_btnR = 0; 
        #1_000_000;
        
        // --- 시나리오 4: btnL 입력 (다시 온습도 화면으로) ---
        $display("[%0t] 시나리오 4: btnL 입력 (다시 온습도 화면 전환)", $time);
        t_btnL = 1; #20; t_btnL = 0;
        #1_000_000;

        $display("[%0t] 테스트 종료", $time);
        $finish;
    end

endmodule