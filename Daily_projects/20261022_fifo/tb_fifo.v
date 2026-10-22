`timescale 1ns / 1ps

module tb_fifo ();
    reg clk, rst, push, pop;
    reg  [7:0] push_data;
    wire [7:0] pop_data;
    wire full, empty;
    integer i;
    fifo dut (
        .clk(clk),
        .rst(rst),
        .push(push),
        .pop(pop),
        .push_data(push_data),
        .pop_data(pop_data),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        push = 0;
        pop = 0;
        push_data = 0;
        i = 0;
        // pop_data = 0;

        @(negedge clk);
        @(negedge clk);
        rst = 0;
        @(negedge clk);
        // 초기 상태
        // if (full == 0) begin
        //     $display("%t :pass full signal", $stime);
        // end else begin
        //     $display("%t :fail full signal", $stime);
        // end

        // if (empty == 1) begin
        //     $display("%t :pass empty signal", $stime);
        // end else begin
        //     $display("%t :fail empty signal", $stime);
        // end
        
        // push only
        // for (i = 0; i < 5; i = i + 1) begin
        //     @(negedge clk);
        //     push_data = 8'h0a + i;
        //     push = 1'b1;
        // end
        // @(negedge clk);
        // push = 1'b0;

        // // // pop only
        // for (i = 0; i < 5; i = i + 1) begin
        //     @(negedge clk);
        //     pop = 1'b1;
            
        // end
        // @(negedge clk);
        // pop = 1'b0;

        //push, pop

        for (i = 0; i < 2; i = i + 1) begin
            @(negedge clk);
            push_data = 8'h0a + 1;
            push = 1'b1;
        end
        @(negedge clk);
        push = 1'b0;

        for (i = 0; i < 5; i = i + 1) begin
            @(negedge clk);
            push_data = 8'h0a + 2;
            push = 1'b1;
            pop = 1'b1;
        end
        @(negedge clk);
        pop = 1'b0;
        push = 1'b0;
        


        #10;


        $finish;
    end
endmodule
