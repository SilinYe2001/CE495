import uvm_pkg::*;


// Reads data from output fifo to scoreboard
class my_uvm_monitor_output extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_output)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_output;

    virtual my_uvm_if vif;
    int out_file_cos;
    int out_file_sin;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_output = new(.name("mon_ap_output"), .parent(this));

        out_file_cos = $fopen(COS_OUT_NAME, "wb");
        if ( !out_file_cos ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", COS_OUT_NAME));
        end
        out_file_sin = $fopen(SIN_OUT_NAME, "wb");
        if ( !out_file_sin ) begin
            `uvm_fatal("MON_OUT_BUILD", $sformatf("Failed to open output file %s...", SIN_OUT_NAME));
        end
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_bytes;
        int i=0;
       // logic [0:BMP_HEADER_SIZE-1][7:0] bmp_header;
        my_uvm_transaction tx_out;

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_out = my_uvm_transaction::type_id::create(.name("tx_out"), .contxt(get_full_name()));

        vif.out_sin_rd_en = 1'b0;
        vif.out_cos_rd_en = 1'b0;
        forever begin
            @(negedge vif.clock)
            //i++;
            begin
                if (vif.out_sin_empty == 1'b0 && vif.out_cos_empty==1'b0) begin
                    $fwrite(out_file_cos, "%h\n", vif.out_cos);  //write one byte
                    tx_out.out_cos = vif.out_cos;  // assign one byte
                    mon_ap_output.write(tx_out);
                    vif.out_cos_rd_en = 1'b1;
                    $fwrite(out_file_sin, "%h\n", vif.out_sin);  //write one byte
                    tx_out.out_sin = vif.out_sin;  // assign one byte
                    mon_ap_output.write(tx_out);
                    vif.out_sin_rd_en = 1'b1;
                end else begin
                    vif.out_cos_rd_en = 1'b0;
                    vif.out_sin_rd_en = 1'b0;
                end
            end
            //$display("i=%d",i);
            // if (i==3979) begin
            //     break;
            // end
        end
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", COS_OUT_NAME), UVM_LOW);
        `uvm_info("MON_OUT_FINAL", $sformatf("Closing file %s...", SIN_OUT_NAME), UVM_LOW);
        $fclose(out_file_cos);
        $fclose(out_file_sin);
    endfunction: final_phase

endclass: my_uvm_monitor_output


// Reads data from compare file to scoreboard
class my_uvm_monitor_compare extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_compare)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_compare;
    virtual my_uvm_if vif;
    int cmp_file_cos,cmp_file_sin, n_bytes;
    //logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_compare = new(.name("mon_ap_compare"), .parent(this));

        cmp_file_cos = $fopen(COS_CMP_NAME, "rb");
        if ( !cmp_file_cos ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", COS_CMP_NAME));
        end
        cmp_file_sin = $fopen(SIN_CMP_NAME, "rb");
        if ( !cmp_file_sin ) begin
            `uvm_fatal("MON_CMP_BUILD", $sformatf("Failed to open file %s...", SIN_CMP_NAME));
        end

        // store the BMP header as packed array
        // n_bytes = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
        // uvm_config_db#(logic[0:BMP_HEADER_SIZE-1][7:0])::set(null, "*", "bmp_header", {>> 8{bmp_header}});
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_cos=0,n_sin=0, i=0;
        int file_size=721;
       // logic [23:0] pixel;
       shortint cos,sin;
        my_uvm_transaction tx_cmp;

        // extend the run_phase 20 clock cycles
        phase.phase_done.set_drain_time(this, (CLOCK_PERIOD*20));

        // notify that run_phase has started
        phase.raise_objection(.obj(this));

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_cmp = my_uvm_transaction::type_id::create(.name("tx_cmp"), .contxt(get_full_name()));

        // syncronize file read with fifo data
        while ( (!$feof(cmp_file_cos) || !$feof(cmp_file_sin) &&(i<file_size)) ) begin
            @(negedge vif.clock)
            begin
                i++;
                if ( vif.out_sin_empty == 1'b0 && vif.out_cos_empty == 1'b0) begin
                    n_cos = $fscanf(cmp_file_cos,"%h",cos);
                    tx_cmp.out_cos = cos;
                    //mon_ap_compare.write(tx_cmp);
                    n_sin = $fscanf(cmp_file_sin,"%h",sin);
                    tx_cmp.out_sin = sin;
                    mon_ap_compare.write(tx_cmp);
                end
            end
        end      

        // notify that run_phase has completed
        phase.drop_objection(.obj(this));
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", COS_CMP_NAME), UVM_LOW);
        $fclose(cmp_file_cos);
        `uvm_info("MON_CMP_FINAL", $sformatf("Closing file %s...", SIN_CMP_NAME), UVM_LOW);
        $fclose(cmp_file_sin);
    endfunction: final_phase

endclass: my_uvm_monitor_compare


// Reads data from compare file to scoreboard
class my_uvm_monitor_precise extends uvm_monitor;
    `uvm_component_utils(my_uvm_monitor_precise)

    uvm_analysis_port#(my_uvm_transaction) mon_ap_precise;
    virtual my_uvm_if vif;
    int rad_in_file, n_bytes;
    //logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_resource_db#(virtual my_uvm_if)::read_by_name
            (.scope("ifs"), .name("vif"), .val(vif)));
        mon_ap_precise = new(.name("mon_ap_precise"), .parent(this));

        rad_in_file = $fopen(RAD_IN_NAME, "rb");
        if ( !rad_in_file ) begin
            `uvm_fatal("MON_PRE_BUILD", $sformatf("Failed to open file %s...", RAD_IN_NAME));
        end

    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        int n_rads=0, i=0;
        int file_size=721;
       // logic [23:0] pixel;
       int rads;
       real float_rads;
        my_uvm_transaction tx_pre;

        // extend the run_phase 20 clock cycles
        phase.phase_done.set_drain_time(this, (CLOCK_PERIOD*20));

        // notify that run_phase has started
        phase.raise_objection(.obj(this));

        // wait for reset
        @(posedge vif.reset)
        @(negedge vif.reset)

        tx_pre = my_uvm_transaction::type_id::create(.name("tx_pre"), .contxt(get_full_name()));

        // syncronize file read with fifo data
        while ( (!$feof(rad_in_file) &&(i<file_size)) ) begin
            @(negedge vif.clock)
            begin
                i++;
                if ( vif.out_sin_empty == 1'b0 && vif.out_cos_empty == 1'b0) begin
                    n_rads = $fscanf(rad_in_file,"%h",rads);
                    tx_pre.in_rad = rads;
                    float_rads=real'(real'(rads)/real'(1<<14));
                    tx_pre.float_cos=$cos(float_rads); //calculate cos and sin
                    tx_pre.float_sin=$sin(float_rads);
                    mon_ap_precise.write(tx_pre);
                end
            end
        end      

        // notify that run_phase has completed
        phase.drop_objection(.obj(this));
    endtask: run_phase

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        `uvm_info("MON_PRE_FINAL", $sformatf("Closing file %s...", RAD_IN_NAME), UVM_LOW);
        $fclose(rad_in_file);
    endfunction: final_phase

endclass: my_uvm_monitor_precise
