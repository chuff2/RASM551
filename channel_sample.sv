module channel_sample (CH_Hff5, CH_Lff5, smpl, CH_H, CH_L, smpl_clk, clk);

output reg [7:0] smpl;
output reg CH_Hff5;
output reg CH_Lff5;

input CH_H;
input CH_L;
input smpl_clk;
input clk;

reg CH_Hff1, CH_Hff2, CH_Hff3, CH_Hff4;
reg CH_Lff1, CH_Lff2, CH_Lff3, CH_Lff4;


//CH_H and CH_L ffs
//uses smpl_clk, which is 400MHz/(2^decimator)
always @(negedge smpl_clk) begin

  CH_Hff5 <= CH_Hff4;
  CH_Hff4 <= CH_Hff3;
  CH_Hff3 <= CH_Hff2;
  CH_Hff2 <= CH_Hff1;
  CH_Hff1 <= CH_H;

  CH_Lff5 <= CH_Lff4;
  CH_Lff4 <= CH_Lff3;
  CH_Lff3 <= CH_Lff2;
  CH_Lff2 <= CH_Lff1;
  CH_Lff1 <= CH_L;

end


//smpl register, uses clk at 100MHz\
always@(posedge clk) begin

  smpl[7] <= CH_Hff2;
  smpl[6] <= CH_Lff2;
  smpl[5] <= CH_Hff3;
  smpl[4] <= CH_Lff3;
  smpl[3] <= CH_Hff4;
  smpl[2] <= CH_Lff4;
  smpl[1] <= CH_Hff5;
  smpl[0] <= CH_Lff5;

end


endmodule
