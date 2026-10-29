`timescale 1ns / 1ps


module ascii_sender (
    input         clk,
    input         rst,
    input         cmd,
    input  [31:0] send_data,
    input         sw0,
    input         sw1,
    output [ 7:0] split_byte
);
    reg [31:0] send_data_reg;
    reg [7:0] split_byte_reg, split_byte_next;
    reg [7:0] ascii_byte;
    reg [2:0] counter_reg,counter_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            split_byte_reg <= 0;
            send_data_reg  <= 0;
            counter_reg<=0;
        end else begin
            split_byte_reg <= ascii_byte;
            counter_reg<=counter_next;
        end
    end

    always @(*) begin
        //현재는 send_data가 들어오는때랑 들어오고나서 그사이에 스위치가 달라지면 그부분에서는 대응 안되어있음
        //cmd 신호 들어왔을 때 - send_data 저장 & 첫 8bit
        if (cmd) begin
            send_data_next = send_data;
            if(sw1)begin // 시계 
            split_byte_next = [31:24]send_data;
            end else begin
            end
            
        end else begin
            //
        end


        //
    end

endmodule
