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

typedef enum logic[1:0] {init,i_cond,j_cond,k_cond} state_t;
state_t n_state, state;
logic [BRAM_DATA_WIDTH-1:0] z,n_z;  //z_cache
logic [3:0] i,n_i,j,n_j,k,n_k; //address index  (0-16)

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
    state <= init;
    i <='0;
    j <= '0;
    k <= '0;
    z <='0;
    end else begin
    state <= n_state;
    i <= n_i;
    j <= n_j;
    k <= n_k;
    z <= n_z;
    end
end


always_comb begin
done = '0;
z_wr_en = '0;
x_rd_addr='0;
y_rd_addr='0; 
z_wr_addr='0;
z_din='0;
n_state = state;
n_i = i;
n_j = j;
n_k = k;
n_z=z;
case (state)
    init: begin
        if (start == 1'b1) begin
            n_state = i_cond;
            n_z <='0;
            n_i='0;
            n_j='0;
            n_k='0; 
        end
    end
    i_cond: begin
        if (i < MATRIX_SIZE) begin
            n_state=j_cond;
        end
        else begin
            n_state = init;
            n_k = '0;
            n_j='0;
            n_z='0;
            n_i='0;  
            done='1;
        end
    end
    j_cond:begin
        if (j < MATRIX_SIZE) begin
            n_state=k_cond;
            end
        else begin
            n_j='0;
            n_z='0;
            n_i=i+'b1; 
            n_state=i_cond;           
        end
    end
    k_cond:begin

        if (k < MATRIX_SIZE) begin
            x_rd_addr=MATRIX_SIZE*i+k;
            y_rd_addr=MATRIX_SIZE*k+j;
            n_state=main;
        end
        else begin
            z_wr_en='b1;
            z_wr_addr=MATRIX_SIZE*i+j; 
            z_din=z;
            n_j=j+'b1;
            n_z='0;
            n_k='0;  
            n_state=j_cond;
        end  
    end
    main: begin
        n_z=$signed(z)+$signed(x_dout)*$signed(y_dout);
        n_k=k+'b1; 
        n_state=k_cond;

    end
    default: begin
        //n_state = s0;
        done = 'x;
        z_wr_en= 'x;
        n_i = 'x;
        n_j = 'x;
        n_k = 'x;
        n_z = 'x;
    end
endcase
end
endmodule