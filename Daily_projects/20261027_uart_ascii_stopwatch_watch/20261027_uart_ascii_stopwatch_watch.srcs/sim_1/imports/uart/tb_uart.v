`timescale 1ns / 1ps

//수업-for문
module tb_uart ();
    parameter BAUD_BIT_PERIOD = 100_000_000 / 9600 * 10;  //1M /9600* 10clk
    reg clk, rst, rx;
    // reg [7:0] result_data, expected_data;
    wire tx;
    // integer i;
    // integer pass_count, fail_count;
    // uart_fifo_loopback dut (
    //     .clk(clk),
    //     .rst(rst),
    //     .rx (rx),
    //     .tx (tx)
    // );

    // wire [3:0] fnd_com;
    // wire [7:0] fnd_font;
    uart_fifo_ascii dut (
        .clk     (clk),
        .rst     (rst),
        .rx      (rx),
        .tx      (tx),
        .fnd_com (),
        .fnd_font()
    );
    always #5 clk = ~clk;

    task sender_uart(input [7:0] send_data);
        integer i;
        begin
            rx = 0;
            #(BAUD_BIT_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_BIT_PERIOD);
            end
            rx = 1;  //stop bit
            #(BAUD_BIT_PERIOD);
        end
    endtask
    task receive_uart(output [7:0] rx_data);
        integer i;
        begin
            wait (~tx);
            #(BAUD_BIT_PERIOD / 2);
            //check start bit 0
            if (tx != 0) $display("[receive tx] error start bit");
            for (i = 0; i < 8; i = i + 1) begin
                #(BAUD_BIT_PERIOD);
                rx_data[i] = tx;
            end
            #(BAUD_BIT_PERIOD);
            if (!tx) $display("[receive tx] error stop bit");
        end
    endtask

    // task score_board(input [7:0] result, expected);
    //     begin
    //         //to compare result data and
    //         if (result == expected) begin
    //             // pass_count = pass_count + 1;
    //             $display("[result] %t: pass", $time);
    //         end else begin
    //             // fail_count = fail_count + 1;
    //             $display("[result] %t: fail", $time);
    //         end
    //     end
    // endtask
    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        #10 rst =0 ;

        sender_uart("r");
        sender_uart("c");
        sender_uart("u");
        sender_uart("s");
        sender_uart("R");
        sender_uart("C");
        sender_uart("U");
        sender_uart("S");

        #1000;
       
        $stop;
    end
endmodule
