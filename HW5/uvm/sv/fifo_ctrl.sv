module fifo_ctrl #(
parameter FIFO_DATA_WIDTH = 8,
parameter FIFO_BUFFER_SIZE = 1024)
(
input logic reset,
input logic wr_clk,
input logic wr_en,
input logic wr_sof,
input logic wr_eof,
input logic [7:0] din,
output logic full,
input logic rd_clk,
input logic rd_en,
output logic rd_sof,
output logic rd_eof,
output logic [7:0] dout,
output logic empty
);
logic in_full_data,in_full_sfef;
logic in_empty_data,in_empty_sfef;
logic [1:0]dout_sfef;
fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(2)
) fifo_sfef (
    .reset(reset),
    .wr_clk(wr_clk),
    .wr_en(wr_en),
    .din({wr_sof,wr_eof}),
    .full(in_full_sfef),
    .rd_clk(rd_clk),
    .rd_en(rd_en),
    .dout(dout_sfef),
    .empty(in_empty_sfef)
);

assign rd_sof=dout_sfef[1];
assign rd_eof=dout_sfef[0];
fifo #(
    .FIFO_BUFFER_SIZE(32),
    .FIFO_DATA_WIDTH(8)
) fifo_data (
    .reset(reset),
    .wr_clk(wr_clk),
    .wr_en(wr_en),
    .din(din),
    .full(in_full_data),
    .rd_clk(rd_clk),
    .rd_en(rd_en),
    .dout(dout),
    .empty(in_empty_data)
);

assign full = in_full_sfef|in_full_data;
assign empty = in_empty_sfef|in_empty_data;
endmodule