//4비트 가산기

//1비트 가산기
module miner(
    input a,
    input b,
    output s,
    output c
);
    assign s = a^b
    assign c = a &b
endmodule