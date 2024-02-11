
module padding #(
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
typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;
shortint i,j,i_c,j_c;
logic [GRAY_DATA_WIDTH-1:0] pd,pd_c;
always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state<=s0;
        pd<='0;
        i<='0;
        j<='0;
    end
    else begin
        state<=state_c;
        pd<=pd_c;
        i<=i_c;
        j<=j_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 8'b0;
    state_c   = state;
    pd_c = pd;
    j_c=j;
    i_c=i;
    case (state)
        s0: begin
            if (j == PAD_HEIGHT-1) begin
                state_c=s1;  // finish
                pd_c='0;
                in_rd_en='0;
                i_c=i+1;
            end
            else if (i== PAD_WIDTH-1) begin
                    j_c=j+1;   //finish one row
                    pd_c='0;
                    in_rd_en='0;
                    state_c=s1;
                    i_c=0;
            end
            else if (i=='d0 || j == 'd0) begin
                pd_c='0;            //pad 0 at sides of each row
                in_rd_en='0;
                i_c=i+1;
                state_c=s1;
            end
            else if (in_empty=='b0) begin
                    i_c=i+1;
                    in_rd_en='1;
                    pd_c=in_dout;
                    state_c=s1;
            end
            else begin
                state_c=s0;
            end  
        end
        s1: begin
            if (out_full == 1'b0) begin
                out_din = pd;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end
        default: begin
            in_rd_en  = 1'b0;
            out_wr_en = 1'b0;
            out_din   = 8'b0;
            state_c   = state;
            pd_c = pd;
            j_c='x;
            i_c='x;
        end
    endcase
end
endmodule
