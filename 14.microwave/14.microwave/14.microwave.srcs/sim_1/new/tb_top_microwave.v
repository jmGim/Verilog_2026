`timescale 1ns / 1ps

module tb_top_microwave();
    // reg clk, reset;
    // reg btn_open_close, btn_start_stop, btn_cancel, btn_speedup, timeout;

    // reg buzzer, PWM_OUT;

    reg clk;
    reg reset;
    reg [4:0] btn;
    reg dir_motor;
    reg timeout;

    wire buzzer;
    wire [7:0] seg;
    wire [3:0] an;
    wire dir_plate;
    wire pwm_plate;
    wire pwm_door;

    top_microwave u_top_microwave(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .dir_motor(dir_motor),

        .buzzer(buzzer),
        .seg(seg),
        .an(an),
        .dir_plate(dir_plate),
        .pwm_plate(pwm_plate),
        .pwm_door(pwm_door)
    );


    task t_open;
        begin
            @(posedge clk);
            #1 btn[1]=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask

    task t_close;
        begin
            @(posedge clk);
            #1 btn[1]=0; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask

    task t_start;
        begin
            @(posedge clk);
            #1 btn[2]=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask

    task t_stop;
        begin
            @(posedge clk);
            #1 btn[2]=0; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask


    task t_cancel;
        begin
            @(posedge clk);
            #1 btn[4]=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(3) @ (posedge clk);    // 아래 내용을 clk의 상승 엣지 3번 동안 유지
            #1 btn[4] = 0;
            repeat(10) @ (posedge clk);    // 대기 시간 확보
            #1 btn[2] = 1;
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask


    task t_speedup;
        begin
            @(posedge clk);
            #100 btn[3]=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(3) @ (posedge clk);    // 아래 내용을 clk의 상승 엣지 3번 동안 유지
            #100 btn[3] = 0;
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask

    task t_timeadd10s;
        begin
            @(posedge clk);
            #1 btn[0]=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(3) @ (posedge clk);    // 아래 내용을 clk의 상승 엣지 3번 동안 유지
            #1 btn[0] = 0;
            repeat(10) @ (posedge clk);    // 대기 시간 확보
        end
    endtask




    task t_timeout;
        begin
            @(posedge clk);
            #1 timeout=1; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 대기 시간 확보
             @(posedge clk);
            #1 timeout=0; //setup time 확보  
            // clk posedge 이전 Data 값 안정적으로 있어야 하는 시간 ( posedge clk 전 Data는 먼저 도달해있어야함 ).
            repeat(10) @ (posedge clk);    // 아래 내용을 clk의 상승 엣지 3번 동안 유지
        end
    endtask

  
    







    // 100MHz  clock 생성
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // 1. 초기 신호 unknown(X) 방지
        clk = 0;
        reset = 1;
        btn[4:0] = 5'b00000;
        timeout = 0;


        // 2. 정상적인 reset seq 
        #100;    // 100ns 동안 reset 유지 
        @(negedge clk)    // clk negedge일 때 reset 해제 : Glitch 방지
        reset = 0;
        $display("time : %t reset release... IDLE state :", $time );

        #50;

        // 3. scenario : 
        // 3.1. 문 열고 시작(비정상) + speedup
        $display("time : %t Start button click with DOOR OPEN ... ", $time);
        t_open();
        t_start();
        t_speedup();
        t_speedup();
        t_timeadd10s();
        #10000;

        // 3.2. 문 닫고 시작(정상) 및 중도 취소
        $display("time : %t Start button click with DOOR CLOSE ... ", $time);
        t_close();
        t_start();
        t_speedup();
        t_speedup();
        t_speedup();
        t_timeadd10s();

        t_cancel();
        #1000;


        // 3.3. 조리 완료(정상)
        $display("time : %t Start button click with DOOR CLOSE ... ", $time);
        t_start();
        t_speedup();
        t_speedup();
        t_speedup();
        t_timeout();


        // 3.4. 조리 중 문 열고 닫은 후 다시 시작(시간 이어서 진행되는 지 확인)
        $display("time : %t Start button click with DOOR CLOSE ... ", $time);
        t_start();
        t_open();
        #100;
        t_close();
        t_start();
        t_timeadd10s();
        t_timeout();

        #300;
        $display("Simultaion Succeeded %t", $time);
        $finish;
        
    end


endmodule
