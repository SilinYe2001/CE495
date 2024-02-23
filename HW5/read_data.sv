
module read_data (
    input logic rd_clk,
    input logic reset,
    input logic in_rd_sof,
    input logic in_rd_eof,
    input logic [7:0]in_dout,
    input logic in_empty,
    output logic in_rd_en,
    input logic out_full,
    output logic out_wr_en,
    output logic [7:0]out_din
);
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
    // localparam IP_PROTOCOL_DEF = 16'h0800;
    // localparam IP_VERSION_DEF = 4'h4;
    // localparam IP_HEADER_LENGTH_DEF = 4'h5;
    // localparam IP_TYPE_DEF = 4'h0;
    // localparam IP_FLAGS_DEF = 4'h4;
    // localparam TIME_TO_LIVE = 4'he;
    // localparam UDP_PROTOCOL_DEF = 8'h11;
typedef enum logic [3:0] {
    WAIT_FOR_SOF,   //sof
    COUNT,
    IP_LENGTH,
    COUNT1,
    IP_PROTOCOL,
    COUNT2,
    IP_SRC_ADDR,
    IP_DST_ADDR,
    UDP_DST_PORT,
    UDP_SRC_PORT,
    UDP_LENGTH,
    UDP_CHECKSUM,
    UDP_DATA,  //eof
    PADSUM,
    CHECK_DATA,
    DATAOUT
    } state_types;
state_types state, next_state;
//read counter
shortint num_bytes,num_bytes_c; 
//buffers
logic [8*IP_LENGTH_BYTES-1:0]ip_length,ip_length_c;
logic [8*IP_PROTOCOL_BYTES-1:0]ip_protocol,ip_protocol_c;
logic [8*IP_SRC_ADDR_BYTES-1:0]ip_src_addr,ip_src_addr_c;
logic [8*IP_DST_ADDR_BYTES-1:0]ip_dst_addr,ip_dst_addr_c;
logic [8*UDP_DST_PORT_BYTES-1:0]udp_dst_port,udp_dst_port_c;
logic [8*UDP_SRC_PORT_BYTES-1:0]udp_src_port,udp_src_port_c;
shortint udp_length,udp_length_c;
logic [8*UDP_CHECKSUM_BYTES-1:0]udp_checksum,udp_checksum_c;
logic [1024*8:0] udp_data,udp_data_c;
//data length buffer
shortint data_length,data_length_c;
//output counter
shortint out_count,out_count_c;
//checksum buffer
shortint sum = 0;
//frame count
logic [1:0] frame_num,frame_num_c;
always_ff @( posedge rd_clk or posedge reset ) begin 
    if (reset) begin
        state=WAIT_FOR_SOF;
        num_bytes='0;
        ip_length='0;
        ip_protocol='0;
        ip_src_addr='0;
        ip_dst_addr='0;
        udp_dst_port='0;
        udp_src_port='0;
        udp_length='0;
        udp_checksum='0;
        udp_data='0;
        data_length='0;
        out_count='0;
        frame_num='0;
    end
    else begin
        state=next_state;
        num_bytes=num_bytes_c;
        ip_length=ip_length_c;
        ip_protocol=ip_protocol_c;
        ip_src_addr=ip_src_addr_c;
        ip_dst_addr=ip_dst_addr_c;
        udp_dst_port=udp_dst_port_c;
        udp_src_port=udp_src_port_c;
        udp_length=udp_length_c;
        udp_checksum=udp_checksum_c;
        udp_data=udp_data_c;
        data_length=data_length_c;
        out_count=out_count_c;
        frame_num=frame_num_c;
    end
