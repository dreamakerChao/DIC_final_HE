`timescale 1ns/1ns

//module sobel_testbench();
module kernel_tb;

reg [7:0] In0, In1, In2, In3, In4, In5, In6, In7;
reg [10:0]th;
wire result;



parameter cycle = 5;
parameter row_size = 512;
parameter column_size = 512;

reg rstn, clk;
reg [7:0] mem0 [0:(row_size*column_size)-1];
reg  mem1 [0:(row_size*column_size)-1];
reg [7:0]data;

integer h,w;
integer  p, q;
integer handle1, handle2;

// Hints !!!!
// design and let input only needed 3x3 pixels when clock rising to the sobel_fillter moudle
// after process you will get 1 pixel output
// inside the module you need to design a 3x3 inner product with sobel parameters


//sobel_fillter UUT ( xxxxxxxxxx  );

kernel  m0 (
                    .clk(clk), .th(th), .result(result),
                    .In0(In0), .In1(In1), .In2(In2), .In3(In3), .In4(In4), .In5(In5),. In6(In6), .In7(In7)
                    );


initial
begin
    clk = 1'b0;
	forever
		#5 clk = ~clk;
end

//initial the mem
initial begin
	$readmemh("E:/project/DIC_hw/hw3/lena_gray.txt", mem0);
	$readmemh("E:/project/DIC_hw/hw3/zero512.txt", mem1);
end


//setup the threshold  
assign rstn = 1'b1;
assign th = 11'd50;

reg done=1'b0;

always @ (negedge rstn)
    begin
        if(~rstn)
            begin
                $readmemh("E:/project/DIC_hw/hw3/lena_gray.txt", mem0);
                $readmemh("E:/project/DIC_hw/hw3/zero512.txt", mem1);
            end
    end


//calculate
initial begin
	$readmemh("E:/project/DIC_hw/hw3/lena_gray.txt", mem0);
    $readmemh("E:/project/DIC_hw/hw3/zero512.txt", mem1);
	#5
	p = 0;

	for (h=1; h<510; h=h+1) begin // 1:510
		for (w=1; w<510 ; w = w+1) begin

			//middle: mem0[h*row_size+w]
			In0 = mem0[(h-1)*row_size+w-1];
			In1 = mem0[(h-1)*row_size+w];
			In2 = mem0[(h-1)*row_size+w+1];

			In3 = mem0[h*row_size+w-1];
			In4 = mem0[h*row_size+w+1];
			
			In5 = mem0[(h+1)*row_size+w-1];
			In6 = mem0[(h+1)*row_size+w];
			In7 = mem0[(h+1)*row_size+w+1];

			#5
			mem1[h*row_size+w] = result;
			#5;

		end
	end

	#10;
	handle1 = $fopen("E:/project/DIC_hw/hw3/sobel_out1.txt");

	for(p=0; p< row_size*column_size; p=p+1) begin
		data = (mem1[p]) ? 8'hFF : 8'h00;

		$fwrite(handle1,"%h ", data);

		if ( (p % 512) == 511) begin
				$fwrite(handle1,"\n");
		end
	end

	$fclose(handle1);
	#10
	$stop;

end


endmodule

