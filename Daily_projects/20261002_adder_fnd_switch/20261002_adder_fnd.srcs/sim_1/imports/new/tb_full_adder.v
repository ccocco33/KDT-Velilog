`timescale 1ns / 1ps

module tb_adder_fnd ();

    reg [7:0] a, b;
    reg [1:0] ds_sel;
    wire [3:0] fnd_com;
    wire [7:0] fnd_font;


    adder_fnd DUT (
        .a(a),
        .b(b),
        .ds_sel(ds_sel),
        .fnd_com(fnd_com),
        .fnd_font(fnd_font)
    );
    //a b 0~255
    
    integer i,j,z;
    initial begin
        a= 0;
        b =0;   

        for(i = 0;i<16;i=i+1)begin
            for(z =0;z<16;z=z+1)begin
                for(j = 0;j<4;j=j+1)begin
                    a = i;
                    b = z;
                    ds_sel =j;
                    # 10;
                end
            end
            
        end
        
        $finish;
    end
endmodule
