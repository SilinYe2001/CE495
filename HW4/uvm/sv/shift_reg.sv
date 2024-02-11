module shift_reg #(
    parameter STAGES = 1447,
    parameter GRAY_DATA_WIDTH =8
)(
    input logic clk,
    input logic rst,
    input logic clk_en,
    input logic [GRAY_DATA_WIDTH-1:0]din,
    output logic [8:0][GRAY_DATA_WIDTH-1:0]dout,
    output logic unsigned [19:0] counter_out
);
    //logic clk_in;
   logic [STAGES-1:0][GRAY_DATA_WIDTH-1:0] imm;
   logic unsigned [19:0]counter;
   logic unsigned [19:0]counter_c;
   genvar i;
   generate if(STAGES>1) begin
        always @(posedge clk) begin 
            if (clk_en) begin
                imm[STAGES-1:1]<=imm[STAGES-2:0];     
            end
        end
    end
   endgenerate
   always @( posedge clk  or posedge rst) begin 
    if(rst) begin
        counter<='0;
        imm[0]<='0;
    end
    else if (clk_en) begin
        imm[0]<=din;
        counter<=counter_c;
    end
   end
   assign counter_out=counter;
   always_comb begin
    counter_c=counter+1;
    dout[0]=imm[STAGES-1];
    dout[1]=imm[STAGES-2];
    dout[2]=imm[STAGES-3];
    dout[3]=imm[STAGES-723];
    dout[4]=imm[STAGES-724];
    dout[5]=imm[STAGES-725];
    dout[6]=imm[STAGES-1445];
    dout[7]=imm[STAGES-1446];
    dout[8]=imm[STAGES-1447];
   end

endmodule