module muti
#(  parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter VECTOR_SIZE = 7)
(
    input  logic                  clock,
    input  logic                  reset,
    input  logic                  start,
    output logic                  done,
    input  logic [DATA_WIDTH-1:0] x_dout,
    output logic [ADDR_WIDTH-1:0] x_addr,
    input  logic [DATA_WIDTH-1:0] y_dout,
    output logic [ADDR_WIDTH-1:0] y_addr,
    output logic [DATA_WIDTH-1:0] z_din,
    output logic [ADDR_WIDTH-1:0] z_addr,
    output logic                  z_wr_en
);

typedef enum logic [1:0] {IDLE, CALC, DONE} state_t;
state_t state, state_c;
logic [ADDR_WIDTH-1:0] i, i_c, j, j_c, k, k_c;
logic [DATA_WIDTH-1:0] temp_sum, temp_sum_c;
logic done_c, done_o;

assign done = done_o;

// always_ff @(posedge clock or posedge reset) begin
//     if (reset) begin
//         state <= IDLE;
//         done_o <= 1'b0;
//         i <= '0;
//         j <= '0;
//         k <= '0;
//         temp_sum <= '0;
       
//     end else begin
//         state <= state_c;
//         done_o <= done_c;
//         i <= i_c;
//         j <= j_c;
//         k <= k_c;
//         temp_sum <= temp_sum_c;
//         end
    
// end
			assign x_addr = i_c * 8 + k_c ;
    			assign y_addr = k_c * 8 + j_c;
always_comb begin
    temp_sum_c = temp_sum;
    z_wr_en = '0;
    z_addr = '0;


    state_c = state;
    i_c = i;
    j_c = j;
    k_c = k;
    done_c = done_o;

    case (state)
        IDLE: begin
            temp_sum_c = '0;
            i_c = '0;
            j_c = '0;
            k_c = '0;
            if (start == 1'b1) begin
                state_c = CALC;
                done_c = 1'b0;
            end else begin
                state_c = IDLE;
            end
        end
        CALC: begin
            if (i <= 7) begin
                if (j <=7) begin
                    if (k <=7) begin
			//if (i==0 && j==0 && k==0) begin
			//temp_sum_c = temp_sum - 8'haeb1c2aa;
			//end else if (
			temp_sum_c = temp_sum + $signed(y_dout) * $signed(x_dout);	
                        k_c = k + 1;
                    end else begin
                        z_wr_en = 1'b1;
                        z_addr = i * 8 + j;
			z_din = temp_sum;
                        temp_sum_c = '0;
                        j_c = j + 1;
                        k_c = '0;
                    end
                end else begin
                    i_c = i + 1;
                    j_c = '0;
                end
            end else begin
                state_c = DONE;
            end
        end
        DONE: begin
            temp_sum_c = '0;
            done_c = '1;
	    state_c = IDLE;
           
        end
	default: begin
            z_din   = 'x;
            z_wr_en = 'x;
            z_addr  = 'x;
            state_c = IDLE;
            i_c     = 'x;
	    j_c     = 'x;
	    k_c     = 'x;
            done_c  = 'x;
	 end
    endcase
end

endmodule

