`timescale 1ns / 1ps

// ==================== 기존 테스트벤치 (주석 처리) ====================
/*

module tb_counter_10000 ();
    reg clk,reset,up_down,run_stop,clear;
    wire [13:0]counter;
    counter_datapath dut (
        .clk(clk),
        .reset(reset),
        .run_stop(run_stop),
        .clear(clear),
        .up_down(up_down),
        .counter(w_counter)
    );
    //gen 100Mhz clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        run_stop = 1;
        clear = 0;
        up_down = 0;
        # 10;
        reset = 0;
        //#(250_000 clk *10nces(1clock*));
        // repeat(3)begin//loop ,#(10_000_000*10);
        //run_stop
        
        #10
        //up_down
        up_down = 1;
        # 10_0000000;
        up_down = 0;
        # 10_000;
        //clear
        # 10;
        clear = 0;
        #1000
        run_stop  = 0;
        
        
        $stop;
    end

endmodule
*/

// module tb_counter_10000 ();
//     reg clk, reset, up_down, run_stop, clear;
//     wire [13:0] counter;

//     counter_datapath dut (
//         .clk(clk),
//         .reset(reset),
//         .run_stop(run_stop),
//         .clear(clear),
//         .up_down(up_down),
//         .counter(counter)
//     );
//     // 시뮬레이션용 tick 주기 줄이기 (10_000_000 -> 10, tick = 100ns 마다)
//     // defparam dut.U_TICK_GEN.F_COUNT = 10;

//     //gen 100Mhz clock
//     always #5 clk = ~clk;

//     initial begin
//         clk = 0;
//         reset = 1;
//         run_stop = 1;
//         clear = 0;
//         up_down = 0;
//         #20;
//         reset = 0;

//         // 1) 경계값 0000 -> 9999 (down)
//         // up_down = 1;
//         // #100_001_000;

//         // 2) 경계값 9999 -> 0000 (up)
//         up_down = 0;
//         #100_001_000;

//         run_stop = 0;
//         #100_001_000;

//         //clear 1
//         clear = 1;
//         #100_001_000;

//         $stop;
//     end

// endmodule


/*
module tb_counter_10000 ();
    parameter BD_PUSH_TIME = 1000;

    reg clk, reset, btnU, btnL, btnR;
    wire [3:0] fnd_com;
    wire [7:0] fnd_font;
    counter_10000 dut (
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .fnd_font(fnd_font),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btnU  = 0;
        btnL  = 0;
        btnR  = 0;
        #10;
        reset = 0;

        btnR  = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;

        repeat (3) begin
            #(10_000_000 * 10);
        end
        btnR  = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        $stop;
    end
endmodule
*/

// ==================== 새 테스트벤치 ====================
// 시나리오:
//   1) btnR -> run_stop 1 -> counter 증가 (up)
//   2) btnR -> run_stop 0 (STOP)
//   3) btnU -> mode 1 (down)   ※ controll_unit은 STOP 상태에서만 btn_mode를 받음
//   4) btnR -> run_stop 1 -> counter 감소
/*
module tb_counter_10000 ();
    parameter BD_PUSH_TIME = 1000;  // 버튼 누르는 시간 (clk 수)
    parameter TICK_TIME = 10_000_000 * 10;  // tick 1번 = 100ms

    reg clk, reset, btnU, btnL, btnR;
    wire [3:0] fnd_com;
    wire [7:0] fnd_font;
    counter_10000 dut (
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .fnd_font(fnd_font),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btnU  = 0;
        btnL  = 0;
        btnR  = 0;
        #10;
        reset = 0;
        repeat (100) @(posedge clk);

        // 1) btnR -> RUN, counter 증가
        btnR = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        repeat (3) #(TICK_TIME);  // counter 0 -> 3

        // 2) btnR -> STOP
        btnR = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        repeat (BD_PUSH_TIME) @(posedge clk);

        btnL = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnL = 0;
        // // 3) btnU -> mode 1 (down)
        // btnU = 1;
        // repeat (BD_PUSH_TIME) @(posedge clk);
        // btnU = 0;
        // repeat (BD_PUSH_TIME) @(posedge clk);

        // // 4) btnR -> RUN, counter 감소
        // btnR = 1;
        // repeat (BD_PUSH_TIME) @(posedge clk);
        // btnR = 0;
        // repeat (5) #(TICK_TIME);  // counter 3 -> 2 -> 1 -> 0 -> 9999 -> 9998

        $stop;
    end
endmodule
*/

// ==================== 9999 -> 0000 테스트벤치 ====================
// 시뮬 주기(F_COUNT)를 바꾸지 않고 9999 -> 0000을 보기 위해
// down 모드로 0 -> 9999를 먼저 만든 뒤 up 모드로 전환한다.
// (up 모드로 0부터 9999까지 세면 9999 tick = 약 1000초가 걸림)
// 시나리오:
//   1) btnU -> mode 1 (down)   ※ STOP 상태에서만 btn_mode를 받음
//   2) btnR -> RUN -> counter 0 -> 9999
//   3) btnR -> STOP
//   4) btnU -> mode 0 (up)
//   5) btnR -> RUN -> counter 9999 -> 0000 -> 0001
module tb_counter_10000 ();
    parameter BD_PUSH_TIME = 1000;  // 버튼 누르는 시간 (clk 수)
    parameter TICK_TIME = 10_000_000 * 10;  // tick 1번 = 100ms

    reg clk, reset, btnU, btnL, btnR;
    wire [3:0] fnd_com;
    wire [7:0] fnd_font;
    counter_10000 dut (
        .clk(clk),
        .reset(reset),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .fnd_font(fnd_font),
        .fnd_com(fnd_com)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        btnU  = 0;
        btnL  = 0;
        btnR  = 0;
        #10;
        reset = 0;
        repeat (100) @(posedge clk);

        // 1) btnU -> mode 1 (down)
        btnU = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnU = 0;
        repeat (BD_PUSH_TIME) @(posedge clk);

        // 2) btnR -> RUN, counter 0 -> 9999
        btnR = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        repeat (1) #(TICK_TIME);

        // 3) btnR -> STOP
        btnR = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        repeat (BD_PUSH_TIME) @(posedge clk);

        // 4) btnU -> mode 0 (up)
        btnU = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnU = 0;
        repeat (BD_PUSH_TIME) @(posedge clk);

        // 5) btnR -> RUN, counter 9999 -> 0000 -> 0001
        btnR = 1;
        repeat (BD_PUSH_TIME) @(posedge clk);
        btnR = 0;
        repeat (2) #(TICK_TIME);

        $stop;
    end
endmodule
