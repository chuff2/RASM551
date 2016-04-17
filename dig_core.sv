module dig_core(clk,rst_n,smpl_clk,wrt_smpl, decimator, VIH, VIL, CH1L, CH1H,
				CH2L, CH2H, CH3L, CH3H, CH4L, CH4H, CH5L, CH5H, cmd, cmd_rdy,
                clr_cmd_rdy, resp, send_resp, resp_sent, LED, we, waddr,
				raddr, wdataCH1, wdataCH2, wdataCH3, wdataCH4, wdataCH5, rdataCH1,
                rdataCH2, rdataCH3, rdataCH4, rdataCH5);
				
  parameter ENTRIES = 384,	// defaults to 384 for simulation, use 12288 for DE-0
            LOG2 = 9;		// Log base 2 of number of entries
			
  input clk,rst_n;			// 100MHz clock and active low asynch reset
  input wrt_smpl;			// indicates when timing is right to write a smpl
  input smpl_clk;			// goes to channel sample logic (decimated 400MHz clock)
  input CH1L,CH1H;			// signals from CH1 comparators
  input CH2L,CH2H;			// signals from CH2 comparators
  input CH3L,CH3H;			// signals from CH3 comparators
  input CH4L,CH4H;			// signals from CH4 comparators
  input CH5L,CH5H;			// signals from CH5 comparators
  input [15:0] cmd;			// command from host
  input cmd_rdy;			// indicates command from host is ready
  input resp_sent;			// indicates response has been sent to host
  input [7:0] rdataCH1;		// sample read from CH1 RAM
  input [7:0] rdataCH2;		// sample read from CH2 RAM
  input [7:0] rdataCH3;		// sample read from CH3 RAM
  input [7:0] rdataCH4;		// sample read from CH4 RAM
  input [7:0] rdataCH5;		// sample read from CH5 RAM  
  
  output [7:0] VIH,VIL;		// sets PWM level for VIH and VIL thresholds
  output clr_cmd_rdy;		// asserted to knock down cmd_rdy after command interpretted
  output [7:0] resp;		// response to host
  output send_resp;			// asserted to initiate transmission of response to host
  output LED;				// LED output
  output we;				// write enable to all channel RAMS
  output [LOG2-1:0] waddr;	// write address to all RAMs
  output [LOG2-1:0] raddr;	// read address to all RAMs
  output [3:0] decimator;	// only every 2^decimator samples is taken
  output [7:0] wdataCH1;	// sample to write to CH1 RAM
  output [7:0] wdataCH2;	// sample to write to CH2 RAM
  output [7:0] wdataCH3;	// sample to write to CH3 RAM
  output [7:0] wdataCH4;	// sample to write to CH4 RAM
  output [7:0] wdataCH5;	// sample to write to CH5 RAM

  ///////////////////////////////////////////////////////
  // delcare any needed internal signals as type wire //
  /////////////////////////////////////////////////////
  logic CH1Trig, CH2Trig, CH3Trig, CH4Trig, CH5Trig;
  logic [4:0] CH1TrigCfg, CH2TrigCfg, CH3TrigCfg, CH4TrigCfg, CH5TrigCfg;
  logic CH1Hff5, CH2Hff5, CH3Hff5, CH4Hff5, CH5Hff5;
  logic CH1Lff5, CH2Lff5, CH3Lff5, CH4Lff5, CH5Lff5;
  logic CH1L, CH2L, CH3L, CH4L, CH5L;
  logic CH1H, CH2H, CH3H, CH4H, CH5H;
  logic [5:0] TrigCfg;
  logic protTrig;
  logic [7:0] baud_cntH, baud_cntL;
  logic [7:0] maskH, maskL;
  logic [7:0] matchH, matchL;
  ///////////////////////////////////////////////////////////////
  // Instantiate the sub units that make up your digital core //
  /////////////////////////////////////////////////////////////
  //unsure about:: set_armed, set_capture_done...(maybe need to be outputs of the chan_capture module)

  //trigger logic
  prot_trig protTrigLogic(.protTrig(protTrig), .clk(clk), .rst_n(rst_n),  .TrigCfg(TrigCfg), 
	.maskH(maskH), .maskL(maskL), .matchH(matchH), .matchL(matchL), .CH1L(CH1L), 
	.CH2L(CH2L), .CH3L(CH3L), .baud_cntH(baud_cntH), .baud_cntL(baud_cntL));

  chan_trig chan1Trig(.clk(clk), .set_armed(), .CHxTrigCfg(CH1TrigCfg), .CHxTrig(CH1Trig), 
	.CHxHff5(CH1Hff5), .CHxLff5(CH1Lff5));

  chan_trig chan2Trig(.clk(clk), .set_armed(), .CHxTrigCfg(CH2TrigCfg), .CHxTrig(CH2Trig), 
	.CHxHff5(CH2Hff5), .CHxLff5(CH2Lff5));

  chan_trig chan3Trig(.clk(clk), .set_armed(), .CHxTrigCfg(CH3TrigCfg), .CHxTrig(CH3Trig), 
	.CHxHff5(CH3Hff5), .CHxLff5(CH3Lff5));

  chan_trig chan4Trig(.clk(clk), .set_armed(), .CHxTrigCfg(CH4TrigCfg), .CHxTrig(CH4Trig), 
	.CHxHff5(CH4Hff5), .CHxLff5(CH4Lff5));

  chan_trig chan5Trig(.clk(clk), .set_armed(), .CHxTrigCfg(CH5TrigCfg), .CHxTrig(CH5Trig), 
	.CHxHff5(CH5Hff5), .CHxLff5(CH5Lff5));

  trigger_logic(.clk(clk), .rst_n(rst_n), .CH1Trig(CH1Trig), .CH2Trig(CH2Trig), .CH3Trig(CH3Trig), .CH4Trig(CH4Trig),
	.CH5Trig(CH5Trig), .protTrig(protTrig), .armed(armed), .set_capture_done(), .triggered());

  //command config
  cmd_cfg cmd_config(.clk(clk), .rst_n(rst_n), .cmd(), .cmd_rdy(), 
	.resp_sent(), .set_capture_done(), .waddr(),
	.rdataCH1(), .rdataCH2(), .rdataCH3(), .rdataCH4(), .rdataCH5(), 
	.resp(), .send_resp(), .clr_cmd_rdy(), .trig_pos(), .addr_ptr(), .decimator(), 
	.maskL(maskL), .maskH(maskH), .matchL(matchL), .matchH(matchH), .baud_cntL(baud_cntL),
	 .baud_cntH(baud_cntH), .TrigCfg(TrigCfg), .CH1TrigCfg(CH1TrigCfg), 
	.CH2TrigCfg(CH2TrigCfg), .CH3TrigCfg(CH3TrigCfg), .CH4TrigCfg(CH4TrigCfg),
	 .CH5TrigCfg(CH5TrigCfg), .VIH(), .VIL());

  //channel capture
  chan_capture chan_cap(.clk(clk), .rst_n(rst_n), .trig_pos(), .run_mode(), .wrt_smpl(), .armed(armed), .capture_done(), .we(), .smpl_cnt(), .trig());

  //5 instances of channel sample logic TODO
  
			   
endmodule  