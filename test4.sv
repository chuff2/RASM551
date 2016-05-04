// Test 4 test the decimator and the trig_pos functionality

// Note: This test writes to channels 4 and 5
task test4(input [3:0] dec_fac, input [7:0] trig_pos);

logic [15:0] cmd;
logic [7:0] received_resp;
logic [2:0] ch;

// First we will experiment with using a different decimator value
Initialize();

// Set Ch4TrigCfg to have a negative edge trigger. Other channels not part of trigger at the moment
sendAndCheckAck({WRITE, 6'h04, 8'h08});


// Set decimator value to be higher than 0. A lower sampling rate should make the wave appear to
// have a higher frequency
sendAndCheckAck({WRITE, 6'h06, 4'h0, dec_fac});

// Sets run mode bit high (bit 4 in TrigCfg).
setRunMode();

waitCapDone;
// Dump channel 4 RAM
channel_dump(3'h4);


// Now we wil test trig_pos on channel 5. 
Initialize();

// Set Ch5TrigCfg to have a positive edge trigger. Other channels not part of trigger at the moment
sendAndCheckAck({WRITE, 6'h05, 8'h10});

// Set trig pos value to be 134 (x86). 384*4 - 134*4 = 1000, so there should be a positive edge at 1000 in the plot
sendAndCheckAck({WRITE, 6'h10, trig_pos});

setRunMode;
waitCapDone;
// Dump channel 5 RAM
channel_dump(3'h5);


endtask
