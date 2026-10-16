module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7,
    UNIT_OF_TIME = 00 // 00 - msec,01 sec,10-min, 11-hour
) (
    input                      clk,
    input                      rst,
    input                      i_tick,
    input                      up,
    input                      down,
    input                      right,
    input                      left,
    // input                      sw_show_mode,
    input                      sw_display_mode,
    input                      sw_time_edit,
    input      [          1:0] selected_digit,
    output     [BIT_WIDTH-1:0] time_count,
    output reg                 o_tick
);
    reg [$clog2(TIMES)-1:0] counter_reg;
    reg [$clog2(TIMES)-1:0] counter_next;
    assign time_count = counter_reg;
    localparam max = TIMES - 1;
    localparam max_1 = max % 10;  //1의 자리 최댓값
    localparam max_10 = max / 10;  //10의 자리 최댓값
    wire [3:0] counter_ds1 = counter_reg % 10;  //지금 1자리
    wire [3:0] counter_ds10 = counter_reg / 10;  //지금 10자리
    reg  [3:0] counter_next_ds1;
    reg  [3:0] counter_next_ds10;

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
        end else begin
            if (sw_time_edit) begin  // 수정 모드
                counter_reg <= counter_next_ds10 * 10 + counter_next_ds1;
            end else begin  //수정 모드 x
                if (i_tick) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        o_tick <= 1'b1;
                        counter_reg <= TIMES - 1;
                    end else begin  // 이거 없으면 w_tick_sec 계속 1됨, 
                        o_tick <= 1'b0;
                    end

                end
            end

        end
    end
endmodule