module udp_top (
    input logic clk,
    input logic reset,
    //sof eof
    input logic in_wr_eof,
    input logic in_wr_sof,
    //input fifo
    input logic in_wr_en,
    input logic [7:0] in_din,
    output logic in_full,
    //output fifo
    input logic out_rd_en,
    output logic [7:0]out_dout,
    output logic out_empty
    
);
    //input to read_data
    logic rd_en;
    logic rd_sof;
    logic rd_eof;
    logic [7:0] rd_dout;
    logic rd_empty;
    //output of read_data
    logic out_full;
    logic out_wr_en;
    logic [7:0] out_din;
 
  // Instantiate the fifo_ctrl module
    fifo_ctrl #(
        .FIFO_DATA_WIDTH(8), // Parameter override if different from default
        .FIFO_BUFFER_SIZE(32) // Parameter override if different from default
    ) fifo_ctrl (
        .reset(reset),
        .wr_clk(clk),
        .wr_en(in_wr_en),
        .wr_sof(in_wr_sof),
        .wr_eof(in_wr_eof),
        .din(in_din),
        .full(in_full),
        .rd_clk(clk),
        .rd_en(rd_en),
        .rd_sof(rd_sof),
        .rd_eof(rd_eof),
        .dout(rd_dout),
        .empty(rd_empty)
    );  

    read_data read_data(
        .rd_clk(clk),
        .reset(reset),
        .in_rd_sof(rd_sof),
        .in_rd_eof(rd_eof),
        .in_dout(rd_dout),
        .in_empty(rd_empty),
        .in_rd_en(rd_en),
        .out_full(out_full),
        .out_wr_en(out_wr_en),
        .out_din(out_din)
    );


    fifo #(
        .FIFO_BUFFER_SIZE(32),
        .FIFO_DATA_WIDTH(8)
    ) fifo_data_out (
        .reset(reset),
        .wr_clk(clk),
        .wr_en(out_wr_en),
        .din(out_din),
        .full(out_full),
        .rd_clk(clk),
        .rd_en(out_rd_en),
        .dout(out_dout),
        .empty(out_empty)
    );
endmodule