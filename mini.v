module tick_counter #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
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
    localparam top_1  = max % 10; 
    localparam max_10 = max / 10;  //10의 자리 최댓값 (9 / 5 / 2)
    wire [3:0] counter_ds1 = counter_reg % 10;  //지금 1자리
    wire [3:0] counter_ds10 = counter_reg / 10;  //지금 10자리
   
    wire [3:0] max_1 = (counter_ds10 == max_10) ? top_1 : 4'd9;
    reg  [3:0] counter_next_ds1;
    reg  [3:0] counter_next_ds10;

    always @(*) begin
        counter_next_ds10 = counter_ds10;
        counter_next_ds1  = counter_ds1;
        if (selected_digit[0]) begin  // 10의 자리 (ds10, ds1000)
            if (up) begin
                if (counter_ds10 >= max_10) counter_next_ds10 = 0;
                else if (counter_ds10 + 1 == max_10 && counter_ds1 > top_1)
                    counter_next_ds10 = 0;  
                else counter_next_ds10 = counter_ds10 + 1;
            end else if (down) begin
                if (counter_ds10 != 0) counter_next_ds10 = counter_ds10 - 1;
                else if (counter_ds1 > top_1)
                    counter_next_ds10 = max_10 - 1;                      
                else counter_next_ds10 = max_10;
            end
        end else begin  // 1의 자리 (ds1, ds100)
            if (up) begin
                counter_next_ds1 = (counter_ds1 >= max_1) ? 0 : counter_ds1 + 1;
            end else if (down) begin
                counter_next_ds1 = (counter_ds1 == 0) ? max_1 : counter_ds1 - 1;
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
