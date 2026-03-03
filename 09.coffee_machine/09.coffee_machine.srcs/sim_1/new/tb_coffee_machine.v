`timescale 1ns / 1ps

module tb_coffee_machine();

    reg clk;   // 100MHz
    reg reset;  // reset btn, active high
    reg coin;   // 동전 투입 100원 단위
    reg return_coin_btn;  // 동전반환 버튼
    reg coffee_btn;
    reg coffee_out;    // 커피 배출 완료

    wire [15:0] coin_val;    // 현재의 금액 표시
    wire seg_en;   // FND 활성화 신호
    wire coffee_make;  // 커피 제조 시작 신호
    wire coin_return ;  // 동전반환 동작 신호


    coffee_machine u_coffee_machine(
    .clk(clk),   // 100MHz
    .reset(reset),  // reset btn, active high
    .coin(coin),   // 동전 투입 100원 단위
    .return_coin_btn(return_coin_btn),  // 동전반환 버튼
    .coffee_btn(coffee_btn),
    .coffee_out(coffee_out),    // 커피 배출 완료

    .coin_val(coin_val),    // 현재의 금액 표시
    .seg_en(seg_en),   // FND 활성화 신호
    .coffee_make(coffee_make),  // 커피 제조 시작 신호
    .coin_return(coin_return)   // 동전반환 동작 신호
    );

    // 동전 투입 task : clk에 동기화 

    task insert_coin;
        begin 
            @(posedge clk);
            #1 coin=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(3) @ (posedge clk);    // 아래 내용을 clk의 상승 엣지 3번 동안 유지
            #1 coin = 0;
            repeat(10) @ (posedge clk);    // 대기 시간 확보

        end
    endtask 


    // 100MHz  clock 생성
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // 1. 초기 신호 unknown(X) 방지
        clk = 0;
        reset = 1;
        coin = 0;
        return_coin_btn = 0;
        coffee_btn = 0;
        coffee_out = 0;

        // 2. 정상적인 reset seq 
        #100;    // 100ns 동안 reset 유지 
        @(negedge clk)    // clk negedge일 때 reset 해제 : Glitch 방지
        reset = 0;
        $display("time : %t reset release... IDLE state :", $time );

        #50;

        // 3. scenario : 
        // 3.1. 300 투입 (IDLE -> COIN_IN -> READY)
        $display("time : %t coin insert ... ", $time);

        insert_coin();  // 100원
        insert_coin();  // 200원
        insert_coin();  // 300원

        // 3.2. READY 확인
        #20;
        if (coin_val >= 300) 
            $display("time : %t current READY   coin_val : %d ... ", $time, coin_val);
        else 
            $display("time : %t ERROR coin_val : %d ... ", $time, coin_val);

      
        // 4. coffee_btn 누른다. READY --> COFFEE --> READY
        @(posedge clk);
        #1 coffee_btn = 1; //setup time 확보
        @(posedge clk);
        #1 coffee_btn = 0;
        $display("time : %t coffee_btn pressed... ", $time);

        // 커피를 만드는 작업이 완료 될 때까지 대기 해야함
        wait(coffee_make == 1);
        $display("time : %t coffee making... ", $time);
        #200;   // 제조 지연 시간
        
        // -- 커피를 제조 완료 신호
        @(posedge clk);
        #1 coffee_out = 1; //setup time 확보
        @(posedge clk);
        #1 coffee_out = 0;
        $display("time : %t coffee_out sensor is detected and turn into READY status... ", $time);
        #50;

        // 5. 동전 반환 (READY → COIN_OUT --> IDLE)
        $display("time : %t coin return coin_val : %d... ", $time, coin_val);
        @(posedge clk);
        #1 return_coin_btn = 1; //setup time 확보
        @(posedge clk);
        #1 return_coin_btn = 0;


        wait(return_coin_btn == 0);
        $display("time : %t coin is returned == 1: .. ", $time);
        #100;   // 
        if (coin_val == 0) 
            $display("time : %t return coin_val %d  //  goto IDLE MODE ... ", $time, coin_val);
        #300;
        $display("Simultaion Succeeded %t", $time);
        $finish;

    end

endmodule
