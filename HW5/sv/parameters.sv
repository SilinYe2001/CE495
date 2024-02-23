package global_params;
    // Define parameters here
    localparam PCAP_FILE_HEADER_SIZE = 24;
    localparam PCAP_PACKET_HEADER_SIZE = 16;
    localparam ETH_DST_ADDR_BYTES = 6;
    localparam ETH_SRC_ADDR_BYTES = 6;
    localparam ETH_PROTOCOL_BYTES = 2;
    localparam IP_VERSION_BYTES = 1;
    localparam IP_HEADER_BYTES = 1;
    localparam IP_TYPE_BYTES = 1;
    localparam IP_LENGTH_BYTES = 2; //
    localparam IP_ID_BYTES = 2;
    localparam IP_FLAG_BYTES = 2;
    localparam IP_TIME_BYTES = 1;
    localparam IP_PROTOCOL_BYTES = 1;  //
    localparam IP_CHECKSUM_BYTES = 2;
    localparam IP_SRC_ADDR_BYTES = 4;  //
    localparam IP_DST_ADDR_BYTES = 4;  //
    localparam UDP_DST_PORT_BYTES = 2; //
    localparam UDP_SRC_PORT_BYTES = 2;//
    localparam UDP_LENGTH_BYTES = 2;//
    localparam UDP_CHECKSUM_BYTES = 2;  //
    localparam IP_PROTOCOL_DEF = 16'h0800;
    localparam IP_VERSION_DEF = 4'h4;
    localparam IP_HEADER_LENGTH_DEF = 4'h5;
    localparam IP_TYPE_DEF = 4'h0;
    localparam IP_FLAGS_DEF = 4'h4;
    localparam TIME_TO_LIVE = 4'he;
    localparam UDP_PROTOCOL_DEF = 8'h11;
endpackage : global_params
