`timescale 1ns / 1ps

module tb_button_debounce();

    parameter CLK_FREQ = 100_000_000;
    parameter CLK_PERIOD = 10; // 10ns (100MHZ 1주기)
    parameter BTN_PRESS_LIMIT = 30_000_000;  // 30ms → 1ms = 1,000,000ns 

    
    reg r_clk;
    reg r_reset;
    reg r_btnC;
    wire [1:0] r_led;

    top_btn u_top_btn(
        .clk(r_clk),
        .reset(r_reset),
        .btnC(r_btnC),
        .led(r_led)
    );

    initial begin 
        r_clk = 0;   
        
        forever #5 r_clk = ~r_clk;     // 파형 만들기 5ns 마다 반전  / 100MHz clk generate

    end


    initial begin 
        r_reset = 1;    // board r_reset  하드웨어가 reset 될 때까지 물리적인 시간 기다림 필요
        r_btnC = 0;
      #100;   // 100ns 기다림
        r_reset = 0;

        // btn input generate  잡음
        $display ("[%0t] start btn noise generation ", $time);
        #100 r_btnC = 1;
        #200 r_btnC = 0;
        #300 r_btnC = 1;
        #120 r_btnC = 0;
        #500;
        r_btnC = 1;
        
        #(BTN_PRESS_LIMIT);  // 30ms
        #100;

        if (r_led !== 2'b00) begin
            $display ("[%0t] TEST PASS... LED Changed... ", $time);
        end else begin
            $display ("[%0t] TEST FAIL... LED is not Changed...  ", $time);
        end

        #1000;
        $display ("============== Simulation FINISH ==============");
        $finish;
    end

endmodule
