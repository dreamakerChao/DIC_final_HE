`timescale 1ns/1ns

module Histogram_Equalization_Testbench;

reg clk;
reg reset;
reg [7:0] pixel_in;
wire [7:0] pixel_out;

parameter IMG_WIDTH = 512;
parameter IMG_HEIGHT = 512;
parameter NUM_PIXELS = 262144; // 512*512 = 262144
reg [7:0] mem0 [0:NUM_PIXELS-1];
reg [7:0] mem1 [0:NUM_PIXELS-1];

integer i, j, p;
integer handle;

// Instantiate the module under test
Histogram uut (
    .clk(clk),
    .reset(reset),
    .pixel_in(pixel_in),
    .pixel_out(pixel_out)
);

// Clock generation
initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

// Reset generation
initial begin
    reset = 1'b1;
    pixel_in = 1'b0;
end

always @ (negedge rstn)
    begin
        if(~reset)
            begin
                $readmemh("C:/Users/97137/Desktop/DIC/Final report/convert/lena_gray1.txt", mem0);
                $readmemh("C:/Users/97137/Desktop/DIC/Final report/Program/zero512.txt", mem1);
            end
    end

for (i=0; i<511; i=i+1) begin // 0:511
		for (j=0; j<511 ; j=j+1) begin

			pixel_in =  mem0[i*row_size+j]
			#5
			mem1[i*row_size+j] = pixel_out;
			#5;

		end
	end
// Stimulus generation
initial begin
    // Open output file
    handle = $fopen("C:/Users/97137/Desktop/DIC/Final report/convert/lena_gray1_o.txt", "w");

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
