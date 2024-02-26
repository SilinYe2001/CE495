import uvm_pkg::*;


class my_uvm_transaction extends uvm_sequence_item;
    //logic [23:0] image_pixel;
    int in_rad;
    shortint out_cos;
    shortint out_sin;
    real float_cos;
    real float_sin;
    // logic sof;
    // logic eof;
    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(my_uvm_transaction)
        `uvm_field_int(in_rad, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: my_uvm_transaction


class my_uvm_sequence extends uvm_sequence#(my_uvm_transaction);
    `uvm_object_utils(my_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        my_uvm_transaction tx;
        int in_file, n_rads=0, i=0;
        int j;
        int rads;
        int file_size=721;
       // logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];
       // logic [23:0] pixel;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", RAD_IN_NAME), UVM_LOW);

        in_file = $fopen(RAD_IN_NAME, "r");
        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", RAD_IN_NAME));
        end
        while ( !$feof(in_file) && (i<file_size)) begin
            i++;
            tx = my_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
            start_item(tx);
            n_rads = $fscanf(in_file,"%h",rads);
            tx.in_rad = rads;
            //`uvm_info("SEQ_RUN", tx.sprint(), UVM_LOW);
            finish_item(tx);
        end
        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", RAD_IN_NAME), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: my_uvm_sequence

typedef uvm_sequencer#(my_uvm_transaction) my_uvm_sequencer;
