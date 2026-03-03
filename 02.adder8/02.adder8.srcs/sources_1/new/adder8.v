`timescale 1ns / 1ps

module adder8(
    input [7:0] a,
    input [7:0] b,
    input cin,   // 1bit
    output [7:0] sum,
    output carry_out
    );

    wire w_carry0, w_carry1, w_carry2, w_carry3, w_carry4, w_carry5, w_carry6 ;

    
    full_adder FA0 (
        .a(a[0]),   // 
        .b(b[0]),   
        .cin(1'b0),
        .sum(sum[0]),   
        .carry_out(w_carry0)    
    );  // named instantiation
    
    full_adder FA1 (
        .a(a[1]),   // 
        .b(b[1]),   
        .cin(w_carry0),    
        .sum(sum[1]),   
        .carry_out(w_carry1)    
        );
    full_adder FA2 (
        .a(a[2]),   // 
        .b(b[2]),   
        .cin(w_carry1),    
        .sum(sum[2]),   
        .carry_out(w_carry2)    
        );
    full_adder FA3 (
        .a(a[3]),   // 
        .b(b[3]),   
        .cin(w_carry2),    
        .sum(sum[3]),   
        .carry_out(w_carry3)    
        );
    full_adder FA4 (
        .a(a[4]),   // 
        .b(b[4]),   
        .cin(w_carry3),    
        .sum(sum[4]),   
        .carry_out(w_carry4)    
        );
    full_adder FA5 (
        .a(a[5]),   // 
        .b(b[5]),   
        .cin(w_carry4),    
        .sum(sum[5]),   
        .carry_out(w_carry5)    
        );
    full_adder FA6 (
        .a(a[6]),   
        .b(b[6]),   
        .cin(w_carry5),    
        .sum(sum[6]),   
        .carry_out(w_carry6)    
        );
    full_adder FA7 (
        .a(a[7]),   
        .b(b[7]),   
        .cin(w_carry6),    
        .sum(sum[7]),   
        .carry_out(carry_out)    
        );
         

         
endmodule
