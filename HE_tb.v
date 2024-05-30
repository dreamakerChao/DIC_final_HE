`timescale 1ns/1ns
module HE_tb;
    // Parameters
    parameter IMAGE_WIDTH = 660;
    parameter IMAGE_HEIGHT = 440;
    parameter NUM_PIXELS = IMAGE_WIDTH * IMAGE_HEIGHT;
    parameter clock_period = 10; //10ns

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] pixel_value;

    // Outputs
    wire [7:0] transformed_pixel;
    wire done;

    // Memory to store the image pixels
    reg [7:0] mem0 [0:NUM_PIXELS-1];
    reg [7:0] mem1 [0:NUM_PIXELS-1];
    reg [7:0] data;

    // table
    reg [7:0] transformation_table[255:0]; 

    //temp for table
    reg [7:0] temp;

    integer i, j, p;
    integer handle;

    // Instantiate the Unit Under Test (UUT)
    HE uut (
        .clk(clk),
        .reset(reset),
        .pixel_value(pixel_value),
        .transformed_pixel(transformed_pixel),
        .done(done)
    );

    // Initialize the memory
    initial begin
        $readmemh("D:/Modelsim/Hsit_t/chickens.txt", mem0);
        $readmemh("D:/Modelsim/Hsit_t/zero_matrix.txt", mem1);
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #(clock_period/2) clk = ~clk; // 100 MHz clock
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        $readmemh("D:/Modelsim/Hsit_t/zero_matrix.txt", mem1);
        pixel_value = 0;

        // Wait for global reset
        #100;
        reset = 0;

        // Load pixels into the module

        /*
        for (i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT; i = i + 1) begin
            pixel_value = mem0[i]; // Use pixel values from memory
            #10; // Wait for a clock cycle
            mem1[i] = transformed_pixel;
        end
        */

        for (i=0; i<IMAGE_HEIGHT-1; i=i+1) begin // 0:511
            for (j=0; j<IMAGE_WIDTH-1 ; j=j+1) begin

                pixel_value =  mem0[i*IMAGE_WIDTH+j];
                #10;
                //mem1[i*IMAGE_WIDTH+j] = transformed_pixel;
                //#30;

            end
        end


        // start to receive      
        wait(done);
        for (i=0; i<NUM_PIXELS; i=i+1) begin
            #(clock_period/2);
            transformation_table[i] = transformed_pixel;
            #(clock_period/2);
        end

        // receive completed

        for (i=0; i<NUM_PIXELS; i=i+1) begin
            temp = mem0[i];
            mem1[i] = transformation_table[temp];
            #(clock_period);
        end

		#1000;

        handle = $fopen("D:/Modelsim/Hsit_t/chickens_o.txt", "w");
        for(p = 0; p < NUM_PIXELS; p = p + 1) begin
		//data = (mem1[p]) ? 8'hFF : 8'h00;
        data = mem1[p];

		$fwrite(handle,"%h ", data);

		    if ( (p % IMAGE_WIDTH) == IMAGE_WIDTH-1) begin
				$fwrite(handle,"\n");
		    end
	    end

        // Add more test cases if necessary

        $stop; // End simulation
    end
endmodule
