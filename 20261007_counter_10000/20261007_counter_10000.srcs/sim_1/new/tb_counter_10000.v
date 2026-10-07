`timescale 1ns / 1ps

module tb_counter_10000 ();
    reg clk,reset,up_down,run_stop,clear;
    wire [13:0]counter;
    counter_datapath dut (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .up_down(up_down),
        .counter(w_counter)
    );
    //gen 100Mhz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        run_stop = 1;
        clear = 0;
        up_down = 0;
        # 10;
        reset = 0;
        //#(250_000 clk *10nces(1clock*));
        // repeat(3)begin//loop ,#(10_000_000*10);
        //run_stop
        
        #10
        //up_down
        up_down = 1;
        # 10_0000000;
        up_down = 0;
        # 10_000;
        //clear
        # 10;
        clear = 0;
        #1000
        run_stop  = 0;
        
        
        $stop;
    end

endmodule
