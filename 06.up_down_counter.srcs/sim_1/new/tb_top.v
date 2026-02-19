`timescale 1ns / 1ps

module tb_top();

    // 입력 신호 define
    reg clk; 
    reg reset;  // switch 15번
    reg [2:0] btn;  // L,C,R in the order
    reg [7:0] sw;
    // 출력 신호 define
    wire [7:0] seg;
    wire [3:0] an;
    // wire [15:0] led;
    wire led;




    // DUT (Design Under Test) Instancization
    top u_top(
    .clk(clk), 
    .reset(reset),  // switch 15번
    .btn(btn),  // L,C,R in the order
    .sw(sw),
    .seg(seg),
    .an(an),
    .led(led)
    // output [2:0] JXADC  // 
    );


    always #5 clk = ~clk;


    task btn_press;
        input integer btn_index;  // interger signed 32bit reg[31:0] 
        begin 
            $display("btn_press btn : %0d start ", btn_index);

            // Making Noise (0.55ms)
            btn[btn_index] = 1; #100000; // 0.1ms High
            btn[btn_index] = 0; #200000; // 0.2ms Low
            btn[btn_index] = 1; #150000; // 0.15ms High
            btn[btn_index] = 0; #100000; // 0.1ms Low


            // 2. 안정 구간 11ms 유지 -> 이 구간이 지나야 clean_btn 이 1이 된다. 
            btn[btn_index] = 1;
            #11000000; // 11ms 

            // 3. btn을 뗀다 (11ms 이상 유지)
            
            btn[btn_index] = 0;

            #11000000; // 11ms 
            $display("btn_press btn : %0d start", btn_index);
            // btn_press(0);

        

        end
    endtask

    initial begin
        // $monitor("time=%t mode=%b an:%d seg:%b ", $time, led[15:13], an, seg);
        // led[15:13]나 an 이나 seg 값이 바뀌면 해당 라인을 출력하는 것.
    end


    initial begin

        // 1. initial 설정
        clk  = 0;
        reset = 1;
        btn=3'b0000;
        sw=8'b00000000;


        // 2. reset 해제
        #100;
        reset = 0;
        #100;

        // 3. mode 변경 ( IDLE → UP_COUNTER btn[0] : btnL)
        $display("MODE ILD -- UP_COUNTER");
        btn_press(0);  // btn[0]

        // 4. UP_COUNTER 동작 관찰
        #20000000;

        // ---- 모드 변경 (UP --> DOWN) ---- //
        $display("MODE ILD -- DOWN_COUNTER ");
        btn_press(0);

        // 5 DOWN_COUNTER 동작 관찰
        #10000000;


        /// 6. 모드 변경 DOWN_COUNTER --> SLIDE_SW_READ
        $display("MODE ILD -- SLIDE_SW_READ ");
        btn_press(0);
        sw = 8'h55;
        #1000000;
        sw = 8'hA4;
        #1000000;
        $display("Simulation Ended....... ");
        $finish;

    end
    
endmodule
