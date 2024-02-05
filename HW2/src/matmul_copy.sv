module matmul
#( parameter BRAM_DATA_WIDTH = 32,
parameter BRAM_ADDR_WIDTH = 6,
parameter MATRIX_SIZE = 8
)
(
input logic clock,
input logic reset,
input logic start,
output logic[BRAM_ADDR_WIDTH-1:0] x_rd_addr,
input logic[BRAM_DATA_WIDTH-1:0] x_dout,
output logic[BRAM_ADDR_WIDTH-1:0] y_rd_addr,
input logic[BRAM_DATA_WIDTH-1:0] y_dout,
output logic[BRAM_ADDR_WIDTH-1:0] z_wr_addr,
output logic[BRAM_DATA_WIDTH-1:0] z_din,
output logic z_wr_en,
output logic done
);
logic[BRAM_ADDR_WIDTH-1:0] n_x_rd_addr;

logic[BRAM_ADDR_WIDTH-1:0] n_y_rd_addr;

logic[BRAM_ADDR_WIDTH-1:0] n_z_wr_addr;
logic[BRAM_DATA_WIDTH-1:0] n_z_din;
logic n_z_wr_en;
logic n_done;
typedef enum logic {s0,s1} state_t;
state_t n_state, state;
logic [BRAM_DATA_WIDTH-1:0] z,n_z;  //z_cache
logic [3:0] i,n_i,j,n_j,k,n_k; //address index  (0-16)

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
    state <= s0;
    i <='0;
    j <= '0;
    k <= '0;
    z <='0;
    done = '0;
    z_wr_en = '0;
    x_rd_addr='0;
    y_rd_addr='0; 
    z_wr_addr='0;
    z_din='0;
    end else begin
    state <= n_state;
    i <= n_i;
    j <= n_j;
    k <= n_k;
    z <= n_z;
    x_rd_addr<=n_x_rd_addr;
    y_rd_addr<=n_y_rd_addr;
    z_wr_addr<=n_z_wr_addr;
    z_din<=n_z_din;
    z_wr_en<=n_z_wr_en;
    done<=n_done;
    end
end


always_comb begin
n_state = state;
n_done=done;
n_z_wr_en=z_wr_en;
n_x_rd_addr=x_rd_addr;
n_y_rd_addr=y_rd_addr; 
n_z_wr_addr=z_wr_addr;
n_z_din=z_din;
n_i = i;
n_j = j;
n_k = k;
n_z=z;
case (state)
    s0: begin
        if (start == 1'b1) begin
            n_state = s1;
            n_z <='0;
            n_i='0;
            n_j='0;
            n_k='0;
           
        end
        else begin
            n_state = state;
            n_i = i;
            n_j = j;
            n_k = k;
            n_z=z;
        end
    end
    s1: begin
        if (i < MATRIX_SIZE) begin
            if (j < MATRIX_SIZE) begin
                n_x_rd_addr=MATRIX_SIZE*i+k;
                n_y_rd_addr=MATRIX_SIZE*k+j; 
                if (k < MATRIX_SIZE) begin
                    n_k=k+1; 
                    n_z=z+x_dout*y_dout;
                end
                else begin
                    n_z_wr_en='1;
                    n_z_wr_addr=MATRIX_SIZE*i+j; 
                    n_z_din=z;
                    n_k='0;  
                    n_j=j+1;
                    n_z='0;
                end   
            end
            else begin
                n_j='0;
                n_z='0;
                n_i=i+1;            
            end
        end
        else begin
            n_state = s0;
            n_k = '0;
            n_j='0;
            n_z='0;
            n_i='0;  
            n_done='1;
        end
    end
    default: begin
        //n_state = s0;
        n_state = s0;
        n_done='x;
        n_z_wr_en='x;
        n_x_rd_addr='x;
        n_y_rd_addr='x; 
        n_z_wr_addr='x;
        n_z_din='x;
        n_i = 'x;
        n_j = 'x;
        n_k = 'x;
        n_z = 'x;
    end
endcase
end
endmodule