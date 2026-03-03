`timescale 1ns / 1ps

module tb_top();
    // 신호 선언
    reg clk;
    reg reset;
    reg btn;
    wire [15:0] led;

    // 1. UUT(Unit Under Test) 인스턴스화 + 파라미터 덮어쓰기
    // 시뮬레이션 가속을 위해 극한으로 줄인 값들입니다.
    top #(
        .SIM_TICK_Hz(10_000_000), // 1ms 대신 1us(박자가 빨라짐)
        .SIM_CNT_LIMIT(5)        // 50번 대신 5번만 tick이 오면 패턴 변화
    ) u_top (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .led(led)
    );

    // 2. 100MHz 클럭 생성 (10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 3. 테스트 시나리오
    initial begin
        // 초기화
        reset = 1;
        btn = 0;
        #100;
        reset = 0;
        #200;

        // [Case 1] 첫 번째 모드 (FIRST) 관찰
        $display("Mode 0 (FIRST) sequence starts...");
        #20000; // LED가 몇 개 켜지는 것을 볼 수 있는 충분한 시간

        // [Case 2] 버튼 클릭 -> 모드 변경 (SECOND)
        // 디바운서 리미트가 작기 때문에 짧은 시간만 유지해도 인식됩니다.
        $display("Button Pressed -> Switching to Mode 1");
        btn = 1; #1000; // btn noise 인식 10 clk
        btn = 0; #10000;

        // [Case 3] 버튼 클릭 -> 모드 변경 (THIRD: Blooming)
        $display("Button Pressed -> Switching to Mode 2 (Blooming)");
        btn = 1; #1000; 
        btn = 0; #10000;

        // [Case 4] 버튼 클릭 -> 모드 변경 (FOURTH: Converging)
        $display("Button Pressed -> Switching to Mode 3 (Converging)");
        btn = 1; #1000; 
        btn = 0; #10000;

        $display("Simulation successfully completed!");
        $finish;
    end
endmodule