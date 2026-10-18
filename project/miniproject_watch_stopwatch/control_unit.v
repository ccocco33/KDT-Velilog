`timescale 1ns / 1ps

module stopwatch_control_unit (
    input      clk,
    input      rst,
    input      btn_run_stop,
    input      btn_clear,
    input      btn_mode,
    input      btn_laptime,   //기능추가
    output reg clear,
    output reg run_stop,
    output     mode,
    output     laptime,       // 저장된 랩 시간 표시
    output reg lap_cap        // 현재 시간을 저장 추가
);
    parameter STOP = 3'b000, 
              RUN = 3'b001,
              CLEAR = 3'b010, 
              MODE = 3'b011, 
              LAPTIME = 3'b100;
    reg [2:0] n_state, c_state;
    reg mode_reg, mode_next;  // mode_reg: currunt mode, mode_next: next mode
    //reg laptime_reg, laptime_next;

    // assign mode = sw;
    assign mode = mode_reg;


    //assign laptime = laptime_reg;
    assign laptime = (c_state == LAPTIME);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= STOP;
            mode_reg <= 1'b0;
            //laptime_reg <= 1'b0;
        end else begin
            c_state  <= n_state;
            mode_reg <= mode_next;
            //laptime_reg <= laptime_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        run_stop = 1'b0;
        clear = 1'b0;
        mode_next = mode_reg;  // 초기값 전상태 유지
        //laptime_next = laptime_reg;
        lap_cap = 1'b0;
        case (c_state)
            STOP: begin
                run_stop = 1'b0;
                clear = 1'b0;
                if (btn_run_stop == 1'b1) begin
                    n_state = RUN;
                end else if (btn_clear == 1'b1) begin
                    n_state = CLEAR;
                end else if (btn_mode == 1'b1) begin
                    n_state = MODE;
                end
            end
            RUN: begin
                run_stop = 1'b1;
                if (btn_run_stop == 1'b1) begin
                    n_state = STOP;
                end else if (btn_laptime == 1'b1) begin
                    n_state = LAPTIME;
                    lap_cap = 1'b1;
                end
            end
            CLEAR: begin
                clear   = 1'b1;
                n_state = STOP;
            end
            MODE: begin
                mode_next = ~mode_reg;
                n_state   = STOP;
            end
            LAPTIME: begin
                run_stop = 1'b1;
                if (btn_run_stop) begin
                    n_state = STOP;
                end else if (btn_laptime) begin
                    //laptime_next = ~laptime_reg;
                    lap_cap = 1'b1;
                end
            end
            default: begin
                n_state = STOP;
            end
        endcase
    end
endmodule


module watch_control_unit (
    input clk,
    input rst,
    input btn_R,
    input btn_L,
    input btn_U,
    input btn_D,
    input sw_display_mode,     // SW0: 표시 단위 선택, CU 내부에서는 미사용
    input sw_show_mode,  // SW1: 0 = 워치, 1 = 스탑워치
    input sw_time_edit,  // SW2: 0 = 일반, 1 = 시간 조정
    output reg up,
    output reg down,  // 0 = 증가, 1 = 감소
    output reg run_stop,  // 일반 0, 수정 1
    output reg [1:0] selected_digit
);
    parameter WATCH = 3'b000,
              S1    = 3'b001,
              S10   = 3'b010,
              S100  = 3'b011,
              S1000 = 3'b100;

    reg [2:0] c_state, n_state;
    reg mode_reg, mode_next;


    // state SL
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= WATCH;
            mode_reg <= 1'b0;
            up <= 0;
            down <= 0;
            run_stop <= 0;
        end else begin
            c_state <= n_state;
            mode_reg <= mode_next;
            run_stop <= sw_time_edit;
            up <= btn_U;
            down <= btn_D;
        end
    end


    // next, output
    always @(*) begin
        n_state        = c_state;  // 입력이 없으면 현재 상태 유지
        selected_digit = 2'd0;
        if (sw_time_edit == 0) begin
            // SW2가 꺼지면 화면과 관계없이 일반 상태로 복귀
            n_state = WATCH;
        end else begin
            // watch 시간조절
            case (c_state)
                WATCH: begin
                    n_state = S1;
                end
                S1: begin
                    selected_digit = 2'b00;
                    if (btn_R) begin
                        n_state = S1000;
                    end else if (btn_L) begin
                        n_state = S10;
                    end else begin
                        n_state = S1;
                    end
                end
                S10: begin
                    selected_digit = 2'b01;
                    if (btn_R) begin
                        n_state = S1;
                    end else if (btn_L) begin
                        n_state = S100;
                    end else begin
                        n_state = S10;
                    end
                end
                S100: begin
                    selected_digit = 2'b10;
                    if (btn_R) begin
                        n_state = S10;
                    end else if (btn_L) begin
                        n_state = S1000;
                    end else begin
                        n_state = S100;
                    end
                end
                S1000: begin
                    selected_digit = 2'b11;
                    if (btn_R) begin
                        n_state = S100;
                    end else if (btn_L) begin
                        n_state = S1;
                    end else begin
                        n_state = S1000;
                    end
                end
                default: begin
                    n_state = WATCH;
                end
            endcase
        end
    end
endmodule
