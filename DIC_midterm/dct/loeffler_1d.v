module loeffler_1d(
    input clk,
    input rstn,
    input signed [15:0] win0, win1, win2, win3, win4, win5, win6, win7,
    output reg signed[11:0] out0, out1, out2, out3, out4, out5, out6, out7
);

parameter PI = 3,PT = 6,A = 35,B = 84,C = 53,D = 35,E = 63,F = 12;

reg signed [11:0] v_data0, v_data1, v_data2, v_data3, v_data4, v_data5, v_data6, v_data7;
reg signed [11:0] v_data8, v_data9, v_data10, v_data11;

always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
        out0 = 12'd0;
        out1 = 12'd0;
        out2 = 12'd0; 
        out3 = 12'd0;
        out4 = 12'd0; 
        out5 = 12'd0; 
        out6 = 12'd0; 
        out7 = 12'd0;
        
    end else begin
        //stage 1
        v_data0 = win0 + win7; // vp0
        v_data1 = win1 + win6; // vp1
        v_data2 = win2 + win5; // vp2
        v_data3 = win3 + win4; // vp3

        v_data4 = win0 - win7;	// vn0
        v_data5 = win1 - win6;	// vn1
        v_data6 = win2 - win5;	// vn2
        v_data7 = win3 - win4;	// vn3

        //stage 2
        v_data8 = v_data0 + v_data3;  // vp0+vp3
        v_data9 = v_data1 + v_data2;  // vp1+vp2
        v_data10 = v_data0 - v_data3; // vp0-vp3
        v_data11 = v_data1 - v_data2; // vp1-vp2
		
		//stage 3
		out0 = (v_data8 + v_data9);
		out1 = ((((-v_data7)*D+v_data4*C)+(v_data6*E+v_data5*F))+((v_data7*C+v_data4*D) + ((-v_data6)*F+v_data5*E)))>>6;
		out2 = (v_data11*A+v_data10*B)>>6;
		out3 = (PT*(((-v_data7)*D+v_data4*C)-(v_data6*E+v_data5*F)))>>8;
		out4 = (v_data8 -v_data9);
		out5 = (PT*((v_data7*C+v_data4*D)-((-v_data6)*F+v_data5*E)))>>8;  
		out6 = ((-v_data11)*B+v_data10*A)>>6;
		out7 = ((((-v_data7)*D+v_data4*C)+(v_data6*E+v_data5*F))-((v_data7*C+v_data4*D) + ((-v_data6)*F+v_data5*E)))>>6;
			
    end
end

endmodule