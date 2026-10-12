`timescale 1ns / 1ps


// module seq_det_mealy (
//     input  clk,
//     input  rst,
//     input  din_bit,
//     output dout_bit

// );
//     reg [2:0] state_reg, next_state;
//     parameter start = 3'b000;
//     parameter rd0_once = 3'b001;
//     parameter rd1_once = 3'b010;
//     parameter rd0_twice = 3'b011;
//     parameter rd1_twice = 3'b100;
//     always @(posedge clk,posedge rst)begin
//         if(rst)begin
//             state_reg <= start;
//         end else begin
//             state_reg <= next_state;
//         end
//     end

//     always @(state_reg or din_bit) begin
//         dout_bit = 1'b0;
//         case (state_reg)
//             start:
//             if (din_bit == 0) next_state = rd0_once;
//             else if (din_bit == 1) next_state = rd1_once;
//             else next_state = start;
//             rd0_once:
//             dout_bit = 1'b0;
//             if (din_bit == 0) next_state = rd0_twice;
//             else if (din_bit == 1) begin
//                 // dout_bit = 1'b1; // 이런식으로 하면 누를때 바로 반영,mealy
//                 next_state = rd1_once;
//             end
//             else next_state = start;
//             rd0_twice:
//             if (din_bit == 0) next_state = rd0_twice;
//             else if (din_bit == 1) next_state = rd1_once;
//             else next_state = start;
//             rd1_once:
//             if (din_bit == 0) next_state = rd0_once;
//             else if (din_bit == 1) next_state = rd1_twice;
//             else next_state = start;
//             rd1_twice:
//             if (din_bit == 0) next_state = rd0_once;
//             else if (din_bit == 1) next_state = rd1_twice;
//             else next_state = start;
//             default: next_state = start;
//         endcase
//     end
//     always @(posedge clk, posedge rst) begin
//         if (rst == 1) state_reg <= start;
//         else state_reg <= next_state;
//     end
//     //mealy
//     // assign dout_bit = (((state_reg == rd0_twice)&&(din_bit == 0)||(state_reg == rd1_twice)&&(din_bit == 1)))? 1:0;
    
//     //moore
//     assign dout_bit = ((state_reg == rd0_twice)||(state_reg == rd1_twice)) ? 1:0;
// endmodule

//mealys
module non_overlap_mealy(
    input clk,
    input reset,
    input  din_bit,
    output reg dout_bit
);
    parameter S0=2'b00,S1=2'b01,S2=2'b10,S3=2'b11;
    reg [1:0]n_state,c_state;

    always@(posedge clk or posedge reset)begin
        if(reset)begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*)begin
        n_state = c_state;
        dout_bit = 1'b0;
        case(c_state)
            S0:begin
                if(din_bit == 1'b1) n_state = S0;
                else if(din_bit == 1'b0) n_state =S1;
            end
            S1: begin
                if(din_bit == 1'b1) n_state = S2;
                else if(din_bit == 1'b0) n_state =S1;
            end
            S2: begin
                if(din_bit == 1'b1) n_state = S0;
                else if(din_bit == 1'b0) n_state =S3;
            end
            S3: begin
                if(din_bit == 1'b1) begin
                    n_state = S0;
                    dout_bit = 1'b1;
                    $display("+1");
                end 
                else if(din_bit == 1'b0) n_state =S1;
            end
        endcase
    end
endmodule

//moore
module non_overlap_moore(
    input clk,
    input reset,
    input  din_bit,
    output reg dout_bit
);
    parameter S0=3'b000,S1=3'b001,S2=3'b010,S3=3'b011,S4 = 3'b100;
    reg [2:0]n_state,c_state;

    always@(posedge clk or posedge reset)begin
        if(reset)begin
            c_state <= S0;
        end else begin
            c_state <= n_state;
        end
    end
    always @(*)begin
        n_state = c_state;
        dout_bit = 1'b0;
        case(c_state)
            S0:begin
                if(din_bit == 1'b1) n_state = S0;
                else if(din_bit == 1'b0) n_state =S1;
            end
            S1: begin
                if(din_bit == 1'b1) n_state = S2;
                else if(din_bit == 1'b0) n_state =S1;
            end
            S2: begin
                if(din_bit == 1'b1) n_state = S0;
                else if(din_bit == 1'b0) n_state =S3;
            end
            S3: begin
                if(din_bit == 1'b1) n_state = S4;
                else if(din_bit == 1'b0) n_state =S1;
            end
            S4: begin
                dout_bit = 1'b1;
                $display("+1");
                if(din_bit == 1'b1) n_state = S0;
                else if(din_bit == 1'b0) n_state =S1;
            end
        endcase
    end
endmodule