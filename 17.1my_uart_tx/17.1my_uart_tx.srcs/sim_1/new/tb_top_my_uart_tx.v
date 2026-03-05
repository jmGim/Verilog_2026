`timescale 1ns / 1ps


module tb_top_my_uart_tx();
    
    reg clk;
    reg reset;
    reg [2:0] btn;
    reg [7:0]sw;
    reg RsRx;

    wire RsTx;
    wire [7:0]seg;
    wire [3:0]an;
    wire [15:0]led;
    wire uartTx;  // JB1 - for Oscilloscope
    wire uartRx;   // JB2

    
    top u_top(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .sw(sw),
        .RsRx(RsRx),

        .RsTx(RsTx),
        .seg(seg),
        .an(an),
        .led(led),
        .uartTx(uartTx),  // JB1 - for Oscilloscope
        .uartRx(uartRx)   // JB2
    );


    always #5 clk =~clk;
    reg [2:0] s = 3'b000;
    // reg step;
    task make_btn_noise(s); 
        begin 
            repeat(3) begin
                s = ~s; 
                
              
                #50;  // Chattering width = 50ns 
            end  // repeat 3 times
        end
    endtask

    initial begin
        clk = 0; reset = 1; btn=0;
        #100;
        reset = 0;
        #100;
        $display("TEST start ......");


        // Making Noise
        $display("btn clicked 1st ......");
        make_btn_noise(btn[0]); 
        sw = 8'h4B; #500;
        btn[0] = 1; #1000000;
        btn[0] = 0; #6000;
        
        $display("btn clicked 2nd ......");
        make_btn_noise(btn[0]); 
        sw = 8'h4A; #500;
        btn[0] = 1; #1000000;
        btn[0] = 0; #6000;

        $display("btn clicked 3rd ......");
        make_btn_noise(btn[0]); 
        sw = 8'h4D; #500;
        btn[0] = 1; #1000000;
        btn[0] = 0; #6000;

        $display("Simulation Finish");
        $finish;
    end

endmodule
