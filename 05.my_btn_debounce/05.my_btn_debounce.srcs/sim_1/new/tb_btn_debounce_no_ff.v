`timescale 1ns / 1ps

module tb_top();

    // 신호 선언
    reg clk;
    reg reset;
    reg btn;
    wire [15:0] led;

    // 테스트할 상위 모듈(UUT) 인스턴스화
    top u_top (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .led(led)
    );

    // 1. 100MHz 클럭 생성 (10ns 주기)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 2. 버튼 누름 동작을 시뮬레이션하기 위한 태스크(Task)
    // 버튼을 일정 시간 동안 눌렀다 떼는 동작을 반복하기 위함
    task press_btnC;
        begin
            btn = 1;     // 중앙 버튼(btnC) 누름
            #20_000_000;    // 20ms 유지 (디바운서 10ms 통과를 위해 충분히 대기)
            btn = 0;     // 버튼 뗌
            #20_000_000;    // 다음 동작 전 여유 시간
        end
    endtask

    // 3. 자극(Stimulus) 생성
    initial begin
        // 초기 상태 설정
        reset = 1;
        btn = 3'b000;
        #100;               // 100ns 후 리셋 해제
        reset = 0;
        #200;

        // [Mode 1: FIRST - 정방향]
        // 초기 리셋 후 자동으로 시작됨. 
        // 시뮬레이션 창에서 led[0], led[1]... 순으로 변하는지 확인
        $display("Starting Mode 1: FIRST");
        #100_000_000;       // 100ms 관찰

        // [Mode 2: SECOND - 역방향]으로 전환
        $display("Switching to Mode 2: SECOND");
        press_btnC();
        #100_000_000;       // 100ms 관찰

        // [Mode 3: THIRD - Flower Blooming]으로 전환
        $display("Switching to Mode 3: THIRD (Blooming)");
        press_btnC();
        #100_000_000;       // 100ms 관찰

        // [Mode 4: FOURTH - Converging]으로 전환
        $display("Switching to Mode 4: FOURTH (Converging)");
        press_btnC();
        #100_000_000;       // 100ms 관찰

        $display("Simulation Finished");
        $finish;            // 시뮬레이션 종료
    end

endmodule