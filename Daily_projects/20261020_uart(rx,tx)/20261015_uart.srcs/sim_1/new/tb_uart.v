`timescale 1ns / 1ps


// module tb_uart ();
//     parameter BAUD_BIT_PERIOD = 100_000_000 / 9600 * 10;  //1M /9600* 10clk
//     reg clk, rst, btnR;
//     reg [7:0]result_data,expexted_data;
//     wire led, tx;
//     uart dut (
//         .clk (clk),
//         .rst (rst),
//         .btnR(btnR),   //tx_busy
//         .tx  (tx)
//     );
//     always #5 clk = ~clk;

//     task receive_uart();
//         integer i;
//         begin
//             wait(~tx);  // negedge or ! ...안전하게 0일때를 선택함
//             #(BAUD_BIT_PERIOD / 2);
//             //check start bit 0
//             if (tx != 0) $display("error start bit");
//             for (i = 0; i < 8; i = i + 1) begin
//                 #(BAUD_BIT_PERIOD);
//                 result_data[i] = tx;
//             end
//             #(BAUD_BIT_PERIOD);

//             if(!tx)$display("error stop bit");
//         end
//     endtask

//     initial begin
//         clk  = 0;
//         rst  = 1;
//         btnR = 0;
//         #10 rst = 0;
//         #10000;
//         //push button tx_start
//         btnR = 1;
//         #(10*100*10);//버튼이 1M기준이니까 10*100 그리고 10ns니까 *10
//         btnR = 0;
//         //tx_
//         // #(BAUD_BIT_PERIOD * 10)//10bit 보고싶으니까 왜? 우리 상태 10개 만들엇으니까


//         //uart receive
//         receive_uart();
//         #100;
//         //to compare result data and
//         if(result_data == 8'h30) $display("pass!!!");
//         $display("fail!!!");

//         #100;
//         $stop;



//     end
// endmodule
module tb_uart();
    parameter BAUD_BIT_PERIOD = 100_000_000 / 9600 * 10;  //1M /9600* 10clk
    reg clk, rst, rx;
    reg [7:0]result_data,expexted_data;
    wire led, tx;
    uart_loopback dut (
        .clk (clk),
        .rst (rst),
        .rx(rx),   //tx_busy
        .tx  (tx)
    );
    always #5 clk = ~clk;

    task sender_uart(input [7:0]send_data);
        integer i;
        begin
           rx = 0;
            #(BAUD_BIT_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = send_data[i];
                #(BAUD_BIT_PERIOD);
            end
            rx = 1; //stop bit
            #(BAUD_BIT_PERIOD);
        end
    endtask
    task receive_uart(output [7:0]rx_data);
        integer i;
        begin
           wait(~tx);
            #(BAUD_BIT_PERIOD / 2);
            //check start bit 0
           if(tx != 0)$display("error start bit");
            for (i = 0; i < 8; i = i + 1) begin
                #(BAUD_BIT_PERIOD);
                rx_data[i]=tx;
            end
            #(BAUD_BIT_PERIOD);
            if(!tx)$display("error stop bit");
        end
    endtask

    initial begin
        clk  = 0;
        rst  = 1;
        rx = 1;
        expexted_data = 8'h30;

        #10 rst = 0;

        sender_uart(expexted_data);
        receive_uart(result_data);
        #100;
        //to compare result data and
        if(result_data == expexted_data) $display("pass!!!");
        else $display("fail!!!");
        $stop;
    end
endmodule