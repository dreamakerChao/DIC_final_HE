module kernel (
    input clk,
    /*
    the kernel size: 3*3
    the middle is the target pixel.
    the input number in space:
    
    0  1  2 
    3     4
    5  6  7
    */
    input [7:0]In0,In1,In2,In3,In4,In5,In6,In7,

    // th : threshold
    input [10:0]th,

    //result : 1 for 255, 0 for 0
    output reg result
);
    // pretend no overflow
    // max: 255*4 = +- 1020 
    // temp use 11 bit =>  range : +- 2^(11-1)-1
    reg signed [10:0] temp_x0,temp_x1,temp_x2,temp_x3;
    reg signed [10:0] temp_y0,temp_y1,temp_y2;
    reg signed [10:0] gx,gy;

    // use sqaure to compare, not root 
    reg signed [21:0] g,th_sqare;

    always @(posedge clk) begin
        /*
        the x and y kernel: 
        x: -1  0  1   y: -1 -2 -1
           -2  0  2       0  0  0
           -1  0  1       1  2  1
        */
        temp_x0 = (~In0+1'b1);   // 2's complement => *-1
        temp_x1 = ~(In3<<1)+1'b1; //<<1 and 2's => *-2
        temp_x2 = In4<<1;  // <<1 =>*2
        temp_x3 = ~In5+1'b1;  // 2's complement

        gx = temp_x0 + In2+ temp_x1 + temp_x2 + temp_x3 + In7;
        
        temp_y0 = ~(In1<<1)+ 1'b1;
        temp_y1 = ~In2 + 1'b1;
        temp_y2 = In6<<1;
        
        // [0] [7] is already calculated in x
        gy = temp_x0 + temp_y0 + temp_y1 + In5 + temp_y2 +In7;
    
        g =  (gx*gx + gy*gy); //critical
        th_sqare= th*th;  //critical
    
        // if (gx**2 + gy**2) >= th, then result = true, vice versa.
        result = (g >= th_sqare) ? 1'b1 : 1'b0 ;
    end


endmodule