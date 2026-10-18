`timescale 1ns / 1ps

module fnd_controller #(
    parameter MSEC_BIT_WIDTH = 7,
    parameter SEC_BIT_WIDTH  = 6,
    parameter MIN_BIT_WIDTH  = 6,
    parameter HOUR_BIT_WIDTH = 5
) (
    input                       clk,
    input                       rst,
    input                       sw_display_mode,
    input                       sw_show_mode,
    input                       sw_time_edit,
    input  [MSEC_BIT_WIDTH-1:0] msec,
    input  [ SEC_BIT_WIDTH-1:0] sec,
    input  [ MIN_BIT_WIDTH-1:0] min,
    input  [HOUR_BIT_WIDTH-1:0] hour,
    input  [               1:0] selected_digit,
    output [               3:0] fnd_com,
    output [               7:0] fnd_font
);
    wire [2:0] w_ds_sel;
    wire w_clk_2000hz;
    //
    wire [3:0] w_mux_out, w_min_mux_out, w_hour_mux_out;
    wire [3:0] w_msec_ds1, w_msec_ds10;
    wire [3:0] w_sec_ds1, w_sec_ds10;
    wire [3:0] w_min_ds1, w_min_ds10;
    wire [3:0] w_hour_ds1, w_hour_ds10;
    wire [3:0] w_min_hour_mux_out, w_msec_sec_mux_out;
    wire w_dot_onoff;
    wire w_clk_2hz;
    clk_div_2000Hz U_CLK_DIV_2000HZ (
        .clk(clk),
        .rst(rst),
        .o_clk_2000hz(w_clk_2000hz)
    );
    counter_8 U_COUNTER_8 (
        .clk(w_clk_2000hz),
        .rst(rst),
        .ds_sel(w_ds_sel)
    );

    decoder_2x4 U_DECODER_2x4 (
        .ds_sel (w_ds_sel[1:0]),
        .fnd_com(fnd_com)
    );
    //msec
    digit_splitter #(
        .BIT_WIDTH(MSEC_BIT_WIDTH)
    ) U_MSEC_DIGIT_SPLITTER (
        .dsin(msec),
        .ds1 (w_msec_ds1),  //digit 1
        .ds10(w_msec_ds10)
    );
    //sec
    digit_splitter #(
        .BIT_WIDTH(SEC_BIT_WIDTH)
    ) U_SEC_DIGIT_SPLITTER (
        .dsin(sec),
        .ds1 (w_sec_ds1),  //digit 1
        .ds10(w_sec_ds10)
    );
    //min
    digit_splitter #(
        .BIT_WIDTH(MIN_BIT_WIDTH)
    ) U_MIM_DIGIT_SPLITTER (
        .dsin(min),
        .ds1 (w_min_ds1),  //digit 1
        .ds10(w_min_ds10)
    );
    //hour
    digit_splitter #(
        .BIT_WIDTH(HOUR_BIT_WIDTH)
    ) U_HOUR_DIGIT_SPLITTER (
        .dsin(hour),
        .ds1 (w_hour_ds1),  //digit 1
        .ds10(w_hour_ds10)
    );
    dot_comparator U_DOT_COMPARATOR (
        .msec(msec),
        .dot_onoff(w_dot_onoff)
    );
    //muxer msec
    mux_8x1 U_MSEC_SEC_MUX_8X1 (
        .sel(w_ds_sel),
        .in0(w_msec_ds1),
        .in1(w_msec_ds10),
        .in2(w_sec_ds1),
        .in3(w_sec_ds10),
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_onoff}),  //dot display
        .in7(4'hf),
        .mux_out(w_msec_sec_mux_out)
    );
    //muxer sec
    mux_8x1 U_MIN_HOUR_MUX_8X1 (
        .sel(w_ds_sel),
        .in0(w_min_ds1),
        .in1(w_min_ds10),
        .in2(w_hour_ds1),
        .in3(w_hour_ds10),
        .in4(4'hf),
        .in5(4'hf),
        .in6({3'b111, w_dot_onoff}),  //dot display
        .in7(4'hf),
        .mux_out(w_min_hour_mux_out)
    );

    mux_2x1 U_MUX_DISPLAY_MODE (
        .sel(sw_display_mode),
        .in0(w_msec_sec_mux_out),
        .in1(w_min_hour_mux_out),
        .mux_out(w_mux_out)
    );

    flash_digit U_FLASH_DIGIT (
        .clk(clk),
        .rst(rst),
        .i_clk_2000hz(w_clk_2000hz),
        .o_clk_2hz(w_clk_2hz)
    );
    bcd U_BCD (
        .bin(w_mux_out),
        .ds_sel(w_ds_sel[1:0]),
        .sw_show_mode(sw_show_mode),
        .sw_time_edit(sw_time_edit),
        .selected_digit(selected_digit),
        .i_clk_2hz(w_clk_2hz),
        .fnd_font(fnd_font)
    );

endmodule

//1:1
module dot_comparator (
    input [6:0] msec,
    output dot_onoff
);
    //true : 1 => off / faulse : 0 => on
    assign dot_onoff = (msec >= 50) ? 1 : 0;

endmodule

module mux_2x1 (
    input        sel,
    input  [3:0] in0,
    input  [3:0] in1,
    output [3:0] mux_out
);
    assign mux_out = (sel) ? in1 : in0;

endmodule
module clk_div_2000Hz (
    input clk,
    input rst,
    output reg o_clk_2000hz
);
    reg [15:0] counter_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 16'd0;
            o_clk_2000hz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (25_000 - 1)) begin
                counter_reg  <= 16'd0;
                o_clk_2000hz <= ~(o_clk_2000hz);
            end
        end
    end
endmodule

module counter_8 (
    input        clk,
    input        rst,
    output [2:0] ds_sel
);
    reg [2:0] counter_reg;
    assign ds_sel = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin  //rst == 1 , when board 'ON', rst button, 
            // rst : 1'b1
            counter_reg <= 3'b0;  // '<=' filp-flop // counter_reg Set the initial cost
        end else begin
            // operation
            counter_reg <= counter_reg + 1;
        end
    end
endmodule

module decoder_2x4 (
    input [1:0] ds_sel,
    output reg [3:0] fnd_com
);
    always @(ds_sel) begin
        case (ds_sel)
            2'b00:   fnd_com = 4'b1110;
            2'b01:   fnd_com = 4'b1101;
            2'b10:   fnd_com = 4'b1011;
            2'b11:   fnd_com = 4'b0111;
            default: fnd_com = 4'b1111;
        endcase
    end
endmodule
module mux_8x1 (
    input [2:0] sel,
    input [3:0] in0,
    input [3:0] in1,
    input [3:0] in2,
    input [3:0] in3,
    input [3:0] in4,
    input [3:0] in5,
    input [3:0] in6,
    input [3:0] in7,
    output reg [3:0] mux_out
);
    always @(*) begin
        case (sel)
            3'b000: mux_out = in0;
            3'b001: mux_out = in1;
            3'b010: mux_out = in2;
            3'b011: mux_out = in3;

            3'b100:  mux_out = in4;
            3'b101:  mux_out = in5;
            3'b110:  mux_out = in6;
            3'b111:  mux_out = in7;
            default: mux_out = in0;
        endcase
    end

endmodule
module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH - 1:0] dsin,
    output [            3:0] ds1,
    output [            3:0] ds10
);

    assign ds1  = dsin % 10;  // digit 1
    assign ds10 = (dsin / 10) % 10;
endmodule
module flash_digit (
    input clk,
    input rst,
    input i_clk_2000hz,
    output reg o_clk_2hz
);
    reg [8:0] flash_counter_reg;
    always @(posedge i_clk_2000hz, posedge rst) begin
        if (rst) begin
            flash_counter_reg <= 9'b0;
            o_clk_2hz <= 0;
        end else begin
            flash_counter_reg <= flash_counter_reg + 1;
            if (flash_counter_reg == 9'd499) begin
                flash_counter_reg <= 0;
                o_clk_2hz <= ~o_clk_2hz;
            end
        end
    end
endmodule


module bcd (
    input [3:0] bin,
    input [1:0] ds_sel,
    input sw_show_mode,  //0일때 시계모드
    input sw_time_edit,  //1일때 수정모드
    input [1:0] selected_digit,
    input i_clk_2hz,
    output reg [7:0] fnd_font
);
    always @(*) begin
        if ((~sw_show_mode) && sw_time_edit && (ds_sel == selected_digit)&&i_clk_2hz) begin
            fnd_font = 8'hff;
        end else begin
            case (bin)
                4'b0000: fnd_font = 8'hc0;  //0
                4'b0001: fnd_font = 8'hf9;  //1
                4'b0010: fnd_font = 8'ha4;  //2
                4'b0011: fnd_font = 8'hb0;  //3
                4'b0100: fnd_font = 8'h99;  //4
                4'b0101: fnd_font = 8'h92;  //5
                4'b0110: fnd_font = 8'h82;  //6
                4'b0111: fnd_font = 8'hf8;  //7
                4'b1000: fnd_font = 8'h80;  //8
                4'b1001: fnd_font = 8'h90;  //9
                4'b1010: fnd_font = 8'h88;
                4'b1011: fnd_font = 8'h83;
                4'b1100: fnd_font = 8'hc6;
                4'b1101: fnd_font = 8'ha1;
                4'b1110: fnd_font = 8'h7f;  //segment dot only ON
                4'b1111: fnd_font = 8'hff;  //segment off
                default: fnd_font = 8'hff;
            endcase
        end
    end
endmodule
