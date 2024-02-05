
`timescale 1 ns / 1 ns

module Wrapper_tb;

localparam string IMG1_IN_NAME  = "base.bmp";
localparam string IMG2_IN_NAME  = "pedestrians.bmp";
localparam string IMG_OUT_NAME = "detect.bmp";
localparam string IMG_CMP_NAME = "target.bmp";

localparam WIDTH = 768;
localparam HEIGHT = 576;
localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 3;
localparam BMP_DATA_SIZE = WIDTH*HEIGHT*BYTES_PER_PIXEL;
localparam FIFO_BUFFER_SIZE = 32;
localparam COLOR_DATA_WIDTH = 24;
localparam GRAY_DATA_WIDTH = 8;


localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;


//write initial 2 pictures
logic full_pic1, full_pic2;
logic wr_en_pic1, wr_en_pic2;
logic [COLOR_DATA_WIDTH-1:0] din_pic1, din_pic2;
//write color to output
logic full_color;
logic wr_en_color;
logic [COLOR_DATA_WIDTH-1:0] din_in_color;
// load output data
logic rd_en_final;
logic empty_final;
logic [COLOR_DATA_WIDTH-1:0] dout_out_final;

logic   hold_clock    = '0;
logic   in1_write_done = '0;
logic   in2_write_done = '0;
logic highlight_write_done='0;
logic   out_read_done = '0;
integer out_errors    = '0;



motion_detect_top_wrapper #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .COLOR_DATA_WIDTH(COLOR_DATA_WIDTH),
    .GRAY_DATA_WIDTH(GRAY_DATA_WIDTH)
) uut (
    .clock(clock),
    .reset(reset),
    .wr_en_pic1(wr_en_pic1),
    .wr_en_pic2(wr_en_pic2),
    .din_pic1(din_pic1),
    .din_pic2(din_pic2),
    .full_pic1(full_pic1),
    .full_pic2(full_pic2),
    .wr_en_color(wr_en_color),
    .full_color(full_color),
    .din_in_color(din_in_color),
    .rd_en_final(rd_en_final),
    .empty_final(empty_final),
    .dout_out_final(dout_out_final)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);

    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    // end the simulation
    $finish;
end
//read img1
initial begin : img1_read_process
    int i, r;
    int in_file;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IMG1_IN_NAME);

    in_file = $fopen(IMG1_IN_NAME, "rb");
    wr_en_pic1 = 1'b0;

    // Skip BMP header
    r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

    // Read data from image file
    i = 0;
    while ( i < BMP_DATA_SIZE ) begin
        @(negedge clock);
        wr_en_pic1 = 1'b0;
        if (full_pic1 == 1'b0) begin
            r = $fread(din_pic1, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            wr_en_pic1 = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    wr_en_pic1 = 1'b0;
    $fclose(in_file);
    in1_write_done = 1'b1;
    $display("@ %0t: reading file %s done", $time, IMG1_IN_NAME);
end
//read img2
initial begin : img2_read_process
    int i, r;
    int in_file;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IMG2_IN_NAME);

    in_file = $fopen(IMG2_IN_NAME, "rb");
    wr_en_pic2 = 1'b0;

    // Skip BMP header
    r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

    // Read data from image file
    i = 0;
    while ( i < BMP_DATA_SIZE ) begin
        @(negedge clock);
        wr_en_pic2 = 1'b0;
        if (full_pic2 == 1'b0) begin
            r = $fread(din_pic2, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            wr_en_pic2 = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    wr_en_pic2 = 1'b0;
    $fclose(in_file);
    in2_write_done = 1'b1;
    $display("@ %0t: reading file %s done", $time, IMG2_IN_NAME);
end
initial begin : highlight_read_process
    int i, r;
    int in_file;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, IMG2_IN_NAME);

    in_file = $fopen(IMG2_IN_NAME, "rb");
    wr_en_color = 1'b0;

    // Skip BMP header
    r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

    // Read data from image file
    i = 0;
    while ( i < BMP_DATA_SIZE ) begin
        @(negedge clock);
        wr_en_color = 1'b0;
        if (full_color == 1'b0) begin
            r = $fread(din_in_color, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            wr_en_color = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    wr_en_color = 1'b0;
    $fclose(in_file);
    highlight_write_done = 1'b1;
    $display("@ %0t: reading file %s to highlight done", $time, IMG2_IN_NAME);
end
initial begin : img_write_process
    int i, r;
    int out_file;
    int cmp_file;
    logic [23:0] cmp_dout;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME);
    
    out_file = $fopen(IMG_OUT_NAME, "wb");
    cmp_file = $fopen(IMG_CMP_NAME, "rb");
    rd_en_final = 1'b0;
    
    // Copy the BMP header
    r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
    for (i = 0; i < BMP_HEADER_SIZE; i++) begin
        $fwrite(out_file, "%c", bmp_header[i]);
    end

    i = 0;
    while (i < BMP_DATA_SIZE) begin
        @(negedge clock);
        rd_en_final = 1'b0;
        if (empty_final == 1'b0) begin
            r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            $fwrite(out_file, "%c%c%c",dout_out_final[23:16],dout_out_final[15:8],dout_out_final[7:0]);

            if (cmp_dout!= dout_out_final) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, IMG_OUT_NAME, i+1, dout_out_final, cmp_dout, i);
            end
            rd_en_final = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    rd_en_final = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule
