module fibonacci(
  input logic clk, 
  input logic reset,
  input logic [15:0] din,
  input logic start,
  output logic [15:0] dout,
  output logic done
);

  // State Declaration
  enum logic [1:0] {S0, S1, S2} state, n_state;

  // Local Logic Signals
  logic [15:0] num1, num2, n_num1, n_num2;
  logic [15:0] count, n_count;

  // Sequential Logic
  always_ff @(posedge clk or posedge reset)
  begin
    if (reset) begin
       state <= S0;
       num1 <= 0;
       num2 <= 0;
       count <= 0;
    end else begin
       state <= n_state;
       num1 <= n_num1;
       num2 <= n_num2;
       count <= n_count;
    end
  end

  // Combinatorial Logic
  always_comb 
  begin
    n_state = state;
    done = 0;
    dout = 0;
    n_num1 = num1;
    n_num2 = num2;
    n_count = count;
    case (state)
      S0:
        if (start) begin
          n_state = S1;
          n_num1 = 0;
          n_num2 = 1;
          n_count = 1;
        end
      S1:
        if (count == din) begin
          n_state = S2;
        end else begin
          n_num1 = num2;
          n_num2 = num1 + num2;   
          n_count = count + 1;      
        end
      S2:
        begin
          dout = num2;
          done = 1;
        end
      default:
        begin
          n_state = S0;
          n_num1= 0;
		  n_num2 = 0;
		  n_count = 0;
		end
	 endcase
	end

endmodule