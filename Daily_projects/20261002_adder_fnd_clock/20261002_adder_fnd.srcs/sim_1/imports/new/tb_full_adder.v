`timescale 1ns / 1ps

module tb_adder_fnd ();
    //100M -> 800hz
    reg clk,reset;
    wire o_clk_800hz;
    clk_div_800Hz dut(
    .clk(clk),
    .reset(reset),
    .o_clk_800hz(o_clk_800hz)
);
    //generate 100hz clock, duty 1:1
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        //#(250_000 clk *10nces(1clock*));
        #(400_00000*10);
        #200;
        $stop;
    end
endmodule
