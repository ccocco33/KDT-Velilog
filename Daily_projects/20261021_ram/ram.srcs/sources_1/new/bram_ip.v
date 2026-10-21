`timescale 1ns / 1ps

module bram_ip (
    input        clk,
    input        we,
    input [7:0] addr,
    input  [7:0] wdata,
    output reg [7:0] rdata
);
    reg[7:0]ram[0:255]; //8bit배열 8개
    //순차
    always @(posedge clk)begin
        //write
        if(we)ram[addr]<=wdata;
        //SL output
        else rdata <= ram[addr];
    end 
    //조합 CL output
    // assign rdata = ram[addr];

endmodule