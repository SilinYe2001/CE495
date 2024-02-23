//import global_params::*;
`timescale 1 ns / 1 ns
module udp_tb;
localparam PCAP_FILE_HEADER_SIZE = 24;
localparam PCAP_PACKET_HEADER_SIZE = 16;
localparam CLOCK_PERIOD = 10;
localparam string PCAP_IN_NAME="test.pcap";
localparam string PCAP_OUT_NAME = "test_out.txt";
localparam string PCAP_CMP_NAME = "test.txt";
logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;

logic        in_full;
logic        in_wr_en  = '0;
logic [7:0] in_din    = '0;
logic       in_wr_sof ;
logic       in_wr_eof ;

logic        out_rd_en;
logic        out_empty;
logic  [7:0] out_dout;

//logic   hold_clock    = '0;
logic   in_write_done = '0;
logic   out_read_done = '0;
integer out_errors    = '0;


udp_top udp_top(
    .clk(clock),
    .reset(reset),
    //sof eof
    .in_wr_eof(in_wr_eof),
    .in_wr_sof(in_wr_sof),
    //input fifo
    .in_wr_en(in_wr_en),
    .in_din(in_din),
    .in_full(in_full),
    //output fifo
    .out_rd_en(out_rd_en),
    .out_dout(out_dout),
    .out_empty(out_empty)
    
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
initial begin : pcap_read_process
    int i, j;
    int packet_size;
    int in_file;
    logic [0:PCAP_FILE_HEADER_SIZE-1] [7:0] file_header;
    logic [0:PCAP_PACKET_HEADER_SIZE-1] [7:0] packet_header;
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, PCAP_IN_NAME);
    in_file = $fopen(PCAP_IN_NAME, "rb");
    in_wr_en = 1'b0;
    in_wr_sof = 1'b0;
    in_wr_eof = 1'b0;
    // Skip PCAP Global header
    i = $fread(file_header, in_file, 0, PCAP_FILE_HEADER_SIZE);
    // Read data from image file
    while ( !$feof(in_file) ) begin
        // read pcap packet header & get packet length
        packet_header = {(PCAP_PACKET_HEADER_SIZE){8'h00}};
        i += $fread(packet_header, in_file, i, PCAP_PACKET_HEADER_SIZE);
        packet_size = {<<8{packet_header[8:11]}};
        $display("Packet size: %d", packet_size);
        // iterate through packet length
        j = 0;
        while ( j < packet_size ) begin
            @(negedge clock);
            if (in_full == 1'b0) begin
                i += $fread(in_din, in_file, i, 1);
                in_wr_en = 1'b1;
                in_wr_sof = j == 0 ? 1'b1 : 1'b0;
                in_wr_eof = j == packet_size-1 ? 1'b1 : 1'b0;
                j++;
            end else begin
                in_wr_en = 1'b0;
                in_wr_sof = 1'b0;
                in_wr_eof = 1'b0;
            end
        end
    end
    @(negedge clock);
    in_wr_en = 1'b0;
    in_wr_sof = 1'b0;
    in_wr_eof = 1'b0;
    $fclose(in_file);
    in_write_done = 1'b1;
    $display("PCAP read done");
end


initial begin : pcap_write_and_compare_process
    int out_file, cmp_file, r;
    int i;
    logic [7:0] cmp_dout;
    logic [7:0] out_byte;

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Writing output to file %s and comparing with %s...", $time, PCAP_OUT_NAME, PCAP_CMP_NAME);
    
    out_file = $fopen(PCAP_OUT_NAME, "wb"); // Open output file for writing in binary mode
    cmp_file = $fopen(PCAP_CMP_NAME, "rb"); // Open comparison file for reading in binary mode
    out_rd_en = 1'b0;
    i=0;
    // Assuming the comparison process directly compares output data stream with the content of PCAP_CMP_NAME
    while (!$feof(cmp_file)) begin
        @(negedge clock);
        if (!out_empty) begin
            out_rd_en = 1'b1; // Enable reading from output FIFO
            out_byte = out_dout; // Read byte from output FIFO
            $fwrite(out_file, "%c", out_byte); // Write byte to output file
            
            r = $fread(cmp_dout, cmp_file); // Read a byte from comparison file
            if (cmp_dout !== out_byte) begin
                out_errors += 1; // Increment error count if there's a mismatch
                $display("@ %0t: Mismatch found at position %0d: Output %h != Expected %h", $time, $ftell(cmp_file), out_byte, cmp_dout);
            end
            i=i+1;
            //$display("i = %0d ", i);
        end else begin
            out_rd_en = 1'b0; // Disable reading if output FIFO is empty
            //out_byte='0;
        end
        // if (i==3979) begin
        //     break;
        // end
    end

    @(negedge clock);
    out_rd_en = 1'b0; // Ensure read enable is turned off after operation
    $fclose(out_file); // Close output file
    $fclose(cmp_file); // Close comparison file
    out_read_done = 1'b1; // Indicate read and comparison process is done

    $display("Comparison completed with %0d errors.", out_errors);
end


endmodule