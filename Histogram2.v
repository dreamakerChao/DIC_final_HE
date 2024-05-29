module histogram_equalization (
    input wire clk,
    input wire reset,
    input wire [7:0] pixel_in,
    input wire pixel_valid,
    output wire [7:0] pixel_out,
    output wire pixel_out_valid
);
    parameter IMG_WIDTH = 512;
    parameter IMG_HEIGHT = 512;
    parameter NUM_PIXELS = 262144; #512*512 = 262144
    parameter HIST_SIZE = 256;

    // Internal signals
    reg [31:0] pixel_count;
    reg [31:0] cdf_min;
    reg [7:0] pixel_buffer;
    reg pixel_out_ready;

    wire [31:0] histogram [0:HIST_SIZE-1];
    wire [31:0] cdf [0:HIST_SIZE-1];
    wire [7:0] lut [0:HIST_SIZE-1];
    wire histogram_done;
    wire cdf_done;
    wire lut_done;

    integer i;

    // State machine
    typedef enum {IDLE, HISTOGRAM, CDF, EQUALIZE, OUTPUT} state_t;
    state_t state, next_state;

    // Histogram calculation submodule
    histogram_calc #(HIST_SIZE, NUM_PIXELS) hist_calc (
        .clk(clk),
        .reset(reset),
        .pixel_in(pixel_in),
        .pixel_valid(pixel_valid),
        .histogram(histogram),
        .done(histogram_done)
    );

    // CDF calculation submodule
    cdf_calc #(HIST_SIZE) cdf_calc_inst (
        .clk(clk),
        .reset(reset),
        .histogram(histogram),
        .cdf(cdf),
        .cdf_min(cdf_min),
        .done(cdf_done)
    );

    // LUT calculation submodule
    lut_calc #(HIST_SIZE, NUM_PIXELS) lut_calc_inst (
        .clk(clk),
        .reset(reset),
        .cdf(cdf),
        .cdf_min(cdf_min),
        .lut(lut),
        .done(lut_done)
    );

    // Output equalized pixel
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_buffer <= 0;
            pixel_out_ready <= 0;
        end else if (state == OUTPUT && pixel_valid) begin
            pixel_buffer <= lut[pixel_in];
            pixel_out_ready <= 1;
        end else begin
            pixel_out_ready <= 0;
        end
    end

    assign pixel_out = pixel_buffer;
    assign pixel_out_valid = pixel_out_ready;

    // State machine transition
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (reset) next_state = HISTOGRAM;
            HISTOGRAM: if (histogram_done) next_state = CDF;
            CDF: if (cdf_done) next_state = EQUALIZE;
            EQUALIZE: if (lut_done) next_state = OUTPUT;
            OUTPUT: if (pixel_count == NUM_PIXELS) next_state = IDLE;
        endcase
    end

endmodule

module histogram_calc #(parameter HIST_SIZE = 256, parameter NUM_PIXELS = 262144) (
    input wire clk,
    input wire reset,
    input wire [7:0] pixel_in,
    input wire pixel_valid,
    output reg [31:0] histogram [0:HIST_SIZE-1],
    output reg done
);
    reg [31:0] pixel_count;

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_count <= 0;
            done <= 0;
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                histogram[i] <= 0;
            end
        end else if (pixel_valid) begin
            histogram[pixel_in] <= histogram[pixel_in] + 1;
            pixel_count <= pixel_count + 1;
            if (pixel_count == NUM_PIXELS - 1) begin
                done <= 1;
            end
        end
    end
endmodule

module cdf_calc #(parameter HIST_SIZE = 256) (
    input wire clk,
    input wire reset,
    input wire [31:0] histogram [0:HIST_SIZE-1],
    output reg [31:0] cdf [0:HIST_SIZE-1],
    output reg [31:0] cdf_min,
    output reg done
);
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                cdf[i] <= 0;
            end
            cdf_min <= 0;
        end else begin
            cdf[0] <= histogram[0];
            for (i = 1; i < HIST_SIZE; i = i + 1) begin
                cdf[i] <= cdf[i-1] + histogram[i];
            end
            cdf_min <= cdf[0];
            done <= 1;
        end
    end
endmodule

module lut_calc #(parameter HIST_SIZE = 256, parameter NUM_PIXELS = 262144) (
    input wire clk,
    input wire reset,
    input wire [31:0] cdf [0:HIST_SIZE-1],
    input wire [31:0] cdf_min,
    output reg [7:0] lut [0:HIST_SIZE-1],
    output reg done
);
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                lut[i] <= 0;
            end
        end else begin
            for (i = 0; i < HIST_SIZE; i = i + 1) begin
                lut[i] <= (cdf[i] - cdf_min) * (HIST_SIZE - 1) / (NUM_PIXELS - cdf_min);
            end
            done <= 1;
        end
    end
endmodule
