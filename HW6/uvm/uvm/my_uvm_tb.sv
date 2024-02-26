
import uvm_pkg::*;
import my_uvm_package::*;

`include "my_uvm_if.sv"

`timescale 1 ns / 1 ns

module my_uvm_tb;

    my_uvm_if vif();

    cordic_top cordic_top(
        .clk(vif.clock),
        .reset(vif.reset),
        .in_wr_en(vif.in_wr_en),
        .in_rad(vif.in_rad),
        .in_full(vif.in_full),
        .out_sin_rd_en(vif.out_sin_rd_en),
        .out_sin(vif.out_sin),
        .out_sin_empty(vif.out_sin_empty),
        .out_cos_rd_en(vif.out_cos_rd_en),
        .out_cos(vif.out_cos),
        .out_cos_empty(vif.out_cos_empty)
    );

    initial begin
        // store the vif so it can be retrieved by the driver & monitor
        uvm_resource_db#(virtual my_uvm_if)::set
            (.scope("ifs"), .name("vif"), .val(vif));

        // run the test
        run_test("my_uvm_test");        
    end

    // reset
    initial begin
        vif.clock <= 1'b1;
        vif.reset <= 1'b0;
        @(posedge vif.clock);
        vif.reset <= 1'b1;
        @(posedge vif.clock);
        vif.reset <= 1'b0;
    end

    // 10ns clock
    always
        #(CLOCK_PERIOD/2) vif.clock = ~vif.clock;
endmodule






