`timescale 1ns / 1ps

module control_unit (
    input clk,
    input rst,
    input btn_run_stop,
    input btn_clear,
    input btn_mode,
    output reg clear,
    output reg run_stop,
    output mode
);
    parameter STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10, MODE = 2'b11;
    reg [1:0] n_state, c_state;
    reg mode_reg, mode_next;  // mode_reg: currunt mode, mode_next: next mode
    // assign mode = sw;
    assign mode = mode_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state  <= STOP;
            mode_reg <= 1'b0;
        end else begin
            c_state  <= n_state;
            mode_reg <= mode_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        run_stop = 1'b0;
        clear = 1'b0;
        mode_next = mode_reg;  // 초기값 전상태 유지
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
            // default: begin
            //     clear = 0;
            //     run_stop = 0;
            // end
        endcase
    end
endmodule
