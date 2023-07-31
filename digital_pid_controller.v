// Code your design here
//PID logic for low latency FPGA :
//Design.v
// Code your design here

module digital_PID_controller(f_pwm,up_clk,N_ref,N_con,,K_p,K_i,K_d,rst);
  input  [18:0] N_ref;
  input [18:0] K_p,K_i,K_d;
input f_pwm,up_clk;
  output reg [18:0] N_con;
  reg [18:0] N_con_temp;//signed is removed
 // wire signed [31:0] N_int_temp1;// in Q2.30
  
  input rst;
  wire signed [35:0] N_prop,N_int_inst,N_der;
  reg signed [35:0] N_int;
 
parameter u_int_max=19'sb0_111111111111111;
  
  reg signed [35:0] N_prop_temp1;
  reg signed [35:0]N_prop_tempq; //in Q1.15
  reg signed [18:0] N_prop_temp;
  reg signed [18:0] N_prop_temp_rs2;
  
  
  reg signed [35:0] N_int_temp1;
  reg signed [35:0]N_int_tempq; //in Q1.15
  reg signed [18:0] N_int_temp;
  reg signed [35:0] N_int_temp2;
  reg signed [35:0] N_int_temp3;
  reg signed [35:0] N_int_temp4;
  
  
  reg signed [18:0] N_der_temp1;
  reg signed [18:0] N_er_prev;
  reg signed [35:0] N_der_tempq;
  reg signed [35:0] N_der_temp2;
  reg signed [18:0] N_der_temp;
  
  reg signed [18:0] N_er;
  reg [18:0] N_dummy;
  
  
  //initilizations in interal

  always @ (posedge f_pwm)

    begin

      if(rst)

        begin

        N_int_temp3<=0;

          N_con <= 19'b0;

          N_er<= 19'b0;

          N_er_prev<= 19'b0;

        end

      else

        N_er<= N_ref - N_con;

   end
      
      
    
  //propotional controller in Q1.15
  
//     always @ (posedge f_pwm)
//      N_er <= N_ref - N_con;
  
assign N_prop_tempq = K_p*N_er;		//Q2.30 error 
  
  always @ ( posedge f_pwm )
  begin
    
    if (N_prop_tempq[35] == N_prop_tempq[34])
    begin
  	  N_prop_temp1 = (N_prop_tempq << 1);
    end
  
    else
    begin
      N_prop_temp1 = (N_prop_tempq << 1) + 36'h100000000; //in Q2.30
    end
  
    
//     if (N_prop_temp ==19'b0)			//compensation for error 
//       N_prop_temp = N_prop_temp +19'h014a;
    
    assign N_prop_temp_rs2 ={N_prop_temp1 [35:18]};	// logic to enter kp in decimals.
    assign N_prop_temp =(N_prop_temp_rs2 >> 2);		//in Q1.15
    
  end
  
  
   //integral part ki*error controller in Q1.15
  
assign N_int_tempq = K_i*N_er;		//Q2.30 error 
  
  always @ ( posedge f_pwm )
  begin
    
    if (N_int_tempq[35] == N_int_tempq[34])
    begin
      N_int_temp1 = (N_int_tempq << 1);
    end
  
    else
    begin
      N_int_temp1 = (N_int_tempq << 1) + 36'h100000000; //in Q2.30
    end
  
    assign N_int_temp2 ={N_int_temp1 [35:18]};		//in Q1.15
    
    N_int_temp4 = N_int_temp2+N_int_temp3;
	N_int_temp3 = N_int_temp4;
    
  end
  
  
  //saturation block for integral controller 
  
always@(posedge f_pwm)
  begin
    
    if (N_int_temp4 > u_int_max)
	N_int_temp <= u_int_max;
    
	else
	N_int_temp <= N_int_temp4;
    
  end
  
  //derivative controller
  
  always@(posedge f_pwm) 
    begin
	N_der_temp1 = (N_er-N_er_prev);
	N_er_prev = N_er;
	end
   
    
assign N_der_tempq = K_d*N_der_temp1;		//Q2.30 error 
  
  always @ ( posedge f_pwm )
  begin
    
    if (N_der_tempq[35] == N_der_tempq[34])
    begin
      N_der_temp2 = (N_der_tempq << 1);
    end
  
    else
    begin
      N_der_temp2 = (N_der_tempq << 1) + 36'b1; //in Q2.30
    end
  
    assign N_der_temp ={N_der_temp2 [35:18]};		//in Q1.15
    
   
    
  end
  
   //assign N_con = N_prop_temp + N_int_temp + N_der_temp;
   

  
  
  always @ (negedge up_clk)
    begin
  
      N_con = N_prop_temp + N_int_temp + N_der_temp ;
      //N_con = (N_con_temp >> 2);
      //N_er <= N_ref - N_dummy;
      
    end

  	
endmodule
