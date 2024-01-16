`timescale 1ns/1ns

module fibonacci_tb;

  logic clk; 
  logic reset = 0;
  logic [15:0] din = 0;
  logic start = 0;
  logic [15:0] dout;
  logic done;
  logic [31:0]count;

  // instantiate your design
  fibonacci fib(.clk(clk), .reset(reset), .din(din), .start(start), .dout(dout), .done(done));

  // Clock Generator
  always
  begin
	clk = 0;
	#5;
	clk = 1;
	#5;
	if (start) begin
		count=0;
	end
	else begin
		count=count+1;
	end
  end

  initial
  begin
	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 5 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 5;
	start = 1;
	#10 start = 0;
	
	// Wait until calculation is done	
	#10 wait (done ==1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 5) begin
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
		$display("clock cycle count: %d", count);
	end
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 5", dout);


	/* ----------------------
	   TEST MORE INPUTS HERE
	   ---------------------
	*/
	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 10 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 10;
	start = 1;
	#10 start = 0;
	
	// Wait until calculation is done	
	#10 wait (done ==1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 55) begin
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
		$display("clock cycle count: %d", count);
	end
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 55", dout);

	// Reset
	#0 reset = 0;
	#10 reset = 1;
	#10 reset = 0;
	
	/* ------------- Input of 10 ------------- */
	// Inputs into module/ Assert start
	#10;
	din = 19;
	start = 1;
	#10 start = 0;
	
	// Wait until calculation is done	
	#10 wait (done ==1);

	// Display Result
	$display("-----------------------------------------");
	$display("Input: %d", din);
	if (dout === 4181) begin
	    $display("CORRECT RESULT: %d, GOOD JOB!", dout);
		$display("clock cycle count: %d", count);
	end
	else
	    $display("INCORRECT RESULT: %d, SHOULD BE: 4181", dout);
	#10;


    // Done
	$stop;
  end
  
endmodule