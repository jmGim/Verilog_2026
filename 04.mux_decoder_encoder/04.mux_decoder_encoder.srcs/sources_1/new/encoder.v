`timescale 1ns / 1ps

module encoder(

    input [3:0] d,
    output [1:0] a

    );
    
    reg [3:0] r_a;  // reg 선언 업이 하면 non-permitted register 에러 발생

    // assign a = (a==2'b00) ? 4'b0001 : 
    //              (a==2'b01) ? 4'b0010 :
    //              (a==2'b10) ? 4'b0100 : 4'b1000 ;
    always @ (*) begin     // 감지 목록 sel or a or b
        case (d)
            4'b0001: r_a = 2'b00;
            4'b0010: r_a = 2'b01;
            4'b0100: r_a = 2'b10;
            4'b1000: r_a = 2'b11;
        endcase

    end

    assign a = r_a; 
endmodule
