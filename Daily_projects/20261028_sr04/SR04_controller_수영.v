`timescale 1ns / 1ps

module sr04_top (
    input clk,
    input rst,
    input sr04_start,
    input echo,
    input enable,
    input clear,
    output trig,
    output [8:0] distance_range

);


    wire w_enable, w_clear, w_ms_tick, w_us_tick;
    baud_tick U_BAUD_TICK (
        .clk(clk),
        .rst(rst),
        .enable(w_enable),
        .clear(w_clear),
        .b_tick(w_us_tick)
    );
    baud_tick_ms U_BAUD_TICK_MS (
        .clk(clk),
        .rst(rst),
        .us_tick(w_us_tick),
        .ms_tick(w_ms_tick)
    );
    SR04_controller U_SR04_CNTL (
        .clk(clk),
        .rst(rst),
        .sr04_start(sr04_start),
        .us_tick(w_us_tick),
        .ms_tick(w_ms_tick),

        .echo(echo),
        .i_enable(enable),
        .i_clear(clear),
        .enable(w_enable),
        .clear(w_clear),
        .trig(trig),
        .distance_range(distance_range)
        // output reg sr04_busy
    );

endmodule

module SR04_controller (
    input clk,
    input rst,
    input sr04_start,
    input us_tick,
    input echo,
    input i_enable,
    input i_clear,
    input ms_tick,
    output enable,
    output clear,
    output trig,
    output [8:0] distance_range
    // output reg sr04_busy
);
    assign enable = i_enable;
    assign clear  = i_clear;

    reg [$clog2(40)-1:0] tick_count_reg, tick_count_next;
    reg [2:0] n_state, c_state;
    reg [12:0] distance_count_reg, distance_count_next;
    reg [8:0] distance_range_next, distance_range_reg;
    reg trig_reg, trig_next;
    // reg sr04_busy_next;

    assign distance_range = distance_range_reg;
    assign trig = trig_reg;

    parameter IDLE = 3'b000, START = 3'b001, WAIT = 3'b010, DISTAUNCE = 3'b011,STOP = 3'b100;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            distance_range_reg <= 0;
            trig_reg <= 0;
            tick_count_reg <= 0;
            distance_count_reg <= 0;

        end else begin
            c_state <= n_state;
            distance_range_reg <= distance_range_next;
            trig_reg <= trig_next;
            tick_count_reg <= tick_count_next;
            distance_count_reg <= distance_count_next;
        end
    end

    always @(*) begin
        trig_next = trig_reg;
        tick_count_next = tick_count_reg;
        n_state = c_state;
        distance_range_next = distance_range_reg;
        distance_count_next = distance_count_reg;
        case (c_state)
            IDLE: begin
                if (sr04_start) begin
                    n_state = START;
                    tick_count_next = 0;
                    distance_count_next = 0;
                end
            end
            START: begin
                if (us_tick) begin
                    if (tick_count_reg < 11) begin
                        trig_next = 1;
                        tick_count_next = tick_count_reg + 1;
                    end else begin
                        n_state = WAIT;
                        tick_count_next = 0;
                        trig_next = 0;
                    end
                end
            end
            WAIT: begin
                if (ms_tick) begin
                    if (echo) begin
                        n_state = DISTAUNCE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                        if(tick_count_reg >40) begin// 40 ms 뒤는 다시 idle로 
                            n_state = IDLE;
                        end
                    end
                end
            end
            DISTAUNCE: begin
                if (us_tick) begin
                    if (echo) begin
                        distance_count_next = distance_count_reg + 1;
                    end else begin
                        n_state = STOP;
                    end
                end
            end
            STOP: begin
                if (ms_tick) begin
                    if (tick_count_reg == 11) begin
                        n_state = IDLE;
                        distance_range_next = (distance_count_reg / 58) / 2;
                        distance_count_next = 0;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

        endcase
    end
endmodule

module baud_tick_ms (
    input clk,
    input rst,
    input us_tick,
    output reg ms_tick
);
    parameter F_COUNT = 1000;
    reg [$clog2(F_COUNT)-1:0] tick_count;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_count <= 0;
            ms_tick <= 0;
        end else begin
            if (us_tick) begin
                if (tick_count == F_COUNT - 1) begin
                    ms_tick <= 1;
                    tick_count   <= 0;
                end else begin
                    ms_tick <= 0;
                    tick_count <= tick_count + 1;
                end
            end else begin
                 ms_tick <= 0;
            end
        end
    end
endmodule

module baud_tick (
    input clk,
    input rst,
    input enable,
    input clear,
    output reg b_tick
);
    parameter F_COUNT = 100;
    reg [$clog2(F_COUNT)-1:0] tick_count;
    always @(posedge clk, posedge rst) begin
        if (rst | clear) begin
            tick_count <= 0;
            b_tick <= 0;
        end else begin
            b_tick <= 0;
            if (enable) begin
                if (tick_count == F_COUNT - 1) begin
                    b_tick <= 1;
                    tick_count <= 0;
                end else begin
                    tick_count <= tick_count + 1;
                end
            end

        end
    end

endmodule
