import uvm_pkg::*;

interface my_uvm_if;
    logic        clock;
    logic        reset;
    logic        in_wr_eof;
    logic        in_wr_sof;
    logic        in_full;
    logic        in_wr_en;
    logic [7:0]  in_din;  /// change to 1 byte
    logic        out_empty;
    logic        out_rd_en;
    logic  [7:0] out_dout;
endinterface
