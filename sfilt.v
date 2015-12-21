// This is a sample example for a serial filter block
// This will be used for the pipelining problem
//
`timescale 1ns/10ps
// cmd codes
// 0 = first mult
// 1 = mult-accumulate
// 2 = shift right by h[6:0] and round
// 3 = send output and clear
module sfilt(input clk, input rst, input pushin, input [1:0] cmd,  
	input [31:0] q, input [31:0] h,
	output pushout, output [31:0] z);
reg signed [63:0] acc,acc_a,acc_d_a,acc_d;
integer q0,q0_d,h0,h0_d,h0_d_a,dout,dout_d,ho_2;
reg push0,push1,push2;
reg _pushout,_pushout_d;
reg [1:0] cmd0,cmd1,cmd2;
reg roundit;

wire signed [63:0] out;
assign pushout = _pushout;
assign z = dout;

DW02_mult_3_stage #(32,32) a1 (.A(q0_d),.B(h0_d),.CLK(clk),.TC(1'b1),.PRODUCT(out));

    always @(*) begin
    q0_d = q0;
    h0_d = h0;
    acc_d = acc;
    dout_d = dout;
   _pushout_d=0;
    acc_d_a = acc_a;
    
  
//------------------------Combo Stage 1---------------//
    if(pushin) begin    
    q0_d = q;
    h0_d = h;
    end
    
    if(push1) begin
    case(cmd1)
   0: begin
    acc_d_a=out;
    end
   1:
    begin
    acc_d_a=out;
    end
    default:begin
    end
   endcase
    end
   
 //---------------------Combo stage 2-----------------//
  
  
  
  
  if(push2) begin
  case(cmd2)
    0:begin
    acc_d=acc_a;
    end
    
   1: begin
    acc_d=acc_a+acc;
    end
   2: begin
    {acc_d,roundit} = {acc,1'b0} >>> ho_2[6:0];
    acc_d = acc_d + ((roundit)?64'b1:64'b0);
    
    end
  3:
    begin
    dout_d = acc[31:0];
    acc_d = 0;
    _pushout_d=1;
    end   
   default: begin end
    
    endcase
    end
end
always @(posedge(clk) or posedge(rst))
  if(rst) begin
    push0 <= #1 0;
    acc <= #1 0;
    q0 <= #1 0;
    h0 <= #1 0;
    dout <= #1 0;
    cmd0 <= #1 0;
    _pushout <= #1 0;
    push1<=#1 0;
    cmd1<=#1 0;
    acc_a<=#1 0;
   h0_d_a<=#1 0;
    ho_2<=#1 0;
    push2<=#1 0;
    cmd2 <=#1 0;
    
  end else begin
  
  //---------------- Pipeline Stage 1-----------------//
  
    push0 <= #1 pushin;
    cmd0 <= #1 cmd; 
    acc<= #1 acc_d;
    q0<= #1 q0_d;
    h0<= #1 h0_d;
    dout <= #1 dout_d; 
    _pushout <= #1 _pushout_d;
    
 //-----------------------Pipeline Stage 2--------------//
 
    push1<=#1 push0;
    cmd1<=#1 cmd0;
    acc_a<=#1 acc_d_a;
    h0_d_a<=#1 h0;
    
    //------------------pipeline stage 3---------//
    push2<= #1 push1;
    cmd2<=#1 cmd1;
    ho_2<=#1 h0_d_a;
  end


endmodule

