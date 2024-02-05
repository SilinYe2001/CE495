module motion_detect_top_wrapper #(
    parameter FIFO_BUFFER_SIZE = 32,
    parameter COLOR_DATA_WIDTH = 24,
    parameter GRAY_DATA_WIDTH = 8
)(
    input logic clock,
    input logic reset,
    // load 2 color images
    input logic wr_en_pic1,wr_en_pic2,
    input logic [COLOR_DATA_WIDTH-1:0]din_pic1,din_pic2,
    output logic full_pic1,full_pic2,
    // load color image to highlight
    input logic wr_en_color,
    output logic full_color,
    input logic [COLOR_DATA_WIDTH-1:0] din_in_color,
    // read final output
    input logic rd_en_final,
    output logic empty_final,
    output logic [COLOR_DATA_WIDTH-1:0] dout_out_final
    
);
//read the 2 grascale outputs
logic rd_en_pic1,rd_en_pic2;
logic empty_pic1,empty_pic2;
logic [GRAY_DATA_WIDTH-1:0] dout_pic1,dout_pic2;
// read the subtraction of grayscale
logic rd_en_sub;
logic [GRAY_DATA_WIDTH-1:0] dout_sub;
logic empty_sub;

highlight_top #(
    .COLOR_DATA_WIDTH(COLOR_DATA_WIDTH),
    .SUB_DATA_WIDTH(GRAY_DATA_WIDTH),
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
) highlight_top_instance (
    .clock(clock),
    .reset(reset),
    //write to color image input fifo
    .wr_en_hi(wr_en_color),
    .full_hi(full_color),
    .din_in_hi(din_in_color),
    // read from subtraction out fifo in vectorsub_top
    .empty_sub(empty_sub),
    .rd_en_sub(rd_en_sub),
    .din_sub(dout_sub),
    .rd_en_final(rd_en_final),
    .empty_final(empty_final),
    .dout_out_final(dout_out_final)
);
// graysclae 2 images
grayscale_top #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),   // Set the width
    .IN_DATA_WIDTH(COLOR_DATA_WIDTH),   // Set the height
    .OUT_DATA_WIDTH(GRAY_DATA_WIDTH)
) grayscale_pic1 (
    .clock(clock),         // Connect to system clock
    .reset(reset),         // Connect to reset signal
    .in_full(full_pic1),     // Output: indicates if the input buffer is full
    .in_wr_en(wr_en_pic1),   // Input: write enable for input data
    .in_din(din_pic1),       // Input: 24-bit input data (RGB color)
    .out_empty(empty_pic1), // Output: indicates if the output buffer is empty
    .out_rd_en(rd_en_pic1), // Input: read enable for output data
    .out_dout(dout_pic1)    // Output: 8-bit output data (grayscale value)
);
grayscale_top #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),   // Set the width
    .IN_DATA_WIDTH(COLOR_DATA_WIDTH),   // Set the height
    .OUT_DATA_WIDTH(GRAY_DATA_WIDTH)
) grayscale_pic2 (
    .clock(clock),         // Connect to system clock
    .reset(reset),         // Connect to reset signal
    .in_full(full_pic2),     // Output: indicates if the input buffer is full
    .in_wr_en(wr_en_pic2),   // Input: write enable for input data
    .in_din(din_pic2),       // Input: 24-bit input data (RGB color)
    .out_empty(empty_pic2), // Output: indicates if the output buffer is empty
    .out_rd_en(rd_en_pic2), // Input: read enable for output data
    .out_dout(dout_pic2)    // Output: 8-bit output data (grayscale value)
);

vectorsub_top #(
    .DATA_WIDTH(GRAY_DATA_WIDTH),
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
) vectorsub_top_instance (
    .clock(clock),
    .reset(reset),
    .x_rd_en(rd_en_pic1),
    .x_empty(empty_pic1),
    .x_din(dout_pic1),
    .y_rd_en(rd_en_pic2),
    .y_empty(empty_pic2),
    .y_din(dout_pic2),
    .z_rd_en(rd_en_sub),
    .z_empty(empty_sub),
    .z_dout(dout_sub)
);



endmodule