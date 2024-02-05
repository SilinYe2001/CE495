module highlight_top #(
    parameter COLOR_DATA_WIDTH =24,
    parameter SUB_DATA_WIDTH = 8,
    parameter FIFO_BUFFER_SIZE = 32
)(
    input logic clock,
    input logic reset,
    // fifo for color image input 
    input logic wr_en_hi,
    output logic full_hi,
    input logic [COLOR_DATA_WIDTH-1:0] din_in_hi,
    //fifo for sub image input
    input logic empty_sub,
    output logic rd_en_sub,
    input logic [SUB_DATA_WIDTH-1:0]din_sub,
    //fifo for final output
    input logic rd_en_final,
    output logic empty_final,
    output logic [COLOR_DATA_WIDTH-1:0] dout_out_final

);
//color input fifo
logic [COLOR_DATA_WIDTH-1:0] din_out_hi; 
logic empty_hi;
logic rd_en_hi;

// final output fifo
logic final_wr_en;
logic final_full;
logic [COLOR_DATA_WIDTH-1:0] dout_in_final;

highlight #(
    .COLOR_DATA_WIDTH(24),
    .SUB_DATA_WIDTH(8)
) highlight_instance (
    .clock(clock),
    .reset(reset),
    .din_color(din_out_hi),
    .co_empty(empty_hi),
    .co_rd_en(rd_en_hi),
    .din_sub(din_sub),
    .sub_empty(empty_sub),
    .sub_rd_en(rd_en_sub),
    .dout_final(dout_in_final),
    .final_full(final_full),
    .final_wr_en(final_wr_en)
);
// fifo for color image input 
fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(COLOR_DATA_WIDTH)
) fifo_in_color (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(wr_en_hi),
    .din(din_in_hi),
    .full(full_hi),
    .rd_clk(clock),
    .rd_en(rd_en_hi),
    .dout(din_out_hi),
    .empty(empty_hi)
);  
// fifo for final output 
fifo #(
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE),
    .FIFO_DATA_WIDTH(COLOR_DATA_WIDTH)
) fifo_out_final (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(final_wr_en),
    .din(dout_in_final),
    .full(final_full),
    .rd_clk(clock),
    .rd_en(rd_en_final),
    .dout(dout_out_final),
    .empty(empty_final)
);  



endmodule