`timescale 1ns / 1ps




module led_toggle_no_ff(

        input btn_debounce,
        output [1:0] led
    );

    reg r_led_toggle = 1'b0;

    always @ (posedge btn_debounce) begin   // btn_debounce : 채터링 제거된 신호
        r_led_toggle <= ~r_led_toggle;

    end

    assign led[0] = (r_led_toggle == 1) ? 1'b1 : 1'b0;

endmodule


