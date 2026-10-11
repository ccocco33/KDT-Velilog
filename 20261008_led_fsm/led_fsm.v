`timescale 1ns / 1ps


// module led_fsm(
//     input        clk,
//     input        reset,
//     input         sw0,
//     output [1:0] led
//     );
//     parameter S1 = 1'b1,S2 = 1'b0;
//     reg current_state,next_state;
//     //state register
//     always @(posedge clk,posedge reset) begin
//         if(reset) begin
//             current_state <=S1; //시퀀셜
//         end else begin
//             current_state <= next_state;
//         end
//     end
//     //next state combinational logic
//     always @(*)begin //입력을 감시한다.
//         if(current_state==S1) begin
//             if(sw0==1'b1)begin
//                 next_state = S2;
//             end else begin
//                 next_state = current_state;
//             end
//         end else if(current_state ==S2)begin
//             if(sw0==1'b0)begin
//                 next_state = S1;
//             end else begin
//                 next_state = current_state;
//             end
//         end else begin
//             next_state = current_state;
//         end
//     end
//     assign led = (current_state == S1) ? 2'b01:2'b10;
// endmodule

// module led_fsm1 (
//     input        clk,
//     input        reset,
//     input  [1:0] sw,
//     output reg [2:0] led
// );
//     parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b111;
//     reg [2:0] c_state, n_state;
//     //output CL , 구문상 위치는 상관 없음
//     // assign led = (c_state == S0) ? 3'b000: 
//     //              (c_state == S1) ? 3'b001:
//     //              (c_state == S2) ? 3'b010:
//     //              (c_state == S3) ? 3'b100:
//     //              (c_state == S4) ? 3'b111:3'b000;
//     // always @(*) begin
//     //     led = 3'b000;
//     //     case(c_state)
//     //         S0:led = 3'b000;
//     //         S1:led = 3'b001;
//     //         S2:led = 3'b010;
//     //         S3:led = 3'b100;
//     //         S4:led = 3'b111;
//     //     endcase
//     // end
//     //state register : SL
//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             c_state <= S0;  //시퀀셜
//         end else begin
//             c_state <= n_state;
//         end
//     end
//     //next state combinational logic :CL
//     always @(*) begin  //입력을 감시한다.
//         n_state = c_state; // <초깃값 설정> 이게 있으면 else, default 를 하지 않아도 latch가 발생 안함.
//         //always로 조합논리로 하다보면 풀케이스 안해서 latch발생 쉬움
//         led = 3'b110;
//         case (c_state)
//             S0: begin
//                 led = 3'b000;
//                 if (sw == 2'b01) n_state = S1;
//                 else n_state = c_state; //else문을 처리하지 않았을 때 latch 발생
//             end
//             S1: begin
//                 led = 3'b001;
//                 if (sw == 2'b10) n_state = S2;
//                 else n_state = c_state;
//             end
//             S2: begin
//                 led = 3'b010;
//                 if (sw == 2'b11) n_state = S3;
//                 else n_state = c_state;
//             end
//             S3: begin
//                 led = 3'b100;
//                 if (sw == 2'b01) n_state = S1;
//                 else if (sw == 2'b00) n_state = S0;
//                 else if (sw == 2'b10) n_state = S4;
//                 else n_state = c_state;
//             end
//             S4: begin
//                 led = 3'b111;
//                 if (sw == 2'b00) n_state = S0;
//                 else n_state = c_state;
//             end
//             default n_state = c_state; //default가 없으면 latch발생 (값을 유지하려고 강제로 넣음 근데 이 latch를 못빠져 나올대가 있음. 디폴트 넣어야함)
//         endcase
//     end
// endmodule

module counter_10000 (
    input        clk,
    input        reset,
    input        run_stop,
    input        clear,
    input        up_down,
    output [7:0] fnd_font,
    output [3:0] fnd_com
);
    wire [13:0] w_counter;
    counter_datapath U_COUNTER_DATAPATH (
        .clk(clk),
        .reset(reset),
        .counter(w_counter),
        .run_stop(run_stop),
        .clear(clear),
        .up_down(up_down)
    );
    fnd_controller U_FND_CONTROLLER (
        .clk(clk),
        .reset(reset),
        .fnd_data(w_counter),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );

endmodule

module counter_datapath (
    input         clk,
    input         reset,
    input         clear,
    input         run_stop,
    input         up_down,
    output [13:0] counter
);
    wire w_tick;
    wire [1:0] w_state;
    tick_counter U_TICK_COUNTER (
        .clk    (clk),
        .reset  (reset),    
        .i_tick (w_tick),
        .up_down(up_down),
        .i_state(w_state),
        .counter(counter)
    );

    tick_gen U_TICK_GEN (
        .clk    (clk),
        .reset  (reset),     
        .i_state(w_state),
        .o_tick (w_tick)
    );
    fsm U_FSM (
        .run_stop(run_stop),  //sw0
        .clear(clear),     //sw1
        .reset(reset),
        .clk(clk),
        .state(w_state)
    );
endmodule

module tick_counter (
    input         clk,
    input         reset,          
    input         i_tick,
    input         up_down,
    input  [ 1:0] i_state,
    output [13:0] counter
);
    reg [13:0] counter_reg;  // tick_gen 의 counter_reg와 다르다.
    assign counter = counter_reg;

    always @(posedge clk, posedge reset) begin   
        if (reset) begin                         
            counter_reg <= 0;
        end else if (i_state == 2'b01) begin     // clear (동기)
            counter_reg <= 0;
        end else begin
            if (!up_down) begin
                if (i_tick) begin
                    counter_reg <= counter_reg + 1;
                    if (counter_reg == (10000 - 1)) begin
                        counter_reg <= 0;
                    end
                end
            end else begin
                if (i_tick) begin
                    counter_reg <= counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_reg <= 9999;
                    end
                end
            end
        end
    end
endmodule

module tick_gen (
    input        clk,
    input        reset, 
    input  [1:0] i_state,             
    output       o_tick
);
    parameter F_COUNT = 10_000_000;

    reg [$clog2(F_COUNT)-1:0] counter_reg;
    reg tick_reg;

    assign o_tick = tick_reg;

    always @(posedge clk, posedge reset) begin   
        if (reset) begin                         
            counter_reg <= 0;
            tick_reg <= 0;
        end else if (i_state == 2'b01) begin     // clear
            counter_reg <= 0;
            tick_reg <= 0;
        end else if (i_state == 2'b00) begin     // stop
            tick_reg <= 0;
        end else begin                           // run
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_reg <= 1'b1;
            end else begin
                tick_reg <= 1'b0;
            end
        end
    end
endmodule

module fsm (
    input        run_stop,  //sw0
    input        clear,     //sw1
    input        reset,
    input        clk,
    output [1:0] state
);
    //S0: stop,clear S1: run,S3:clear
    parameter S0 = 2'b00, S1 = 2'b10, S2 = 2'b01;

    reg [1:0] c_state, n_state;  //2bit / front:sw0 , back:sw1
    reg [1:0] out_state;
    assign state = c_state;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            c_state <= S2;
        end else begin
            c_state <= n_state;
        end
    end
    always @(*) begin
        n_state = c_state;
        case (c_state)
            S0: begin
                if (run_stop == 1) n_state = S1;
                else if (clear == 1) n_state = S2;
                else n_state = c_state;
            end
            S1: begin
                if (run_stop == 0) n_state = S0;
                else n_state = c_state;
            end
            S2: begin
                if (clear == 0) n_state = S0;
                else n_state = c_state;
            end
            default n_state = c_state;
        endcase
    end

endmodule
