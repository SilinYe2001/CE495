import uvm_pkg::*;

`uvm_analysis_imp_decl(_output)
`uvm_analysis_imp_decl(_compare)

class my_uvm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_uvm_scoreboard)

    uvm_analysis_export #(my_uvm_transaction) sb_export_output;
    uvm_analysis_export #(my_uvm_transaction) sb_export_compare;
    uvm_analysis_export #(my_uvm_transaction) sb_export_precise;

    uvm_tlm_analysis_fifo #(my_uvm_transaction) output_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) compare_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) precise_fifo;

    my_uvm_transaction tx_out;
    my_uvm_transaction tx_cmp;
    my_uvm_transaction tx_pre;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        tx_out    = new("tx_out");
        tx_cmp    = new("tx_cmp");
        tx_pre    = new("tx_pre");
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sb_export_output    = new("sb_export_output", this);
        sb_export_compare   = new("sb_export_compare", this);
        sb_export_precise   = new("sb_export_precise", this);

        output_fifo     = new("output_fifo", this);
        compare_fifo    = new("compare_fifo", this);
        precise_fifo    = new("precise_fifo", this); 
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        sb_export_output.connect(output_fifo.analysis_export);
        sb_export_compare.connect(compare_fifo.analysis_export);
        sb_export_precise.connect(precise_fifo.analysis_export);
    endfunction: connect_phase

    virtual task run();
        forever begin
            output_fifo.get(tx_out);
            compare_fifo.get(tx_cmp);     
            precise_fifo.get(tx_pre);         
            comparison();
            precise();
        end
    endtask: run

    virtual function void comparison();
        if (tx_out.out_cos != tx_cmp.out_cos) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            `uvm_info("SB_CMP", tx_out.sprint(), UVM_LOW);
            `uvm_info("SB_CMP", tx_cmp.sprint(), UVM_LOW);
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.out_cos, tx_out.out_cos))
        end
        if (tx_out.out_sin != tx_cmp.out_sin) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            `uvm_info("SB_CMP", tx_out.sprint(), UVM_LOW);
            `uvm_info("SB_CMP", tx_cmp.sprint(), UVM_LOW);
            `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.out_sin, tx_out.out_sin))
        end
    endfunction: comparison

    virtual function void precise();
        real float_cos=real'(real'(tx_out.out_cos)/real'(1<<14));
        real float_sin=real'(real'(tx_out.out_sin)/real'(1<<14));
        if (float_cos != tx_pre.float_cos) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            $display("COS Preceision difference = %f  -  %f = %f", float_cos,tx_pre.float_cos,float_cos-tx_pre.float_cos);
            // `uvm_info("SB_PRE", tx_out.sprint(), UVM_LOW);
            // `uvm_info("SB_PRE", tx_cmp.sprint(), UVM_LOW);
            // `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.out_cos, tx_out.out_cos))
        end
        if (float_sin!= tx_pre.float_sin) begin
            $display("SIN Preceision difference = %f  -  %f = %f", float_sin,tx_pre.float_sin,float_sin-tx_pre.float_sin);
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            // `uvm_info("SB_CMP", tx_out.sprint(), UVM_LOW);
            // `uvm_info("SB_CMP", tx_cmp.sprint(), UVM_LOW);
            // `uvm_error("SB_CMP", $sformatf("Test: Failed! Expecting: %08x, Received: %08x", tx_cmp.out_sin, tx_out.out_sin))
        end
    endfunction: precise
endclass: my_uvm_scoreboard
