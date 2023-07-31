/test bench

// Code your testbench here
// or browse Examples

//test bench

// Code your testbench here
// or browse Examples

module digital_PID_controller_tb;
  reg  [18:0] N_ref;
  reg f_pwm,up_clk;
  reg signed [18:0] K_p;
  reg signed [18:0] K_i;
  reg signed [18:0] K_d;
  wire signed [18:0] N_con;
  reg signed [18:0] N_rer;
  reg rst;
  
  reg signed [35:0] N_prop_tempq;
  reg signed [35:0] N_prop_temp1; //in Q1.15
  wire signed [18:0] N_prop_temp; 

  // Instantiate the PID Controller module
  digital_PID_controller uut (
    .N_ref(N_ref),
    .f_pwm(f_pwm),
    .K_p(K_p),
    .K_i(K_i),
    .K_d(K_d),
    .N_con(N_con),
    .up_clk(up_clk),
    .rst(rst)
  );

  // Clock generation
  always begin
    #5 f_pwm = ~f_pwm;
    #10 up_clk = ~up_clk;
  end

  // Test stimulus
  initial 
    begin
      
     // $monitor("Time=%0t ,N_er=%d ,K_p=%d,K_i=%d, K_d=%d N_con=%d,N_prop_temp1=%b,N_prop_temp=%b,N_prop_tempq=%b", $time, N_er, K_p, K_i, K_d, N_con,N_prop_temp1,N_prop_temp,N_prop_tempq);
    $dumpfile("dump.vcd"); 
    $dumpvars;

    // Initialize inputs
    //N_er = 0;
	 K_p=19'b0000000001010000_10; //Q1.15 dec 80
	 K_i=19'b0100_0110_1110_0011; //Q1.15 dec 99
	 K_d=19'b00000_0000000000000; //Q1.15 dec 99
    //K_d =10'b0;
    f_pwm = 0;
      up_clk =0;
      #5 rst =1;
      #100 rst =0;

    // Apply test cases
    #10 N_ref = 19'sb0000_1111_1111_1110;
   
    // End simulation
    #50000 $finish;
    end
endmodule
