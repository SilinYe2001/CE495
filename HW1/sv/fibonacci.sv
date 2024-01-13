module fibonacci(
  input logic clk, 
  input logic reset,
  input logic [15:0] din,
  input logic start,
  output logic [15:0] dout,
  output logic done );

  // TODO: Add local logic signals
  enum logic [1:0] {S0,S1,S2} state,n_state;
  logic [15:0] num1,num2,n_num1,n_num2;
  //logic [15:0] count,n_count;
  always_ff @(posedge clk, posedge reset)
  begin
    if ( reset == 1'b1 ) begin
       state=S0;
       num1=16'b0;
       num2=16'b0;
       //count=16'b0;
    end else begin
       state=n_state;
       num1=n_num1;
       num2=n_num2;
       count=n_count;
    end
  end

  always_comb 
  begin
  n_state=state;
  done=1'b0;
  dout = 16'b0;
  n_num1=num1;
  n_num2=num2;
  //n_count=count;
    case (state)
      S0:
        if (start==1'b1) begin  // initailize and begin 
          n_state = S1;
          n_num1 = 16'b0;
          n_num2 = 16'b1;
          //n_count= 16'b10;
        end
      S1:
        if (num2>=din) begin  // loop to calculate 
          n_state<=S2;
          //n_count = count+1;
        end 
        else begin
          n_num1=num2;
          n_num2=num1+num2;         
        end
      S2:   //finish and stay in S2
        dout=num2;
        done=1'b1;
      default:
        n_state=S0;
        n_num1=16'b0;
        n_num2=16'b0;
       // n_count=16'b0;
    endcase
  end
endmodule
