`timescale 1ns / 1ps


module counter_10000 (
    input        clk,
    input        reset,
    input        run_stop,
    input        clear,
    input        up_down,
    output [7:0] fnd_font,
    output [3:0] fnd_com
);
    wire [13:0] w_counter;
    counter_datapath U_COUNTER_DATAPATH (
        .clk(clk),
        .reset(reset),
        .counter(w_counter),
        .run_stop(run_stop),
        .clear(clear),
        .up_down(up_down)
    );
    fnd_controller U_FND_CONTROLLER (
        .clk(clk),
        .reset(reset),
        .fnd_data(w_counter),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );

endmodule

module counter_datapath (
    input         clk,
    input         reset,
    input         clear,
    input         run_stop,
    input         up_down,
    output [13:0] counter
);
    wire w_tick;
    tick_counter U_TICK_COUNTER (
        .clk    (clk),
        .reset  (reset),
        .i_tick (w_tick),
        .up_down(up_down),
        .clear(clear),
        .counter(counter)
    );

    tick_gen U_TICK_GEN (
        .clk   (clk),
        .reset (reset),
        .o_tick(w_tick),
        .run_stop(run_stop)
    );
endmodule
module tick_counter (
    input         clk,
    input         reset,
    input         i_tick,
    input         up_down,
    input clear,
    output [13:0] counter
);
    reg [13:0] counter_reg;  // tick_gen 의 counter_reg와 다르다.
    assign counter = counter_reg;

    always @(posedge clk, posedge reset) begin
        if (reset||clear) begin
            counter_reg <= 0;
        end else begin
            if (i_tick) begin
                if (up_down) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_reg <= 9999;
                    end
                end else begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == 9999) begin
                        counter_reg <= 0;
                    end
                end


                // counter_reg <= counter_reg + 1;
                // if (counter_reg == (10000 - 1)) begin
                //     counter_reg <= 0;
                // end
            end
        end
    end
endmodule

module tick_gen (
    input  clk,
    input  reset, 
    input  run_stop,
    output o_tick
);
    parameter F_COUNT = 10_000_000;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;
    reg pass;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
            tick_reg <= 0;
            pass <= 0;
        end else if (~run_stop) begin
            //tick, counter stop 
            pass = pass + 1;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                tick_reg <= 1'b0;
            end
        end

        // if (reset) begin
        //     counter_reg <= 0;
        //     tick_reg <= 1'b0;
        // end else begin
        //     counter_reg <= counter_reg + 1;
        //     if (counter_reg == F_COUNT - 1) begin
        //         counter_reg <= 0;
        //         tick_reg <= 1'b1;
        //     end else begin
        //         tick_reg <= 1'b0;
        //     end
        // end
        // if (counter_reg == 1) begin
        //     tick_reg <= ~tick_reg;
        // end else if (counter_reg == 2) begin
        //     tick_reg <= ~tick_reg;
        // end else if (counter_reg == F_COUNT - 1) begin
        //     counter_reg <= 1'b0;
        // end

    end
endmodule
