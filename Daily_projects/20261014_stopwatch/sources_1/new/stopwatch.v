`timescale 1ns / 1ps
module stopwatch (
    input clk,
    input rst,
    input btnR,
    input btnL,
    input btnU,
    input sw_display_mode,
    output [3:0] fnd_com,
    output [7:0] fnd_font
);
    wire w_btn_run_stop, w_run_stop;
    wire w_btn_cler, w_clear;
    wire w_btn_mode, w_mode;
    parameter MSEC_BIT_WIDTH = 7;
    parameter SEC_BIT_WIDTH = 6;
    parameter MIN_BIT_WIDTH = 6;
    parameter HOUR_BIT_WIDTH = 5;
    wire [MSEC_BIT_WIDTH -1:0] w_msec;
    wire [ SEC_BIT_WIDTH -1:0] w_sec;
    wire [ MIN_BIT_WIDTH -1:0] w_min;
    wire [HOUR_BIT_WIDTH -1:0] w_hour;
    button_debounce U_BD_RUN_STOP (
        .clk  (clk),
        .rst(rst),
        .i_btn(btnR),
        .o_btn(w_btn_run_stop)
    );
    button_debounce U_BD_CLEAR (
        .clk  (clk),
        .rst(rst),
        .i_btn(btnL),
        .o_btn(w_btn_cler)
    );
    button_debounce U_BD_MODE (
        .clk  (clk),
        .rst(rst),
        .i_btn(btnU),
        .o_btn(w_btn_mode)
    );
    control_unit U_SOTPWATCH_CONTROL_UNIT (
        .clk         (clk),
        .rst       (rst),
        .btn_run_stop(w_btn_run_stop),
        .btn_clear   (w_btn_cler),
        .btn_mode    (w_btn_mode),
        .clear       (w_clear),
        .run_stop    (w_run_stop),
        .mode        (w_mode)
    );
    //stopwatch datapath
    stopwatch_datapath U_STOPWATCH_DATAPATH (
        .clk     (clk),
        .rst     (rst),
        .run_stop(w_run_stop),
        .clear   (w_clear),
        .mode    (w_mode),
        .msec    (w_msec),
        .sec     (w_sec),
        .min     (w_min),
        .hour    (w_hour)
    );
    //fnd display controller
    fnd_controller U_FND_CNTL (
        .clk            (clk),
        .rst            (rst),
        .sw_display_mode(sw_display_mode),
        .msec           (w_msec),
        .sec            (w_sec),
        .min            (w_min),
        .hour           (w_hour),
        .fnd_com        (fnd_com),
        .fnd_font       (fnd_font)
    );

endmodule
module stopwatch_datapath #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input clk,
    input rst,
    input run_stop,
    input clear,
    input mode,
    output [MSEC_BIT_WIDTH-1:0] msec,
    output [SEC_BIT_WIDTH-1:0] sec,
    output [MIN_BIT_WIDTH-1:0] min,
    output [HOUR_BIT_WIDTH-1:0] hour
);

    wire w_tick_10ms, w_tick_sec, w_tick_min, w_tick_hour;
    tick_counter #(
        .TIMES    (24),
        .BIT_WIDTH(HOUR_BIT_WIDTH)
    ) U_HOUR_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_hour),
        .clear     (clear),
        .mode      (mode),
        .time_count(hour),
        .o_tick    ()
    );
    tick_counter #(
        .TIMES    (60),
        .BIT_WIDTH(MIN_BIT_WIDTH)
    ) U_MIN_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_min),
        .clear     (clear),
        .mode      (mode),
        .time_count(min),
        .o_tick    (w_tick_hour)
    );
    tick_counter #(
        .TIMES    (60),
        .BIT_WIDTH(SEC_BIT_WIDTH)
    ) U_SEC_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_sec),
        .clear     (clear),
        .mode      (mode),
        .time_count(sec),
        .o_tick    (w_tick_min)
    );
    tick_counter #(
        .TIMES    (100),
        .BIT_WIDTH(MSEC_BIT_WIDTH)
    ) U_MSEC_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_10ms),
        .clear     (clear),
        .mode      (mode),
        .time_count(msec),
        .o_tick    (w_tick_sec)
    );

    tick_gen_100hz U_TICK_GEN_100HZ (
        .clk     (clk),
        .rst     (rst),
        .run_stop(run_stop),
        .clear   (clear),
        .o_tick  (w_tick_10ms)
    );

endmodule

module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                      clk,
    input                      rst,
    input                      i_tick,
    input                      clear,
    input                      mode,
    output     [BIT_WIDTH-1:0] time_count,
    output reg                 o_tick
);
    reg [$clog2(TIMES)-1:0] counter_reg;
    assign time_count = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst | clear) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            if (mode) begin  //mode = 1 , down
                if (i_tick) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        o_tick <= 1'b1;
                        counter_reg <= TIMES - 1;
                    end
                end else begin  // 이거 없으면 w_tick_sec 계속 1됨, 
                    o_tick <= 1'b0;
                end
            end else begin  //mode = 0 , up
                if (i_tick) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == TIMES - 1) begin
                        o_tick <= 1'b1;
                        counter_reg <= 0;
                    end
                end else begin
                    o_tick <= 1'b0;
                end
            end
        end
    end
endmodule

module tick_gen_100hz (
    input      clk,
    input      rst,
    input      run_stop,
    input      clear,
    output reg o_tick
);
    //100M->100hz
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst | clear) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            if (run_stop) begin
                counter_reg <= counter_reg + 1;
                if (counter_reg == (F_COUNT - 1)) begin
                    counter_reg <= 0;
                    o_tick <= 1'b1;
                end else begin
                    o_tick <= 1'b0;
                end
            end else begin
                //run_stop 1 and o_tick 1 => run_stop 이 0으로 바뀌면 o_tick 계속 1 인 경우 해결용.
                o_tick <= 1'b0;
            end
        end
    end

endmodule