end
always_comb begin
    //default value:
    next_state=state;
    num_bytes_c=num_bytes;
    ip_length_c=ip_length;
    ip_protocol_c=ip_protocol;
    ip_src_addr_c=ip_src_addr;
    ip_dst_addr_c=ip_dst_addr;
    udp_dst_port_c=udp_dst_port;
    udp_src_port_c=udp_src_port;
    udp_length_c=udp_length;
    udp_checksum_c=udp_checksum;
    udp_data_c=udp_data;
    data_length_c=data_length;
    out_count_c=out_count;
    frame_num_c=frame_num;
    out_wr_en=1'b0;
    in_rd_en=1'b0;
    out_din='0;
  case (state) 
    WAIT_FOR_SOF: begin
        if ( (in_rd_sof == 1'b1) && (in_empty == 1'b0) ) begin
        next_state = COUNT;
        //in_rd_en = 1'b1;
        end 
        else if ( in_empty == 1'b0 ) begin
        in_rd_en = 1'b1;
        end
    end
    COUNT:begin
        if ( in_empty == 1'b0 ) begin
            in_rd_en = 1'b1;
            num_bytes_c = num_bytes + 1;
            if (num_bytes==ETH_DST_ADDR_BYTES+ETH_SRC_ADDR_BYTES+ETH_PROTOCOL_BYTES+IP_VERSION_BYTES+IP_HEADER_BYTES+IP_TYPE_BYTES-2) begin
                next_state=IP_LENGTH;
                num_bytes_c='0;
            end
        end
    end
    IP_LENGTH: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            ip_length_c= ($unsigned(ip_length) << 8) | (IP_LENGTH_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ( num_bytes == IP_LENGTH_BYTES-1 ) begin
                sum+=($unsigned(ip_length) << 8) | (IP_LENGTH_BYTES*8)'($unsigned(in_dout))-20;     //checksum
                num_bytes_c='0;
                next_state = COUNT1;
            end
        end
    end 
    COUNT1: begin
        if ( in_empty == 1'b0 ) begin
            in_rd_en = 1'b1;
            num_bytes_c = (num_bytes + 1);
            if (num_bytes==IP_ID_BYTES+IP_FLAG_BYTES+IP_TIME_BYTES-1) begin
                next_state=IP_PROTOCOL;
                num_bytes_c='0;
            end
        end
    end 
    IP_PROTOCOL: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            ip_protocol_c= (IP_PROTOCOL_BYTES*8)'($unsigned(in_dout));
            //num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            sum+=(IP_PROTOCOL_BYTES*8)'($unsigned(in_dout)); //checksum
            num_bytes_c='0;
            next_state = COUNT2;
        end 
    end 
    COUNT2: begin
        if ( in_empty == 1'b0 ) begin
            in_rd_en = 1'b1;
            num_bytes_c = (num_bytes + 1);
            if (num_bytes==IP_CHECKSUM_BYTES-1) begin
                next_state=IP_SRC_ADDR;
                num_bytes_c='0;
            end
        end
    end 
    IP_SRC_ADDR: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            ip_src_addr_c= ($unsigned(ip_src_addr) << 8) | (IP_SRC_ADDR_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ((num_bytes + 1)%2==0) begin
                sum+=($unsigned(ip_src_addr) << 8) | (IP_SRC_ADDR_BYTES*8)'($unsigned(in_dout)); //checksum
            end
            if ( num_bytes == IP_SRC_ADDR_BYTES-1 ) begin
                num_bytes_c='0;
                next_state = IP_DST_ADDR;
            end
        end 
    end
    IP_DST_ADDR: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            ip_dst_addr_c= ($unsigned(ip_dst_addr) << 8) | (IP_DST_ADDR_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ((num_bytes + 1)%2==0) begin
                sum+=($unsigned(ip_dst_addr) << 8) | (IP_DST_ADDR_BYTES*8)'($unsigned(in_dout)); //checksum
            end
            if ( num_bytes == IP_DST_ADDR_BYTES-1 ) begin
                num_bytes_c='0;
                next_state = UDP_DST_PORT;
            end
        end 
    end
    UDP_DST_PORT: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            udp_dst_port_c= ($unsigned(udp_dst_port) << 8) | (UDP_DST_PORT_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ( num_bytes == UDP_DST_PORT_BYTES-1 ) begin
                sum+=($unsigned(udp_dst_port) << 8) | (UDP_DST_PORT_BYTES*8)'($unsigned(in_dout));     //checksum
                num_bytes_c='0;
                next_state = UDP_SRC_PORT;
            end
        end
    end
    UDP_SRC_PORT: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            udp_src_port_c= ($unsigned(udp_src_port) << 8) | (UDP_SRC_PORT_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ( num_bytes == UDP_SRC_PORT_BYTES-1 ) begin
                sum+=($unsigned(udp_src_port) << 8) | (UDP_SRC_PORT_BYTES*8)'($unsigned(in_dout));     //checksum
                num_bytes_c='0;
                next_state = UDP_LENGTH;
            end
        end
    end
    UDP_LENGTH:begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            udp_length_c= ($unsigned(udp_length) << 8) | (UDP_LENGTH_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ( num_bytes == UDP_LENGTH_BYTES-1 ) begin
                sum+=($unsigned(udp_src_port) << 8) | (UDP_LENGTH_BYTES*8)'($unsigned(in_dout));     //checksum
                num_bytes_c='0;
                next_state = UDP_CHECKSUM;
            end
        end
    end
    UDP_CHECKSUM: begin
        if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            udp_checksum_c= ($unsigned(udp_checksum) << 8) | (UDP_CHECKSUM_BYTES*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ( num_bytes == UDP_CHECKSUM_BYTES-1 ) begin
                sum+=($unsigned(udp_src_port) << 8) | (UDP_CHECKSUM_BYTES*8)'($unsigned(in_dout));     //checksum
                data_length_c=udp_length - (UDP_CHECKSUM_BYTES + UDP_LENGTH_BYTES + UDP_DST_PORT_BYTES + UDP_SRC_PORT_BYTES);
                num_bytes_c='0;
                next_state = UDP_DATA;
            end
        end 
    end
    UDP_DATA: begin
            if ( in_empty == 1'b0 ) begin
            // concatenate new input to bottom 8-bits of previous value
            udp_data_c= ($unsigned(udp_data) << 8) | (1024*8)'($unsigned(in_dout));
            num_bytes_c = num_bytes + 1;
            in_rd_en = 1'b1;
            if ((num_bytes + 1)%2==0) begin
                sum+=($unsigned(udp_data) << 8) | (1024*8)'($unsigned(in_dout));
            end
            if ( (in_rd_eof==1'b1)) begin  //finish the whole frame,should be satisfy 2 conditions at the same time
                out_count_c=num_bytes+1;
                num_bytes_c='0;
                //padding
                if(data_length&1) begin
                    sum+=($unsigned(udp_data) << 8) | (1024*8)'(0);
                end 
                sum=~sum;
                next_state = DATAOUT;
            end
        end
    end 
    // PADSUM: begin
    //     if(data_length&1) begin
    //         //padding 0 byte at the end
    //         sum+=($unsigned(udp_data) << 8) | ((data_length+1)*8)'(0);
    //     end 
    //     next_state=CHECK_DATA;
    // end
    // CHECK_DATA: begin
    //     if (udp_checksum != sum) begin
    //         udp_data_c='0;   //wrong, clean the data
    //         //clean other buffer? 
    //         next_state=CHECK_DATA;
    //     end
    //     else begin
    //         next_state=DATAOUT;

    //     end
    // end
    DATAOUT: begin
        if (out_full==1'b0) begin
            if(out_count=='0) begin  //output finish, go to next frame
                next_state=WAIT_FOR_SOF;
                frame_num_c=frame_num+1;
                //clear the buffer
                sum=0;
                num_bytes_c='0;
                ip_length_c='0;
                ip_src_addr_c='0;
                ip_dst_addr_c='0;
                udp_dst_port_c='0;
                udp_src_port_c='0;
                udp_length_c='0;
                udp_checksum_c='0;
                udp_data_c='0;
                data_length_c='0;
                out_count_c='0;
                //frame_num_c=frame_num;
            end
            else begin
                out_wr_en=1'b1;
                out_din=udp_data[(out_count-1)*8+:8];
                out_count_c=out_count-1;
            end
        end
    end
       default: begin
            next_state=state;
            num_bytes_c=num_bytes;
            ip_length_c=ip_length;
            ip_src_addr_c=ip_src_addr;
            ip_dst_addr_c=ip_dst_addr;
            udp_dst_port_c=udp_dst_port;
            udp_src_port_c=udp_src_port;
            udp_length_c=udp_length;
            udp_checksum_c=udp_checksum;
           // udp_data_c=udp_data;
            data_length_c=data_length;
            out_count_c=out_count;
            frame_num_c=frame_num;
            out_wr_en=1'b0;
            in_rd_en=1'b0;
       end
  endcase
end
endmodule