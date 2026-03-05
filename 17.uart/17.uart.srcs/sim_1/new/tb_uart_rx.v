`timescale 1ns / 1ps

module tb_uart_rx( );

    reg clk;
    reg reset;
    reg rx;

    wire [7:0] data_out;
    wire rx_done;

    uart_rx #(
    .BPS(9600)
    ) u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),

        .data_out(data_out),
        .rx_done(rx_done)
    );

    
    // 100MHz clock 생성
    initial clk = 0;
    always #5 clk = ~clk;

    localparam CLK_FREQUENCY = 100_000_000;    // 100MHz
    // 1bit 당 10ns의 clk 몇 개 필요한 가?
    localparam BIT_PER_CLK_NUMBER = CLK_FREQUENCY / 9600;    // 10,416개
    localparam CLK_PERIOD_10NS = 10;   // 10ns

    localparam BAUD_PERIOD = BIT_PER_CLK_NUMBER * CLK_PERIOD_10NS;   // Sim wait 시간 = 104_160ns


    always @ (posedge rx_done) begin
        $display("time : %t -- data out received 8'h%h", $time, data_out);
    end

    // UART Rx Simulator
    // ASCII 'U' 와 'u'를 uart_rx로 전송 기능 구현

    initial begin 
        #00 reset = 1; rx=1; clk = 0; 
        #100; 
        reset = 0;
        #200;  // reset → idle로 빠짐
        // 'U' : 0x55 : 0101 0101  7<-0번 // 반전시키면 AA - 많이씀
        #BAUD_PERIOD; rx = 0;  // (rx(start bit) = 0)
        #BAUD_PERIOD; rx = 1;  // bit 0
        #BAUD_PERIOD; rx = 0;  // bit 1
        #BAUD_PERIOD; rx = 1;  // bit 2
        #BAUD_PERIOD; rx = 0;  // bit 3
        #BAUD_PERIOD; rx = 1;  // bit 4
        #BAUD_PERIOD; rx = 0;  // bit 5
        #BAUD_PERIOD; rx = 1;  // bit 6
        #BAUD_PERIOD; rx = 0;  // bit 7
        #BAUD_PERIOD; rx = 1;  // stop bit

        #1_000_000; // 1ms

        $display("UART Rx test finished");
        $finish;
              

    end

endmodule
 //