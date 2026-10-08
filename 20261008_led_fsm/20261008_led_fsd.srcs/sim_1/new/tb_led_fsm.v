`timescale 1ns / 1ps


module tb_led_fsm();
    reg clk,reset;
    reg [1:0]sw;
    wire [2:0]led;
    led_fsm1 dut(
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .led(led)
    );
    always #5 clk = ~clk;

    always begin
        reset = 1;
        clk = 0;
        #10;
        reset= 0;
        #10;

        // 0 -> 1 -> 2 -> 3 -> 0
        sw = 2'b00;
        #10;
        sw = 2'b01;
        #10;
        sw = 2'b10;
        #10;
        sw = 2'b11;
        #10;
        sw = 2'b00;

        // 1 -> 2-> 3 -> 4 -> 0
        #10;
        sw = 2'b01;
        #10;
        sw = 2'b10;
        #10;
        sw = 2'b11;
        #10;
        sw = 2'b10;
        #10;
        sw = 2'b00;

        // 1 -> 2 -> 3 -> 1
        #10;
        sw = 2'b01;
        #10;
        sw = 2'b10;
        #10;
        sw = 2'b11;
        #10;
        sw = 2'b01;
        #15;


    end
endmodule
