module cordic_module (
    input logic clk,
    input logic reset,
    //input fifo
    input logic in_empty,
    input int in_rad,
    output logic rd_en,
    //output fifo
    input logic out_full_sin,
    output shortint out_sin,
    output logic wr_en_sin,
    input logic out_full_cos,
    output shortint out_cos,
    output logic wr_en_cos
);

localparam real M_PI = 3.14159265358979323846;
localparam real K = 1.646760258121066;
// Define the number of elements in the CORDIC table
localparam shortint CORDIC_NTAB = 16;
// Define the CORDIC table as a constant array
logic [0:15][15:0] cordic_table = '{
    16'h3243, 16'h1DAC, 16'h0FAD, 16'h07F5, 16'h03FE, 16'h01FF, 16'h00FF, 16'h007F, 
    16'h003F, 16'h001F, 16'h000F, 16'h0007, 16'h0003, 16'h0001, 16'h0000, 16'h0000
};
int cordic_1k,pi,two_pi,half_pi;
int r_imm;
logic [CORDIC_NTAB:0][15:0] x_inter;
logic [CORDIC_NTAB:0][15:0] y_inter;
logic [CORDIC_NTAB:0][15:0] z_inter;
logic [CORDIC_NTAB:0]valid_inter;

assign   cordic_1k = 32'h0000_26dd;
assign   pi = 32'h0000_C90F;
assign    two_pi = 32'h0001_921F;
assign    half_pi = 32'h0000_6487;



always_comb begin
    //default
    r_imm='0;
    rd_en=1'b0;
    wr_en_sin=1'b0;
    wr_en_cos=1'b0;
    valid_inter[0]=1'b0;
    out_sin='0;
    out_cos='0;
    x_inter[0]=cordic_1k;
    y_inter[0]= 0;
    z_inter[0]='0;
    //read process
    if (in_empty==1'b0) begin
        rd_en=1'b1;
        //pre calculate z first input 
        if (in_rad>pi) begin
            r_imm=in_rad-two_pi;
        end
        else if (in_rad<-pi) begin
            r_imm=in_rad+two_pi;
        end
        else begin
            r_imm=in_rad;
        end
        if (r_imm>half_pi) begin
            z_inter[0]=r_imm-pi;  
            x_inter[0]=-cordic_1k;
        end
        else if (r_imm<-half_pi) begin
            z_inter[0]=r_imm+pi;
            x_inter[0]=-cordic_1k;
        end
        else begin
            z_inter[0]=r_imm;
        end
        valid_inter[0]=1'b1;
    end
    //write process
    if (out_full_cos==1'b0 && out_full_sin==1'b0) begin
        if (valid_inter[16]==1'b1) begin
            wr_en_sin=1'b1;
            wr_en_cos=1'b1;
            out_cos=x_inter[16];
            out_sin=y_inter[16];
        end
    end 
end

// generate 16 stages of cordic
generate
    genvar i;
    for (i = 0; i < CORDIC_NTAB; i++) begin : cordic_stage
        cordic_stage cordic_stage(
            .clk(clk),
            .reset(reset),
            .valid_in(valid_inter[i]),
            .k(i),
            .c(cordic_table[i]),
            .xk(x_inter[i]),
            .yk(y_inter[i]),
            .zk(z_inter[i]),
            .valid_out(valid_inter[i+1]),
            .x_out(x_inter[i+1]),
            .y_out(y_inter[i+1]),
            .z_out(z_inter[i+1])
        );
    end
endgenerate


endmodule