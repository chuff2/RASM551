`timescale 100ps / 10ps
module chan_capture_tb ();

  parameter ENTRIES = 384;
  parameter LOG2 = 9;

  //inputs
  logic clk, rst_n;
  logic capture_done;
  logic [LOG2-1:0] trig_pos;
  logic run_mode;
  logic wrt_smpl;
  logic trig;

  //outputs
  logic armed;
  logic set_capture_done;
  logic we;

  chan_capture chan_capture_DUT (.clk(clk), .rst_n(rst_n), .capture_done(capture_done),
                                 .trig_pos(trig_pos), .run_mode(run_mode), .wrt_smpl(wrt_smpl),
                                 .armed(armed), .set_capture_done(set_capture_done),
                                 .we(we), .trig(trig));

  initial begin
  
	  clk = 0;
	  rst_n = 0;
	  capture_done = 0;
	  trig_pos = 9'b000001000;
	  run_mode = 0;
	  wrt_smpl = 0;
	  trig = 0;
          capture_done = 0;
	
	  repeat (5) @(negedge clk);
	  rst_n = 1;
	
	  @(negedge clk); 
	  $display("Check that you're still in IDLE state, then continue.");
	  $stop; 
	  
	  run_mode = 1;
	
	  @(negedge clk);
	  $display("Should now be in WAIT_WRT_SAMPLE. smpl_cnt and trig_cnt should be 0.");
	  $stop;
	
	  run_mode = 0;
	  wrt_smpl = 1;
	
	  @(negedge clk);
	  $display("Should be in INCR.");
	  $stop;
	
	  @(negedge clk);
	  $display("Should now be in CHECK_SMPL_CNT because no trig signal. Check that smpl_cnt incremented");
	  $stop;

          @(posedge armed);
          $display("Got to smpl_cnt + trig_pos = 384.  smpl_cnt = 12'h178 and trig_pos = 12'h008");
          $stop;
          $display("Now setting trig = 1 to increment trig_cnt until capture is finished.");
          trig = 1; 

          @(posedge set_capture_done);
          capture_done = 1;
          $display("set_capture_done has gone high. Check that trig_cnt = trig_pos.");
          $stop;
          
          repeat (3) @(negedge clk);
          capture_done = 0;

          @(negedge clk);
          $display("Should now be back at IDLE state.");
          $display("Testing done.");
          $stop;

  end


  always #5 clk = ~clk;


endmodule
