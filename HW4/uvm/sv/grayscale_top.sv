
module edge_detect #(
    parameter WIDTH = 720,
    parameter HEIGHT = 720
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full,
    input  logic        in_wr_en,
    input  logic [23:0] in_din,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [7:0]  out_dout
);
//input of the gs module
logic [23:0] in_dout;
logic        in_empty;
logic        in_rd_en;
//output of the gs module
logic  [7:0] out_din;
logic        out_full;
logic        out_wr_en;

//output of gs fifo
logic        out_empty_gs;
logic        out_rd_en_gs;
logic [7:0]  out_dout_gs;

//input of pd module
logic [7:0] in_dout_pd;
logic        in_empty_pd;
logic        in_rd_en_pd;
//output of pd module
logic  [7:0] out_din_pd;
logic        out_full_pd;
logic        out_wr_en_pd;

//output of pd fifo
logic        out_empty_pd;
logic        out_rd_en_pd;
logic [7:0]  out_dout_pd;

//input of sobel module
logic [7:0] in_dout_sb;
logic        in_empty_sb;
logic        in_rd_en_sb;

//output of sobel module
logic  [7:0] out_din_sb;
logic        out_full_sb;
logic        out_wr_en_sb;

grayscale #(
) grayscale (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout),
    .in_rd_en(in_rd_en),
    .in_empty(in_empty),
    .out_din(out_din),
    .out_full(out_full),
    .out_wr_en(out_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(24)
) fifo_in_gs (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(in_din),
    .full(in_full),
    .rd_clk(clock),
    .rd_en(in_rd_en),
    .dout(in_dout),
    .empty(in_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(8)
) fifo_gsout_pdin (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en),
    .din(out_din),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(out_rd_en_gs),
    .dout(out_dout_gs),
    .empty(out_empty_gs)
);
assign out_rd_en_gs=in_rd_en_pd;
assign in_dout_pd=out_dout_gs;
assign in_empty_pd=out_empty_gs;
padding #(

) pad (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout_pd),
    .in_rd_en(in_rd_en_pd),
    .in_empty(in_empty_pd),
    .out_din(out_din_pd),
    .out_full(out_full_pd),
    .out_wr_en(out_wr_en_pd)
);

fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(8)
) fifo_pdout_sbin (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en_pd),
    .din(out_din_pd),
    .full(out_full_pd),
    .rd_clk(clock),
    .rd_en(out_rd_en_pd),
    .dout(out_dout_pd),
    .empty(out_empty_pd)
);
assign out_rd_en_pd=in_rd_en_sb;
assign in_dout_sb=out_dout_pd;
assign in_empty_sb=out_empty_pd;
sobel #(

) sobel (
    .clock(clock),
    .reset(reset),
    .in_dout(in_dout_sb),
    .in_rd_en(in_rd_en_sb),
    .in_empty(in_empty_sb),
    .out_din(out_din_sb),
    .out_full(out_full_sb),
    .out_wr_en(out_wr_en_sb)
);


fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(8)
) fifo_out_sb (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(out_wr_en_sb),
    .din(out_din_sb),
    .full(out_full_sb),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_dout),
    .empty(out_empty)
);


endmodule
