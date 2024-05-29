module Histogram (
    input wire clk,
    input wire reset,
    input wire [7:0] pixel_in,
    output wire [7:0] pixel_out
);
    parameter IMG_WIDTH = 512;
    parameter IMG_HEIGHT = 512;
    parameter NUM_PIXELS = 262144; // #512*512 = 262144
    parameter HIST_SIZE = 256;

    parameter IDLE = 0;
    parameter HISTOGRAM = 1;
    parameter CDF = 2;
    parameter EQUALIZE = 3;
    parameter OUTPUT = 4;

    // Internal signals
    reg [31:0] histogram [0:HIST_SIZE-1];
    reg [31:0] cdf [0:HIST_SIZE-1];
    reg [7:0] lut [0:HIST_SIZE-1];
    reg [31:0] pixel_count;
    reg [31:0] cdf_min;
    reg [31:0] cdf_value;
    reg [7:0] pixel_buffer;
    reg pixel_out_ready;

    integer i;

    // State machine

        typedef enum {IDLE, HISTOGRAM, CDF, EQUALIZE, OUTPUT} state_t;
        state_t state, next_state;


    // Histogram calculation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            pixel_count <= 0;
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                histogram[i] <= 0;
            end
        end else begin
            state <= state + 1;
            if (state == HISTOGRAM) begin
                histogram[pixel_in] <= histogram[pixel_in] + 1;
                pixel_count <= pixel_count + 1;
            end
        end
    end

    // CDF calculation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                cdf[i] <= 0;
            end
            cdf_min <= 0;
        end else if (state == CDF) begin
            cdf[0] <= histogram[0];
            for (i = 1; i < HIST_SIZE; i = i + 1) begin
                cdf[i] <= cdf[i-1] + histogram[i];
            end
            cdf_min <= cdf[0];
        end
    end

    // LUT calculation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                lut[i] <= 0;
            end
        end else if (state == EQUALIZE) begin
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                lut[i] <= (cdf[i] - cdf_min) * (HIST_SIZE - 1) / (NUM_PIXELS - cdf_min);
            end
        end
    end

    // Output equalized pixel
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_buffer <= 0;
            pixel_out_ready <= 0;
        end else if (state == OUTPUT) begin
            pixel_buffer <= lut[pixel_in];
            pixel_out_ready <= 1;
        end else begin
            pixel_out_ready <= 0;
        end
    end

    assign pixel_out = pixel_buffer;

    // State machine transition
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (reset) next_state = HISTOGRAM;
            HISTOGRAM: if (pixel_count == NUM_PIXELS) next_state = CDF;
            CDF: next_state = EQUALIZE;
            EQUALIZE: next_state = OUTPUT;
            OUTPUT: if (pixel_count == NUM_PIXELS) next_state = IDLE;
        endcase
    end

endmodule
