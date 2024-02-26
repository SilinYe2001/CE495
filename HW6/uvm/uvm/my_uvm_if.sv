import uvm_pkg::*;

interface my_uvm_if;
    logic        clock;
    logic        reset;
    logic        in_wr_en;
    logic        in_full;
    int           in_rad;  /// change to 1 byte
    logic        out_sin_empty;
    logic        out_sin_rd_en;
    shortint    out_sin;
    logic        out_cos_empty;
    logic        out_cos_rd_en;
    shortint    out_cos;
endinterface
