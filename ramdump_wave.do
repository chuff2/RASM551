onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clocks
add wave -noupdate /LA_dig_tb/clk400MHz
add wave -noupdate /LA_dig_tb/clk
add wave -noupdate /LA_dig_tb/REF_CLK
add wave -noupdate /LA_dig_tb/host_cmd
add wave -noupdate /LA_dig_tb/send_cmd
add wave -noupdate /LA_dig_tb/resp
add wave -noupdate /LA_dig_tb/resp_rdy
add wave -noupdate {/LA_dig_tb/iDUT/iDIG/TrigCfg[4]}
add wave -noupdate {/LA_dig_tb/iDUT/iDIG/TrigCfg[5]}
add wave -noupdate -divider -height 25 {Channel Inputs}
add wave -noupdate /LA_dig_tb/CH1L
add wave -noupdate /LA_dig_tb/CH1H
add wave -noupdate /LA_dig_tb/CH2L
add wave -noupdate /LA_dig_tb/CH2H
add wave -noupdate /LA_dig_tb/CH3L
add wave -noupdate /LA_dig_tb/CH3H
add wave -noupdate /LA_dig_tb/CH4L
add wave -noupdate /LA_dig_tb/CH4H
add wave -noupdate /LA_dig_tb/CH5L
add wave -noupdate /LA_dig_tb/CH5H
add wave -noupdate /LA_dig_tb/iAFE/VIL
add wave -noupdate /LA_dig_tb/iAFE/VIH
add wave -noupdate -divider -height 25 {Trigger Logic}
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/triggered_in
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/triggered
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/trig_set
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/set_capture_done
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/protTrig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/armed
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/CH5Trig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/CH4Trig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/CH3Trig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/CH2Trig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/trig_log/CH1Trig
add wave -noupdate -divider -height 25 {Channel Capture SM}
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/clk
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/rst_n
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/trig_pos
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/run_mode
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/wrt_smpl
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/trig
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/capture_done
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/armed
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/set_capture_done
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/we
add wave -noupdate -radix unsigned /LA_dig_tb/iDUT/iDIG/chan_cap/smpl_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/trig_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/rst_smpl_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/rst_trig_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/inc_smpl_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/inc_trig_cnt
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/set_armed
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/clr_armed
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/clr_cap_done
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/state
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_cap/nstate
add wave -noupdate -divider -height 25 {RAM wdata}
add wave -noupdate /LA_dig_tb/iDUT/iDIG/chan_sample1/smpl
add wave -noupdate /LA_dig_tb/iDUT/iDIG/wdataCH1
add wave -noupdate /LA_dig_tb/iDUT/iDIG/wdataCH2
add wave -noupdate /LA_dig_tb/iDUT/iDIG/wdataCH3
add wave -noupdate /LA_dig_tb/iDUT/iDIG/wdataCH4
add wave -noupdate /LA_dig_tb/iDUT/iDIG/wdataCH5
add wave -noupdate -divider {CH1 RAM}
add wave -noupdate /LA_dig_tb/iDUT/iRAMCH1/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {66563490 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 195
configure wave -valuecolwidth 68
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {4275673690 ps} {4288798810 ps}
