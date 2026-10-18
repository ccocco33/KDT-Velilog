module watch_datapath #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input clk,
    input rst,
    input sw_show_mode,
    input sw_display_mode,
    input edit,
    input up,
    input down,
    input [1:0]selected_digit,
    output [MSEC_BIT_WIDTH-1:0] msec,
    output [SEC_BIT_WIDTH-1:0] sec,
    output [MIN_BIT_WIDTH-1:0] min,
    output [HOUR_BIT_WIDTH-1:0] hour
    );
    wire w_tick_10ms, w_tick_sec, w_tick_min, w_tick_hour;
    //hour
    tick_counter_watch #(
        .TIMES       (24),
        .BIT_WIDTH   (HOUR_BIT_WIDTH),
        .UNIT_OF_TIME(2'b11)            // 00 - msec,01 sec,10-min, 11-hour
    ) U_HOUR_COUNTER_WATCH (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_hour),
        .up(up),
        .down(down),
        .sw_display_mode(sw_display_mode),
        .edit(edit),
        .selected_digit(selected_digit),
        .time_count(hour),
        .o_tick()
    );
    //min
    tick_counter_watch #(
        .TIMES       (60),
        .BIT_WIDTH   (MIN_BIT_WIDTH),
        .UNIT_OF_TIME(2'b10)            // 00 - msec,01 sec,10-min, 11-hour
    ) U_MIN_COUNTER_WATCH (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_min),
        .up(up),
        .down(down),
        .sw_display_mode(sw_display_mode),
        .edit(edit),
        .selected_digit(selected_digit),
        .time_count(min),
        .o_tick(w_tick_hour)
    );
    //SEC
    tick_counter_watch #(
        .TIMES       (60),
        .BIT_WIDTH   (SEC_BIT_WIDTH),
        .UNIT_OF_TIME(2'b01)            // 00 - msec,01 sec,10-min, 11-hour
    ) U_SEC_COUNTER_WATCH (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_sec),
        .up(up),
        .down(down),
        .sw_display_mode(sw_display_mode),
        .edit(edit),
        .selected_digit(selected_digit),
        .time_count(sec),
        .o_tick(w_tick_min)
    );
    //MSEC
    tick_counter_watch #(
        .TIMES       (100),
        .BIT_WIDTH   (MSEC_BIT_WIDTH),
        .UNIT_OF_TIME(2'b00)            // 00 - msec,01 sec,10-min, 11-hour
    ) U_MSEC_COUNTER_WATCH (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_10ms),
        .up(up),
        .down(down),
        .sw_display_mode(sw_display_mode),
        .edit(edit),
        .selected_digit(selected_digit),
        .time_count(msec),
        .o_tick(w_tick_sec)
    );

    tick_gen_100hz_watch U_TICK_GEN_100HZ_WATCH (
        .clk(clk),
        .rst(rst),
        .o_tick(w_tick_10ms)
    );

endmodule
module tick_counter_watch #(
    parameter TIMES = 100,
    BIT_WIDTH = 7,
    UNIT_OF_TIME = 2'b00  // 00 - msec,01 sec,10-min, 11-hour
) (
    input                      clk,
    input                      rst,
    input                      i_tick,
    input                      up,
    input                      down,
    input                      sw_display_mode,
    input                      edit,
    input      [          1:0] selected_digit,
    output     [BIT_WIDTH-1:0] time_count,
    output reg                 o_tick
);
    reg [$clog2(TIMES)-1:0] counter_reg;
    // reg [$clog2(TIMES)-1:0] counter_next;
    assign time_count = counter_reg;
    localparam max = TIMES - 1;
    localparam max_1 = max % 10;  //1의 자리 최댓값
    localparam max_10 = max / 10;  //10의 자리 최댓값
    wire [3:0] counter_ds1 = counter_reg % 10;  //지금 1자리
    wire [3:0] counter_ds10 = counter_reg / 10;  //지금 10자리
    reg [3:0] counter_next_ds1;
    reg [3:0] counter_next_ds10;
    //sw_display_mode,UNIT_OF_TIME, selected_digit을 가지고 지금 내가 수정하는것인지 알아야한다.
    wire [1:0]edit_this_module = (sw_display_mode)? ((selected_digit[1]?2'b11:2'b10)):(selected_digit[1]?2'b01:2'b00); //(hour:min):(sec:msec)

    always @(*) begin
        counter_next_ds10 = counter_ds10;
        counter_next_ds1  = counter_ds1;
        if (selected_digit[0]) begin  //ds10,ds1000 더하기 빼기 10씩 되는곳
            if (up) begin
                //1자리가 1의자리 맥스보다 크다면 10의 자리는 10의자리 맥스보다 1작은 수가 최대가 된다. 아니라면 10의자리 맥스까지 가능하다.
                counter_next_ds10 = (counter_ds1 > max_1) ? ((counter_ds10 == max_10 - 1) ? 0 : counter_ds10 + 1)
                                                          : ((counter_ds10 == max_10)     ? 0 : counter_ds10 + 1);
            end else if (down) begin  // ds1,ds100 //빼기 10씩
                //1의 자리 확인 -> 1의 자리 맥스보다 크면 max10보다 1 작은거가 최대 / 1의자리 맥스보다 작으면 max 10까지 돌수있음
                counter_next_ds10 = (counter_ds1 > max_1) ? ((counter_ds10 == 0) ? max_10 - 1 : counter_ds10 - 1)
                                                          : ((counter_ds10 == 0) ? max_10     : counter_ds10 - 1);
            end
        end else begin  //ds1,ds100 더하기 빼기 1씩 되는곳
            if (up) begin
                counter_next_ds1 = (counter_ds10 == max_10) ? ((counter_ds1 == max_1) ? 0 : counter_ds1 + 1)
                                                            : ((counter_ds1 == 9)     ? 0 : counter_ds1 + 1);
            end else if (down) begin  // ds1,ds100 // 빼기 1씩
                //10의자리 == max_10?
                counter_next_ds1 = (counter_ds10 == max_10) ? ((counter_ds1 == 0) ? max_1 : counter_ds1 - 1)
                                                            : ((counter_ds1 == 0) ? 9     : counter_ds1 - 1);
            end
        end

    end

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
            if (UNIT_OF_TIME == 2'b11) begin //hour은 12로 초기화
                    counter_reg <= 5'b01100;
            end else begin
                counter_reg <= 0;
            end
        end else begin
            o_tick <= 1'b0;
            if (edit) begin  // 수정 모드
                if (edit_this_module == UNIT_OF_TIME) begin
                    counter_reg <= counter_next_ds10 * 10 + counter_next_ds1;
                end else begin
                    counter_reg <=counter_reg;
                end
            end else begin  //수정 모드 x
                if (i_tick) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == max) begin
                        o_tick <= 1'b1;
                        counter_reg <= 0;
                    end else begin  // 이거 없으면 w_tick_sec 계속 1됨, 
                        o_tick <= 1'b0;
                    end

                end
            end

        end
    end
endmodule
module tick_gen_100hz_watch (
    input      clk,
    input      rst,
    output reg o_tick
);
    //100M->100hz
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            o_tick <= 1'b0;
        end else begin
            
                counter_reg <= counter_reg + 1;
                if (counter_reg == (F_COUNT - 1)) begin
                    counter_reg <= 0;
                    o_tick <= 1'b1;
                end else begin
                    o_tick <= 1'b0;
                end
                
            
        end
    end

endmodule

