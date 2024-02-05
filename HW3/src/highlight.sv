module highlight #(
    parameter COLOR_DATA_WIDTH =24,
    parameter SUB_DATA_WIDTH = 8
) (
    input  logic clock,
    input  logic reset,
    input  logic [COLOR_DATA_WIDTH-1:0] din_color,
    input  logic co_empty,
    output logic co_rd_en,
    input  logic [SUB_DATA_WIDTH-1:0] din_sub,
    input  logic sub_empty,
    output logic sub_rd_en,
    output logic [COLOR_DATA_WIDTH-1:0] dout_final,
    input  logic final_full,
    output logic final_wr_en
);
typedef enum logic [0:0] {s0, s1} state_t;
state_t state, state_c;
logic detect, detect_c;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        detect <= '0;
    end else begin
        state <= state_c;
        detect <= detect_c;
    end
end

always_comb begin
    dout_final = '0;
    final_wr_en = 1'b0;
    co_rd_en = 1'b0;
    sub_rd_en = 1'b0;
    detect_c = '0;
    state_c = state;

    case (state)
        s0: begin
            if (co_empty == 1'b0 && sub_empty == 1'b0) begin           
               if (din_sub=='hFF) begin
                    detect_c='1;
               end 
                state_c = s1;   
            end
        end

        s1: begin
            if (final_full == 1'b0) begin
                final_wr_en = 1'b1;
                co_rd_en = 1'b1;
                sub_rd_en = 1'b1;
           		if (detect =='1) begin
           			dout_final='h0000FF;  //set to red
           		end
           		else begin
           			dout_final=din_color; //set to original color
           		end
                state_c = s0;
            end
        end

        default: begin
            state_c = s0;
            detect_c = 'x;
        end
    endcase
end

endmodule