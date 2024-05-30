module HE(
    input wire clk,
    input wire reset,
    input wire [7:0] pixel_value,
    output reg [7:0] transformed_pixel,
    output reg done
);
    // Parameters
    parameter IMAGE_WIDTH = 660;  // Example image width
    parameter IMAGE_HEIGHT = 440; // Example image height
    parameter NUM_PIXELS = IMAGE_WIDTH * IMAGE_HEIGHT;
    parameter NUM_BINS = 256;
    //parameter Lsub1_divMN = (NUM_BINS-1)/NUM_PIXELS;

    // Internal registers
    reg [15:0] histogram [NUM_BINS-1:0];
    reg [31:0] cdf [NUM_BINS-1:0];
    //reg [31:0] cdf_min;
    reg [31:0] tmp;
    reg [31:0] pixel_count;
    reg [7:0] transformation_table [NUM_BINS-1:0];
    integer i, j;

    // State machine states
    reg [2:0] current_state;

    // State definitions
    localparam IDLE = 3'b000,
               CALC_HIST = 3'b001,
               CALC_CDF = 3'b010,
               APPLY_TRANSFORM = 3'b011,
               FINISH = 3'b100;

    // State machine and logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers
            current_state <= CALC_HIST;
            done <= 1'b0;
            pixel_count <= 32'b0;
            //cdf_min <= 32'b0;
            //num_pixels <= 32'b0;
            transformed_pixel <= 8'b0;

            for (i = 0; i < NUM_BINS; i = i + 1) begin
                histogram[i] <= 16'b0;
                cdf[i] <= 32'b0;
                transformation_table[i] <= 8'b0;
            end
        end else begin
                /*
                for(i=0;i <= NUM_PIXELS;i = i+1)begin
                    histogram[pixel_value] <= histogram[pixel_value] + 1;
                    pixel_count <= pixel_count + 1;
                end

                */
            case (current_state)
                CALC_HIST: begin
					if (pixel_count == NUM_PIXELS) begin
                        current_state = CALC_CDF;
                    end
					else begin
                        histogram[pixel_value] = histogram[pixel_value] + 1;
                        pixel_count = pixel_count + 1;
					end
                end

				// 以下需修改 ///
                // cumulative distribution function
                CALC_CDF: begin

                    cdf[0] = histogram[0];
                    for (j = 1; j < NUM_BINS; j = j + 1) begin
						cdf[j] = cdf[j-1] + histogram[j];
					end

                    /*
                    for (j = 0; j < NUM_BINS; j = j + 1) begin
						if (j == 0) begin
							cdf[0] = histogram[0];
						end else begin
							cdf[j] = cdf[j-1] + histogram[j];
						end
                    end
                    */

					current_state = APPLY_TRANSFORM;
                end
                APPLY_TRANSFORM: begin
                    for (i = 0; i < NUM_BINS; i = i + 1) begin
                        tmp  = 255*cdf[i];
                        transformation_table[i] = tmp / NUM_PIXELS; //L-1 = NUM_BINS-1 = 255
                    end
                    current_state = FINISH;
                end
                FINISH: begin
					transformed_pixel <= transformation_table[pixel_value];
                    done <= 1'b1;
                end

            endcase
        end
    end

endmodule
