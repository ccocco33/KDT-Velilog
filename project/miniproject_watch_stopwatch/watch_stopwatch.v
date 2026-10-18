`timescale 1ns / 1ps


module watch_stopwatch_top (
    input clk,
    input rst,
    input btnR,
    input btnL,
    input btnU,
    input btnD,  //랩타임 OR DOWN
    input sw_show_mode,
    input sw_display_mode,
    input sw_time_edit,
    output [3:0] fnd_com,
    output [7:0] fnd_font

);
    parameter MSEC_BIT_WIDTH = 7;
    parameter SEC_BIT_WIDTH = 6;
    parameter MIN_BIT_WIDTH = 6;
    parameter HOUR_BIT_WIDTH = 5;

    wire w_btnR, w_run_stop, w_right;
    wire w_btnL, w_clear;
    wire w_btnU, w_mode;
    wire w_btnD, w_laptime, w_lap_cap;
    wire w_up_control_unit, w_down_control_unit;
    wire w_edit;
    wire [1:0] w_selected_digit;

    wire [MSEC_BIT_WIDTH -1:0] w_msec_stopwatch, w_msec_watch, w_msec_result;
    wire [SEC_BIT_WIDTH -1:0] w_sec_stopwatch, w_sec_watch, w_sec_result;
    wire [MIN_BIT_WIDTH -1:0] w_min_stopwatch, w_min_watch, w_min_result;
    wire [HOUR_BIT_WIDTH -1:0] w_hour_stopwatch, w_hour_watch, w_hour_result;
    wire w_btnR_stopwatch, w_btnL_stopwatch,
         w_btnU_stopwatch,
         w_btnD_stopwatch,
         w_btnR_watch,
         w_btnL_watch,
         w_btnU_watch,
         w_btnD_watch;

    //debounce
    button_debounce U_BD_RUN_STOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );
    button_debounce U_BD_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );
    button_debounce U_BD_MODE (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );
    button_debounce U_BD_LAPTIME (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    mux_4_8_bt_control_unit U_MUX_4_8_bt_control (
    .btnR(w_btnR),
    .btnL(w_btnL),
    .btnU(w_btnU),
    .btnD(w_btnD),
    .sw_show_mode(sw_show_mode),
    .btnR_stopwatch(w_btnR_stopwatch),
    .btnL_stopwatch(w_btnL_stopwatch),
    .btnU_stopwatch(w_btnU_stopwatch),
    .btnD_stopwatch(w_btnD_stopwatch),
    .btnR_watch(w_btnR_watch),
    .btnL_watch(w_btnL_watch),
    .btnU_watch(w_btnU_watch),
    .btnD_watch(w_btnD_watch)
);
    // 워치용으로수정한 컨트롤 유닛, 데이터패스 와야합니다.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    watch_control_unit U_WATCH_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .btn_R(w_btnR_watch),
        .btn_L(w_btnL_watch),
        .btn_U(w_btnU_watch),
        .btn_D(w_btnD_watch),
        .sw_display_mode(sw_display_mode),     // SW0: 표시 단위 선택, CU 내부에서는 미사용
        .sw_show_mode(sw_show_mode),  // SW1: 0 = 워치, 1 = 스탑워치
        .sw_time_edit(sw_time_edit),  // SW2: 0 = 일반, 1 = 시간 조정
        .up(w_up_control_unit),
        .down(w_down_control_unit),  // 0 = 증가, 1 = 감소
        .run_stop(w_edit),  // 일반 0, 수정 1
        .selected_digit(w_selected_digit)
    );

    //stopwatch control unit , laptime 옵션 할거면 모듈가서 내용 수정해야함
    stopwatch_control_unit U_SOTPWATCH_CONTROL_UNIT (
        .clk         (clk),
        .rst         (rst),
        .btn_run_stop(w_btnR_stopwatch),
        .btn_clear   (w_btnL_stopwatch),
        .btn_mode    (w_btnU_stopwatch),
        .btn_laptime (w_btnD_stopwatch),
        .clear       (w_clear),
        .run_stop    (w_run_stop),
        .mode        (w_mode),
        .laptime     (w_laptime),
        .lap_cap     (w_lap_cap)
    );
    stopwatch_datapath U_STOPWATCH_DATAPATH (  //먹스랑 이어주기
        .clk     (clk),
        .rst     (rst),
        .run_stop(w_run_stop),
        .clear   (w_clear),
        .mode    (w_mode),
        .laptime (w_laptime),
        .lap_cap (w_lap_cap),
        .msec    (w_msec_stopwatch),
        .sec     (w_sec_stopwatch),
        .min     (w_min_stopwatch),
        .hour    (w_hour_stopwatch)
    );
    //watch datapath
    watch_datapath U_WATCH_DATAPATH (
        .clk(clk),
        .rst(rst),
        .sw_show_mode(sw_show_mode),
        .sw_display_mode(sw_display_mode),
        .edit(w_edit),
        .up(w_up_control_unit),
        .down(w_down_control_unit),
        .selected_digit(w_selected_digit),
        .msec(w_msec_watch),
        .sec(w_sec_watch),
        .min(w_min_watch),
        .hour(w_hour_watch)
    );

    //mux(sw0 = sw_show_mode의 입력을 받아 누구의 msec,sec,min,hour 출력할지 결정)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!여기 만들어야함
    mux_2x1x4_result U_MUX_2x1x4_RESULT (
        .msec_watch(w_msec_watch),
        .sec_watch(w_sec_watch),
        .min_watch(w_min_watch),
        .hour_watch(w_hour_watch),
        .msec_stopwatch(w_msec_stopwatch),
        .sec_stopwatch(w_sec_stopwatch),
        .min_stopwatch(w_min_stopwatch),
        .hour_stopwatch(w_hour_stopwatch),
        .sw_show_mode(sw_show_mode),
        .msec_result(w_msec_result),
        .sec_result(w_sec_result),
        .min_result(w_min_result),
        .hour_result(w_hour_result)
    );
    //fnd display controller
    fnd_controller U_FND_CNTL (
        .clk            (clk),
        .rst            (rst),
        .sw_show_mode(sw_show_mode),
        .sw_display_mode(sw_display_mode),
        .sw_time_edit(sw_time_edit),
        .msec           (w_msec_result),
        .sec            (w_sec_result),
        .min            (w_min_result),
        .hour           (w_hour_result),
        .selected_digit (w_selected_digit),
        .fnd_com        (fnd_com),
        .fnd_font       (fnd_font)
    );
endmodule

module mux_2x1x4_result #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input      [MSEC_BIT_WIDTH-1:0] msec_watch,
    input      [ SEC_BIT_WIDTH-1:0] sec_watch,
    input      [ MIN_BIT_WIDTH-1:0] min_watch,
    input      [HOUR_BIT_WIDTH-1:0] hour_watch,
    input      [MSEC_BIT_WIDTH-1:0] msec_stopwatch,
    input      [ SEC_BIT_WIDTH-1:0] sec_stopwatch,
    input      [ MIN_BIT_WIDTH-1:0] min_stopwatch,
    input      [HOUR_BIT_WIDTH-1:0] hour_stopwatch,
    input                           sw_show_mode,
    output reg [MSEC_BIT_WIDTH-1:0] msec_result,
    output reg [ SEC_BIT_WIDTH-1:0] sec_result,
    output reg [ MIN_BIT_WIDTH-1:0] min_result,
    output reg [HOUR_BIT_WIDTH-1:0] hour_result
);
    always @(*) begin
        if (~sw_show_mode) begin  //시계
            msec_result = msec_watch;
            sec_result  = sec_watch;
            min_result  = min_watch;
            hour_result = hour_watch;

        end else begin  //스탑워치
            msec_result = msec_stopwatch;
            sec_result  = sec_stopwatch;
            min_result  = min_stopwatch;
            hour_result = hour_stopwatch;
        end
    end
endmodule
module mux_4_8_bt_control_unit(
    input btnR,
    input btnL,
    input btnU,
    input btnD,
    input sw_show_mode,
    output btnR_stopwatch,
    output btnL_stopwatch,
    output btnU_stopwatch,
    output btnD_stopwatch,
    output btnR_watch,
    output btnL_watch,
    output btnU_watch,
    output btnD_watch
);
    assign btnR_stopwatch=btnR&&(sw_show_mode);
    assign btnL_stopwatch=btnL&&(sw_show_mode); 
    assign btnU_stopwatch=btnU&&(sw_show_mode); 
    assign btnD_stopwatch=btnD&&(sw_show_mode);
    assign btnR_watch    =btnR&&(~sw_show_mode);
    assign btnL_watch    =btnL&&(~sw_show_mode);
    assign btnU_watch    =btnU&&(~sw_show_mode);
    assign btnD_watch    =btnD&&(~sw_show_mode);
endmodule
