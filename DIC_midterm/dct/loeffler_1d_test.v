`timescale 1ns/1ns
module loeffler_1d_test;

parameter clk_time = 5;
parameter max_size = 16; 

wire [11:0] out0;
wire [11:0] out1;
wire [11:0] out2;
wire [11:0] out3;
wire [11:0] out4;
wire [11:0] out5;
wire [11:0] out6;
wire [11:0] out7;


reg rstn, clk;
reg [max_size-1:0] win0, win1, win2, win3, win4, win5, win6, win7;


integer i,j;
reg [7:0]k=0,y1,y2;
integer handle1;

reg [43*8-1:0] stringvar1="E:/project/DIC_hw/midterm/random_data/data_";
reg [4*8-1:0] stringvar2=".txt";
reg [49*8-1:0] filename;

loeffler_1d dct_1d (clk, rstn, win0, win1, win2, win3, win4, win5, win6, win7, 
					out0, out1, out2, out3, out4, out5, out6, out7);
 
reg [7:0] mem0 [0:63];
  
initial
begin
	clk=0;
	forever 
	#clk_time clk=~clk;	//Set clock with a period 10 units  5+5 10ns => 100Mhz
end
  
initial
begin

    //handle1 = $fopen("out.txt");
    
    
    
    rstn = 1'b0;
    i = 0;
    
    #10
    rstn = 1'b1;
    
    for (j=0;j<100;j=j+1) begin
		k=j;
		y1=8'h30+(j/10);
		y2=8'h30 +(j%10);

		filename = {stringvar1,y1,y2,stringvar2};

		$display("%c ",y2);
		$readmemh(filename, mem0);

		for (i = 0; i < 64; i = i + 8)
    	begin	  
			win0 = mem0[i];
			win1 = mem0[i+1];
			win2 = mem0[i+2]; 
			win3 = mem0[i+3]; 
			win4 = mem0[i+4]; 
			win5 = mem0[i+5]; 
			win6 = mem0[i+6]; 
			win7 = mem0[i+7]; 
			#10;
    	end
  
		#200;

	end

    //$fdisplay(handle1," %d, %d, %d, %d, %d, %d, %d, %d,", out0, out1, out2, out3, out4, out5, out6, out7);
	
	//#200 $fclose(handle1);
    #10 $stop; 
         
end

endmodule
