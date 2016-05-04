// Test5 tests the PWM controller for VIH and VIL. We alter the levels to 
// produce mostly Xs or all 0/1s and check that the plot matches our expectation

// Note: This test writes to channels 1 and 2.
// Channel 1 should show up with mostly Xs, channel 2 should have no Xs
task test5;

logic [15:0] cmd;
logic [7:0] received_resp;
logic [2:0] ch;

Initialize();

// set VIH and VIL to be in the middle. VIH=7F, VIL=80. There should be no Xs, only 1s and 0s
// This will test the PWM module


// Set VIH=x7F
sendAndCheckAck({WRITE, 6'h07, 8'h7F});

// Set VIL=x80
sendAndCheckAck({WRITE, 6'h08, 8'h80});

// Set Ch2TrigCfg to have a positive edge trigger. Other channels not part of trigger at the moment
sendAndCheckAck({WRITE, 6'h02, 8'h10});

setRunMode;
waitCapDone;
channel_dump(3'h2);

// Now we will set VIH and VIL to very high/low and dump channel 1. We should only get mostly Xs
Initialize();

// Set VIH=xE0
sendAndCheckAck({WRITE, 6'h07, 8'hF0});

// Set VIL=x10
sendAndCheckAck({WRITE, 6'h08, 8'h10});

// Set Ch1TrigCfg to have a positive edge trigger. Other channels not part of trigger at the moment
sendAndCheckAck({WRITE, 6'h01, 8'h10});

setRunMode;
waitCapDone;
channel_dump(3'h1);


endtask

