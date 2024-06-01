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
    reg [18:0] histogram [NUM_BINS-1:0];
    reg [18:0] cdf [NUM_BINS-1:0];

    //reg [31:0] cdf_min;
    reg [31:0] pixel_count;
    reg [7:0] transformation_table [NUM_BINS-1:0];
    integer i, j;

    // State machine states
    reg [2:0] current_state;

    //counter
    reg [18:0] counter;
    reg [8:0] j_counter;

    // State definitions
    localparam IDLE = 3'b000,
               CALC_HIST = 3'b001,
               CALC_CDF = 3'b010,
               APPLY_TRANSFORM = 3'b011,
               FINISH_SEND = 3'b100;
               //SEND = 3'b101;

    // State machine and logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers
            current_state <= CALC_HIST;
            done <= 0;
            pixel_count <= 0;
            //cdf_min <= 32'b0;
            //num_pixels <= 32'b0;
            transformed_pixel <= 0;
            j_counter<=0;
            counter<=0;
            
            for (i = 0; i < NUM_BINS; i = i + 1) begin
                histogram[i] <= 0;
                cdf[i] <= 0;
                transformation_table[i] <= 0;
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
                        current_state <= CALC_CDF;
                    end
					else begin
                        histogram[pixel_value] <= histogram[pixel_value] + 1;
                        pixel_count <= pixel_count + 1;
					end
                    j_counter<=1;
                end

               // cumulative distribution function
                CALC_CDF: begin

                    if(j_counter==1) begin
                        cdf[1] <= histogram[0]+ histogram[j_counter];
                        j_counter <= j_counter + 1;
                    end else if(j_counter>=NUM_BINS) begin
                        current_state <= APPLY_TRANSFORM;
                        j_counter <= 0;
                    end else begin
                        current_state <= CALC_CDF;
                        cdf[j_counter] <= cdf[j_counter-1] + histogram[j_counter];
                        j_counter <= j_counter + 1;
                    end
					
                end
                APPLY_TRANSFORM: begin
                    if(j_counter>=NUM_BINS) begin
                        current_state <= FINISH_SEND;
                        j_counter <= 0;
                        counter <= 0;
                    end else begin
                        current_state <=  APPLY_TRANSFORM;
                        transformation_table[j_counter] <= cdf[j_counter]/ 1139; 
                        //L-1 = NUM_BINS-1 = 255
                        j_counter <= j_counter + 1;
                    end
                    
                end
                FINISH_SEND: begin
                    done <= 1'b1;
                    if(counter < 19'd290400) begin
                        transformed_pixel <= transformation_table[counter];
                        counter <= counter+1;
                    end
                               
                end

            endcase
        end
    end

endmodule
