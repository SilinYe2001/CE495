import uvm_pkg::*;


class my_uvm_transaction extends uvm_sequence_item;
    //logic [23:0] image_pixel;
    logic [7:0] bytes;
    logic sof;
    logic eof;
    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(my_uvm_transaction)
        `uvm_field_int(bytes, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: my_uvm_transaction


class my_uvm_sequence extends uvm_sequence#(my_uvm_transaction);
    `uvm_object_utils(my_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        my_uvm_transaction tx;
        int in_file, n_bytes=0, i=0;
        int j;
       // logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
        int packet_size;
        logic [0:PCAP_FILE_HEADER_SIZE-1] [7:0] file_header;
        logic [0:PCAP_PACKET_HEADER_SIZE-1] [7:0] packet_header;
        logic [7:0] bt;
       // logic [23:0] pixel;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", PCAP_IN_NAME), UVM_LOW);

        in_file = $fopen(PCAP_IN_NAME, "rb");
        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", PCAP_IN_NAME));
        end

        // // read BMP header
        // n_bytes = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);
        // if ( !n_bytes ) begin
        //     `uvm_fatal("SEQ_RUN", $sformatf("Failed read header data from %s...", IMG_IN_NAME));
        // end

        //read PCAP file header
        n_bytes=$fread(file_header, in_file, 0, PCAP_FILE_HEADER_SIZE);
        $display("read file header done");
        if ( !n_bytes ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed read header data from %s...", PCAP_IN_NAME));
        end

        while ( !$feof(in_file)) begin
            packet_header = {(PCAP_PACKET_HEADER_SIZE){8'h00}};
            n_bytes += $fread(packet_header, in_file, n_bytes, PCAP_PACKET_HEADER_SIZE);
            packet_size= {<<8{packet_header[8:11]}};
            $display("Packet size: %d", packet_size);
            j=0;
            while(j<packet_size) begin
                tx = my_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
                start_item(tx);
                n_bytes+=$fread(bt,in_file,n_bytes,1);
                //$display("Read data: %d", bt);
                tx.bytes=bt;
                tx.sof=j==0? 1'b1 : 1'b0;
                tx.eof=j == packet_size-1 ? 1'b1 : 1'b0;
                finish_item(tx);
                j++;

            end
            //tx.image_pixel = pixel;
            //`uvm_info("SEQ_RUN", tx.sprint(), UVM_LOW);

            //i += BYTES_PER_PIXEL;
        end

        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", PCAP_IN_NAME), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: my_uvm_sequence

typedef uvm_sequencer#(my_uvm_transaction) my_uvm_sequencer;
