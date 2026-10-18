`timescale 1ns / 1ps

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
    input laptime, // 저장된 랩 시간 표시
    input lap_cap, // 현재 시간 저장 신호
    output [MSEC_BIT_WIDTH-1:0] msec,
    output [SEC_BIT_WIDTH-1:0] sec,
    output [MIN_BIT_WIDTH-1:0] min,
    output [HOUR_BIT_WIDTH-1:0] hour
);

    wire w_tick_10ms, w_tick_sec, w_tick_min, w_tick_hour;

    wire [ MSEC_BIT_WIDTH -1 :0] w_lap_msec;
    wire [  SEC_BIT_WIDTH -1 :0] w_lap_sec;
    wire [  MIN_BIT_WIDTH -1 :0] w_lap_min;
    wire [ HOUR_BIT_WIDTH -1 :0] w_lap_hour;
    wire [ MSEC_BIT_WIDTH -1 :0] w_count_msec;
    wire [  SEC_BIT_WIDTH -1 :0] w_count_sec;
    wire [  MIN_BIT_WIDTH -1 :0] w_count_min;
    wire [ HOUR_BIT_WIDTH -1 :0] w_count_hour;

    mux_2x1x4_lapstop #(
    .MSEC_BIT_WIDTH(MSEC_BIT_WIDTH),
    .SEC_BIT_WIDTH(SEC_BIT_WIDTH),
    .MIN_BIT_WIDTH(MIN_BIT_WIDTH),
    .HOUR_BIT_WIDTH(HOUR_BIT_WIDTH)
) U_MUX_LAP_STOPWATCH (
    .msec_lap(w_lap_msec),
    .sec_lap(w_lap_sec),
    .min_lap(w_lap_min),
    .hour_lap(w_lap_hour),
    .msec_stopwatch(w_count_msec),
    .sec_stopwatch(w_count_sec),
    .min_stopwatch(w_count_min),
    .hour_stopwatch(w_count_hour),
    .laptime(laptime),
    .msec_result(msec),
    .sec_result(sec),
    .min_result(min),
    .hour_result(hour) 
);

    stopwatch_laptime #(
    .MSEC_BIT_WIDTH (MSEC_BIT_WIDTH),
    .SEC_BIT_WIDTH  (SEC_BIT_WIDTH),
    .MIN_BIT_WIDTH  (MIN_BIT_WIDTH),
    .HOUR_BIT_WIDTH (HOUR_BIT_WIDTH)
) U_STOPWATCH_LAPTIME (
    .clk    (clk),
    .rst    (rst),
    .clear  (clear),
    .laptime(laptime),
    .lap_cap(lap_cap),    
    .i_msec(w_count_msec),
    .i_sec (w_count_sec),
    .i_min (w_count_min),
    .i_hour(w_count_hour),           
    .o_msec(w_lap_msec),
    .o_sec (w_lap_sec),
    .o_min (w_lap_min),
    .o_hour(w_lap_hour)  
);


    tick_counter #(
        .TIMES    (24),
        .BIT_WIDTH(HOUR_BIT_WIDTH)
    ) U_HOUR_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_hour),
        .clear     (clear),
        .mode      (mode),
        .time_count(w_count_hour),
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
        .time_count(w_count_min),
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
        .time_count(w_count_sec),
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
        .time_count(w_count_msec),
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

module stopwatch_laptime #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input                          clk,
    input                          rst,
    input                          clear,
    input                          laptime,
    input                          lap_cap,
 
    //해당 카운팅 된 시간이 들어옴 
    input [ MSEC_BIT_WIDTH -1 :0]  i_msec,
    input [  SEC_BIT_WIDTH -1 :0]  i_sec,
    input [  MIN_BIT_WIDTH -1 :0]  i_min,
    input [ HOUR_BIT_WIDTH -1 :0]  i_hour,
    // 저장된 시간 출력              
    output [ MSEC_BIT_WIDTH -1 :0] o_msec,
    output [  SEC_BIT_WIDTH -1 :0] o_sec,
    output [  MIN_BIT_WIDTH -1 :0] o_min,
    output [ HOUR_BIT_WIDTH -1 :0] o_hour  
);

    reg [ MSEC_BIT_WIDTH -1 :0] lap_msec;
    reg [  SEC_BIT_WIDTH -1 :0] lap_sec;
    reg [  MIN_BIT_WIDTH -1 :0] lap_min;
    reg [ HOUR_BIT_WIDTH -1 :0] lap_hour;

    always @(posedge clk, posedge rst) begin
        if(rst | clear) begin
            lap_msec <= 0;
            lap_sec  <= 0;
            lap_min  <= 0;
            lap_hour <= 0;
        end else if (lap_cap) begin
            lap_msec <= i_msec;
            lap_sec  <= i_sec;
            lap_min  <= i_min;
            lap_hour <= i_hour;
        end
    end

    assign o_msec = lap_msec;  
    assign o_sec  = lap_sec;
    assign o_min  = lap_min;
    assign o_hour = lap_hour;  

endmodule

module mux_2x1x4_lapstop #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input      [MSEC_BIT_WIDTH-1:0] msec_lap,
    input      [ SEC_BIT_WIDTH-1:0]  sec_lap,
    input      [ MIN_BIT_WIDTH-1:0]  min_lap,
    input      [HOUR_BIT_WIDTH-1:0] hour_lap,
    input      [MSEC_BIT_WIDTH-1:0] msec_stopwatch,
    input      [ SEC_BIT_WIDTH-1:0]  sec_stopwatch,
    input      [ MIN_BIT_WIDTH-1:0]  min_stopwatch,
    input      [HOUR_BIT_WIDTH-1:0] hour_stopwatch,
    input                           laptime,
    output     [MSEC_BIT_WIDTH-1:0] msec_result,
    output     [ SEC_BIT_WIDTH-1:0]  sec_result,
    output     [ MIN_BIT_WIDTH-1:0]  min_result,
    output     [HOUR_BIT_WIDTH-1:0] hour_result
);
    assign msec_result = laptime ? msec_lap : msec_stopwatch;
    assign sec_result  = laptime ? sec_lap  : sec_stopwatch;
    assign min_result  = laptime ? min_lap  : min_stopwatch;
    assign hour_result = laptime ? hour_lap : hour_stopwatch;
endmodule