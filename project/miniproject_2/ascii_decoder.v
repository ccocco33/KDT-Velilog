`timescale 1ns / 1ps
module ascii_decoder (
    input            clk,
    input            rst,
    input            enable,
    input      [7:0] ascii,
    output reg       pop,
    output reg [3:0] bin,
    output reg       mode1,
    output reg       mode2,
    output reg       mode3,
    output reg       mode4
);
    reg [7:0] data_reg, data_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            data_reg <= 0;
        end else begin
            data_reg <= data_next;
        end
    end
    always @(*) begin
        bin = 4'h0;
        pop = 1'b0;
        data_next = data_reg;
        mode1 = 0;
        mode2 = 0;
        mode3 = 0;
        mode4 = 0;
        if (enable) begin
            data_next = ascii;
            pop = 1'b1;

            case (ascii)
                //R ,r
                "R","r": mode1 = 1;
                //C,c
                "C","c": mode2 = 1;
                //U,u
                "U","u": mode3= 1;
                //S,s
                "S","s": mode4 = 1;
            endcase
        end else begin
            case (data_reg)
                8'h30: bin = 4'h0;
                8'h31: bin = 4'h1;
                8'h32: bin = 4'h2;
                8'h33: bin = 4'h3;
                8'h34: bin = 4'h4;
                8'h35: bin = 4'h5;
                8'h36: bin = 4'h6;
                8'h37: bin = 4'h7;
                8'h38: bin = 4'h8;
                8'h39: bin = 4'h9;

                //대문자,소문자
                8'h41, 8'h61: bin = 4'ha;
                8'h42, 8'h62: bin = 4'hb;
                8'h43, 8'h63: bin = 4'hc;
                8'h44, 8'h64: bin = 4'hd;
                8'h45, 8'h65: bin = 4'he;
                8'h46, 8'h66: bin = 4'hf;

                default: bin = 4'b0000;
            endcase
        end
    end

endmodule

// 10.27 수업 끝날때의 아즈키 디코더 , 단순 백업용
// module ascii_decoder (
//     input            clk,
//     input            rst,
//     input            enable,
//     input      [7:0] ascii,
//     output reg       pop,
//     output reg [3:0] bin
// );
//     reg [7:0] data_reg, data_next;
//     // cl 내가함
//     // assign pop = enable;
//     // sl 내가함
//     // reg next_pop;
//     // assign pop = next_pop;


//     always @(posedge clk, posedge rst) begin
//         if (rst) begin
//             data_reg <= 0;
//         end else begin
//             data_reg <= data_next;
//             //sl내가함
//             // next_pop <= enable;
//         end
//     end
//     always @(*) begin
//         bin = 4'h0;
//         pop = 1'b0;
//         data_next = data_reg;
//         if (enable) begin
//             data_next = ascii;
//             pop = 1'b1;
//         end else begin
//             case (data_reg)
//                 8'h30: bin = 4'h0;
//                 8'h31: bin = 4'h1;
//                 8'h32: bin = 4'h2;
//                 8'h33: bin = 4'h3;
//                 8'h34: bin = 4'h4;
//                 8'h35: bin = 4'h5;
//                 8'h36: bin = 4'h6;
//                 8'h37: bin = 4'h7;
//                 8'h38: bin = 4'h8;
//                 8'h39: bin = 4'h9;

//                 //대문자,소문자
//                 8'h41, 8'h61: bin = 4'ha;
//                 8'h42, 8'h62: bin = 4'hb;
//                 8'h43, 8'h63: bin = 4'hc;
//                 8'h44, 8'h64: bin = 4'hd;
//                 8'h45, 8'h65: bin = 4'he;
//                 8'h46, 8'h66: bin = 4'hf;

//                 default: bin = 4'b0000;
//             endcase
//         end
//     end

// endmodule

// module uart_ascii_decoder (
//     input clk,
//     input rst,
//     input rx,
//     output tx,
//     output [7:0] fnd_font,
//     output [3:0] fnd_com
// );
//     wire w_rx_done;
//     wire [7:0] w_rx_data;
//     // wire [3:0] w_decoder_data;
//     wire [3:0] w_bin;
//     // assign fnd_com = 4'b1110;
//     uart_loopback U_UART_LOOPBACK (
//         .clk    (clk),
//         .rst    (rst),
//         .rx     (rx),         //from PC
//         .tx     (tx),         //to PC
//         .rx_done(w_rx_done),
//         .rx_data(w_rx_data)
//     );
//     ascii_decoder U_ASCII_DECODER (
//         .clk(clk),
//         .rst(rst),
//         .enable    (w_rx_done),
//         .ascii(w_rx_data),
//         .bin       (w_bin)
//     );
//     fnd_controller U_FND_CNTL (
//         .clk(clk),
//         .reset(rst),
//         .fnd_data(w_bin),  //9bit , {c,s}
//         .fnd_com(fnd_com),
//         .fnd_font(fnd_font)
//     );
//     // ascii_decoder U_ASCII_DECODER (
//     //     .clk(clk),
//     //     .rst(rst),
//     //     .rx_done(w_rx_done),
//     //     .rx_data(w_rx_data),
//     //     .decoder_data(w_decoder_data)
//     // );


//     // bcd U_BCD (
//     //     .decoder_data(w_decoder_data),
//     //     .fnd_font(fnd_font)
//     // );
// endmodule

// module ascii_decoder (
//     input clk,
//     input rst,
//     input rx_done,
//     input [7:0] rx_data,
//     output [3:0] decoder_data
// );
//     reg [3:0]decoder_data_reg,decoder_data_next;
//     assign decoder_data = decoder_data_reg;
//     always@(posedge clk,posedge rst)begin
//         if(rst)begin
//             decoder_data_reg <=0;
//         end else begin
//             decoder_data_reg <= decoder_data_next;
//         end
//     end
//     always @(*) begin
//         decoder_data_next=decoder_data_reg;
//         if(rx_done)begin
//         case (rx_data)
//             8'h30:   decoder_data_next = 4'b0000;
//             8'h31:   decoder_data_next = 4'b0001;
//             8'h32:   decoder_data_next = 4'b0010;
//             8'h33:   decoder_data_next = 4'b0011;
//             8'h34:   decoder_data_next = 4'b0100;
//             8'h35:   decoder_data_next = 4'b0101;
//             8'h36:   decoder_data_next = 4'b0110;
//             8'h37:   decoder_data_next = 4'b0111;
//             8'h38:   decoder_data_next = 4'b1000;
//             8'h39:   decoder_data_next = 4'b1001;

//             8'h41:   decoder_data_next = 4'b1010;
//             8'h42:   decoder_data_next = 4'b1011;
//             8'h43:   decoder_data_next = 4'b1100;
//             8'h44:   decoder_data_next = 4'b1101;
//             8'h45:   decoder_data_next = 4'b1110;
//             8'h46:   decoder_data_next = 4'b1111;

//             8'h61:   decoder_data_next = 4'b1010;
//             8'h62:   decoder_data_next = 4'b1011;
//             8'h63:   decoder_data_next = 4'b1100;
//             8'h64:   decoder_data_next = 4'b1101;
//             8'h65:   decoder_data_next = 4'b1110;
//             8'h66:   decoder_data_next = 4'b1111;
//             default: decoder_data_next = 4'b0000;
//         endcase
//         end
//     end
// endmodule

// module bcd (
//     input [3:0] decoder_data,
//     output reg [7:0] fnd_font
// );
//     always @(*) begin
//         case (decoder_data)
//             4'b0000: fnd_font = 8'hc0;  //0
//             4'b0001: fnd_font = 8'hf9;  //1
//             4'b0010: fnd_font = 8'ha4;  //2
//             4'b0011: fnd_font = 8'hb0;  //3
//             4'b0100: fnd_font = 8'h99;  //4
//             4'b0101: fnd_font = 8'h92;  //5
//             4'b0110: fnd_font = 8'h82;  //6
//             4'b0111: fnd_font = 8'hf8;  //7
//             4'b1000: fnd_font = 8'h80;  //8
//             4'b1001: fnd_font = 8'h90;  //9
//             4'b1010: fnd_font = 8'h88;  //a
//             4'b1011: fnd_font = 8'h83;  //b
//             4'b1100: fnd_font = 8'hc6;  //c
//             4'b1101: fnd_font = 8'ha1;  //d
//             4'b1110: fnd_font = 8'h86;  //e 
//             4'b1111: fnd_font = 8'h8e;  //f 
//             default: fnd_font = 8'hff;  //off
//         endcase
//     end

// endmodule
