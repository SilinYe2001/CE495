module sobel #(
    parameter GRAY_DATA_WIDTH = 8,
    parameter PAD_WIDTH = 722,
    parameter PAD_HEIGHT = 722
)(
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [GRAY_DATA_WIDTH-1:0] in_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [GRAY_DATA_WIDTH-1:0]  out_din
);

typedef enum logic [1:0] {s0,s1,s2,s3} state_types;
state_types state, state_c;
logic [GRAY_DATA_WIDTH-1:0]din,din_c;
logic [8:0][GRAY_DATA_WIDTH-1:0] dout_reg;
logic [GRAY_DATA_WIDTH-1:0]dout_sobel;
logic wait_sign;
logic unsigned[19:0]  counter;
logic unsigned [19:0] output_count,output_count_c;
// unsigned logic[1:0] counter_wait,counter_wait_c;
logic clk_en;
shift_reg #(
    .STAGES(1447),
    .GRAY_DATA_WIDTH(8)
)shift_reg (
    .clk(clock),
    .clk_en(clk_en),
    .rst(reset),
    .din(din),
    .dout(dout_reg),
    .counter_out(counter)
);
sobel_filter#(
    .GRAY_DATA_WIDTH(8)
    //.BUFFER_WIDTH(3)
) sobel_filter(
    .din(dout_reg),
    .dout(dout_sobel)
);

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        din <= 8'h0;
        output_count<='0;
    end else begin
        state <= state_c;
        din <= din_c;
        output_count<=output_count_c;
    end
end  
always_comb begin
    state_c=state;
    din_c=din;
    in_rd_en='0;
    out_wr_en='0;
    clk_en='0;
    wait_sign='0;
    output_count_c=output_count;
    case (state)
        s0:begin  //shift and process
            if($unsigned(counter)<'d1447) begin  //before shifting
                if(in_empty == 1'b0) begin
                    din_c=in_dout;
                    clk_en='1;
                    in_rd_en = 1'b1;
                    state_c=s0;
                end
            end
            else if (output_count<'d518400) begin  // start shifting
                if (in_empty == 1'b0) begin //read and compute
                    din_c=in_dout;
                    clk_en='1;
                    in_rd_en = 1'b1;
                    state_c=s1;
                end
            end
            else begin
                state_c=s0;
            end
        end 
        s1: begin  // output 
            clk_en='0;
            if (out_full == 1'b0) begin //output the value 
                if (output_count%720=='0 && output_count>1 ) begin
                    out_wr_en = 1'b1;
                    out_din = dout_sobel;
                    output_count_c=output_count+1;
                    state_c=s2;
                end
                else begin
                    out_din = dout_sobel;
                    out_wr_en = 1'b1;
                    state_c=s0;
                    output_count_c=output_count+1;
                end
            end
        end
        s2: begin    //shift but not process
            wait_sign='1;
            if (in_empty == 1'b0) begin
                    din_c=in_dout;
                    in_rd_en = 1'b1;
                    clk_en='1;
                    state_c=s3;
            end
        end
        s3: begin//shift but not process
            wait_sign='1;
            if (in_empty == 1'b0) begin
                    din_c=in_dout;
                    in_rd_en = 1'b1;
                    clk_en='1;
                    state_c=s0;
            end
        end
        default: begin
            state_c=state;
            din_c=din;
            in_rd_en='0;
            out_wr_en='0;
            clk_en='0;
        end
    endcase
end
endmodule