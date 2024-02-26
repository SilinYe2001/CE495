module cordic_top (
    input logic clk,
    input logic reset,
    //input fifo
    input logic in_wr_en,
    input int in_rad,
    output logic in_full,
    //output fifo
    input logic out_sin_rd_en,
    output shortint out_sin,
    output logic out_sin_empty,
    input logic out_cos_rd_en,
    output shortint out_cos,
    output logic out_cos_empty
);
int dout_cordicin;
logic rd_en_cordicout;
logic in_empty_cordicin;
logic full_sin;
shortint in_sin;
logic wr_en_sin;
logic full_cos;
shortint in_cos;
logic wr_en_cos;
fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(32)
) fifo_radin (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(in_wr_en),
    .din(in_rad),
    .full(in_full),
    .rd_clk(clk),
    .rd_en(rd_en_cordicout),
    .dout(dout_cordicin),
    .empty(in_empty_cordicin)
);


cordic_module cordic(
    .clk(clk),
    .reset(reset),
    //input fifo
    .in_empty(in_empty_cordicin),
    .in_rad(dout_cordicin),
    .rd_en(rd_en_cordicout),
    //output fifo
    .out_full_sin(full_sin),
    .out_sin(in_sin),
    .wr_en_sin(wr_en_sin),
    .out_full_cos(full_cos),
    .out_cos(in_cos),
    .wr_en_cos(wr_en_cos)
);


fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(16)
) fifo_sin (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_sin),
    .din(in_sin),
    .full(full_sin),
    .rd_clk(clk),
    .rd_en(out_sin_rd_en),
    .dout(out_sin),
    .empty(out_sin_empty)
);


fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(16)
) fifo_cos (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(wr_en_cos),
    .din(in_cos),
    .full(full_cos),
    .rd_clk(clk),
    .rd_en(out_cos_rd_en),
    .dout(out_cos),
    .empty(out_cos_empty)
);
endmodule