`timescale 1ns / 1ps

module tb_top();
    // 신호 선언
    reg clk;
    reg reset;
    reg [2:0] btn;
    wire [7:0] seg;
    wire [3:0] an;


    // 1. UUT(Unit Under Test) 인스턴스화 + 파라미터 덮어쓰기
    // 시뮬레이션 가속을 위해 극한으로 줄인 값들입니다.
    top #(
        .SIM_TICK_Hz(10_000_000), 
        .SIM_CNT_LIMIT(5),
        .SIM_DEBOUNCE_LIMIT(10) // 시뮬레이션을 위해 10클럭으로 단축 [cite: 101]
    ) u_top (
        .clk(clk), .reset(reset), .btn(btn), .seg(seg), .an(an)
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
        $display(" sequence starts...");
        #20000;

        // [Case 2] 버튼 클릭 -> 모드 변경 (SECOND)
        // 디바운서 리미트가 작기 때문에 짧은 시간만 유지해도 인식됩니다.
        @(posedge clk);
        btn[0] = 1; #10000; // btn noise 인식 10 clk
        $display("TIME : %t ...Button1 Pressed -> Switching to Mode 1", $time);
        @(posedge clk);
        btn[0] = 0; #50000;

        @(posedge clk);
        btn[0] = 1; #10000; // btn noise 인식 10 clk
        $display("TIME : %t ...Button1 Pressed -> Switching to Mode 1", $time);
        @(posedge clk);
        btn[0] = 0; #50000;

        @(posedge clk);
        btn[0] = 1; #10000; // btn noise 인식 10 clk
        $display("TIME : %t ...Button1 Pressed -> Switching to Mode 1", $time);
        @(posedge clk);
        btn[0] = 0; #50000;

        @(posedge clk);
        btn[0] = 1; #10000; // btn noise 인식 10 clk
        $display("TIME : %t ...Button1 Pressed -> Switching to Mode 1", $time);
        @(posedge clk);
        btn[0] = 0; #50000;

        @(posedge clk);
        btn[0] = 1; #10000; // btn noise 인식 10 clk
        $display("TIME : %t ...Button1 Pressed -> Switching to Mode 1", $time);
        @(posedge clk);
        btn[0] = 0; #50000;

        // [Case 3] 버튼 클릭 -> 모드 변경 (THIRD: Blooming)
        @(posedge clk);
        btn[1] = 1; #10000; 
        $display("TIME : %t ...Button2 Pressed -> Switching to Mode 2 ", $time);
        @(posedge clk);
        btn[1] = 0; #50000;

        // [Case 4] 버튼 클릭 -> 모드 변경 (FOURTH: Converging)
        @(posedge clk);
        btn[2] = 1; #10000; 
        $display("TIME : %t ...Button Pressed3 -> Switching to Mode 3 )", $time);
        @(posedge clk);
        btn[2] = 0; #50000;

        
        $display("TIME : %t ...Simulation successfully completed!", $time);
        $finish;
    end
endmodule