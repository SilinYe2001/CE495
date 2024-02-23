`ifndef __GLOBALS__
`define __GLOBALS__

// UVM Globals
// localparam string IMG_IN_NAME  = "image.bmp";
// localparam string IMG_OUT_NAME = "output.bmp";
// localparam string IMG_CMP_NAME = "grayscale.bmp";
// localparam int IMG_WIDTH = 720;
// localparam int IMG_HEIGHT = 540;
// localparam int BMP_HEADER_SIZE = 54;
// localparam int BYTES_PER_PIXEL = 3;
// localparam int BMP_DATA_SIZE = (IMG_WIDTH * IMG_HEIGHT * BYTES_PER_PIXEL);
localparam int CLOCK_PERIOD = 10;

//add new parameters
localparam PCAP_FILE_HEADER_SIZE = 24;
localparam PCAP_PACKET_HEADER_SIZE = 16;
localparam string PCAP_IN_NAME="test.pcap";
localparam string PCAP_OUT_NAME = "test_out.txt";
localparam string PCAP_CMP_NAME = "test.txt";

`endif
