`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/12 16:26:08
// Design Name: 
// Module Name: button_divi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module button_debounce (
    input  clk,
    input  reset,
    input  i_btn,
    output o_btn
);
    reg[7:0]q_reg;
    reg edge_reg; //edge detct signal
    wire debounce; //debounced
    //8bit shift register : SIPO
    always@(posedge clk,posedge reset)begin
        if(reset)begin
            q_reg <=8'h00;
        end else begin 
            q_reg <= {i_btn,q_reg[7:1]}; //right shift(->) / msb:[7] in, 7:1 -> 6:0
        end
    end

    //8 input AND gate
    assign debounce = &q_reg;
    

    //edge detection
    always@(posedge clk, posedge reset)begin
        if(reset)begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end
    //rising edge, tick gen
    assign o_btn = ~edge_reg & debounce;

endmodule
