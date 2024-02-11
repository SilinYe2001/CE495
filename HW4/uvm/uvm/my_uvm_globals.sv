`ifndef __GLOBALS__
`define __GLOBALS__

// UVM Globals
localparam string IMG_IN_NAME  = "tracks_720_720.bmp";
localparam string IMG_OUT_NAME = "stage1.bmp";
localparam string IMG_CMP_NAME = "stage2_sobel.bmp";
localparam int IMG_WIDTH = 720;
localparam int IMG_HEIGHT = 720;
localparam int BMP_HEADER_SIZE = 54;
localparam int BYTES_PER_PIXEL = 3;
localparam int BMP_DATA_SIZE = (IMG_WIDTH * IMG_HEIGHT * BYTES_PER_PIXEL);
localparam int CLOCK_PERIOD = 18.891;

`endif
