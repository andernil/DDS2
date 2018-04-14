//////////////////////////////////////////////////
// Title:   assertions_hdlc
// Author:
// Date:
//////////////////////////////////////////////////

module assertions_hdlc (
  output int  ErrCntAssertions,
  input logic Clk,
  input logic Rst,
  input logic Rx,
  input logic Rx_EoF,
  input logic Rx_FlagDetect,
  input logic Rx_Ready,
  input logic[7:0] DataOut,
  input logic[7:0] DataIn,
  input logic[2:0]  Address,
  input logic WriteEnable,
  input logic ReadEnable,
  input logic[7:0] Rx_Data,
  input logic Rx_Drop,
  input logic Rx_AbortSignal,
  input logic Rx_FrameError,
  input logic Rx_ValidFrame,
  input logic Rx_Overflow,
  input logic Tx,
  input logic Tx_NewByte,
  input logic Tx_DataAvail,
  input logic Tx_Done,
  input logic Tx_Full,
  input logic[7:0] Tx_FrameSize,
  input logic[7:0] Tx_Data,
  input logic TxEN,
  input logic Tx_Enable,
  input logic Tx_AbortedTrans,
  input logic Tx_WriteFCS,
  input logic Tx_FCSDone,
  input logic Tx_AbortFrame,
  input logic Tx_ValidFrame
  );

  initial begin
    ErrCntAssertions = 0;
  end

  sequence Rx_flag;
    !Rx ##1 Rx [*6] ##1 !Rx;
  endsequence

  sequence Tx_flag;
    !Tx ##1 Tx [*6] ##1 !Tx;
  endsequence

  sequence seq_tx;    
   !Tx and $past(Tx) and $past(Tx,2) and $past(Tx,3) and $past(Tx,4) and $past(Tx,5);
  endsequence

  sequence seq_rx;    
   !Rx and $past(Rx) and $past(Rx,2) and $past(Rx,3) and $past(Rx,4) and $past(Rx,5);
  endsequence

  sequence abort;
    !Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx;
  endsequence

  sequence prev_abort;
    $past(Rx,4) and $past(Rx,5) and $past(Rx,6) and $past(Rx,7) and $past(Rx,8) and $past(Rx,9) and $past(!Rx,10);
  endsequence

  sequence startendframe;
   !Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 Tx ##1 !Tx;
  endsequence

  // Check if flag sequence is detected
  property Receive_FlagDetect;
    @(posedge Clk) Rx_flag |-> ##2 Rx_FlagDetect;
  endproperty


  property correct_data_rxBuff_Drop;
    @(posedge Clk) $rose(Rx_Drop) |-> DataOut==8'b00000000;
  endproperty


  property correct_data_rxBuff_Abort;
    @(posedge Clk) $rose(Rx_AbortSignal) |-> DataOut==8'b00000000;
  endproperty


  property correct_data_rxBuff_Error;
    @(posedge Clk) $rose(Rx_FrameError) |-> DataOut==8'b00000000;
  endproperty

  property Verify3; //Correct bits set in Rx status/control-register after receiving frame
    @(posedge Clk) disable iff (!Rst) $fell(Rx_EoF) |-> 
    if(Rx_AbortSignal)
        (##4 !Rx_Overflow ##0 Rx_AbortSignal ##0 !Rx_FrameError ##0 !Rx_Ready, $display("Aborted frame at: ",$time))
    else if (Rx_Overflow)
        (##4 Rx_Overflow ##0 !Rx_AbortSignal ##0 !Rx_FrameError ##0 !Rx_Ready, $display("Overflow at: ",$time))
    else if (Rx_FrameError)
        (##4 !Rx_Overflow ##0 !Rx_AbortSignal ##0 Rx_FrameError ##0 !Rx_Ready, $display("Frame error at: ",$time))
    else
        ##4 !Rx_Overflow ##0 !Rx_AbortSignal ##0 !Rx_FrameError ##0 Rx_Ready;
  endproperty


  property Verify5; //Start and end frame generation, 01111110
    @(posedge Clk) disable iff (!Rst) !$stable(Tx_ValidFrame) ##0 $past(!Tx_AbortFrame,2)|-> ##[0:2] startendframe;
  endproperty


  property Verify6_insert; //Zero insert
    @(posedge Clk) disable iff (!Rst) seq_tx ##0 $past(!Tx_WriteFCS,5) ##0 ($past(Tx_NewByte,5) or $past(Tx_NewByte,6) or $past(Tx_NewByte,7))|-> ($past(Tx_Data,0)==?8'bxx111111 or $past(Tx_Data,0)==?8'bx111111x or $past(Tx_Data,0)==?8'b111111xx);
  endproperty


  property Verify6_remove; //Zero removal
    @(posedge Clk) disable iff (!Rst) seq_rx |-> Rx_Data==?8'bxx111111 or Rx_Data==?8'bx111111x or Rx_Data==?8'b111111x;
  endproperty

  property Verify7; //Idle pattern generation, 11111111
    @(posedge Clk) disable iff (!Rst || Tx_FCSDone) !Tx_FCSDone[*10] ##0 !Rx_FrameError ##0 !Tx_ValidFrame[*10] |=>
     //##[0:8] Tx[*8];
        if($fell(Tx_FCSDone))
            ##8 Tx[*8]
        else
            $past(Tx) ##0 Tx[*7];  
  endproperty

  property Verify8; //Abort signal generated correctly and checked by Rx
    @(posedge Clk) disable iff (!Rst) $rose(Tx_AbortFrame) |=>  ##3 abort ##3 $rose(Rx_AbortSignal);
  endproperty 

  property verify9; //Aborting frame during transmission asserts Tx_AbortedTrans
    @(posedge Clk) disable iff (!Rst) $rose(Tx_AbortFrame) ##0 Tx_DataAvail |-> Tx_AbortedTrans;
  endproperty

  property verify10; //Abort pattern detected and Rx_AbortSignal generated properly
    @(posedge Clk) disable iff (!Rst) $stable(Rx_ValidFrame) ##0 $rose(Rx_AbortSignal) |-> prev_abort;
  endproperty

  property verify15; //Rx_Ready should indicate bytes in RX buffer are ready to be read
    @(posedge Clk) disable iff (!Rst) $rose(Rx_Ready) ##1 Rx_Ready |-> $fell(Rx_EoF);//$past(Rx_EoF) ##0 !Rx_EoF; 
  endproperty  

  property verify17;
    @(posedge Clk) disable iff (!Rst) $fell(Tx_DataAvail) |-> $past(Tx_Done, 1);
  endproperty


  property verify18;
    @(posedge Clk) disable iff (!Rst) $rose(Tx_Enable) ##2 Tx_FrameSize == 8'd126 |-> $past(Tx_Full, 2);
  endproperty



Receive_FlagDetect_Assert    :  assert property (Receive_FlagDetect) $display("PASS: Receive_FlagDetect");
                                  else begin $error("Flag sequence did not generate FlagDetect");
ErrCntAssertions++; end

correct_data_rxBuff_Drop_Assert    :  assert property (correct_data_rxBuff_Drop) $display("PASS: correct_data_rxBuff_Drop");
                                  else begin $error("Wrong data in rx buffer after Drop");
ErrCntAssertions++; end

correct_data_rxBuff_Abort_Assert    :  assert property (correct_data_rxBuff_Abort) $display("PASS: correct_data_rxBuff_Abort");
                                  else begin $error("Wrong data in rx buffer after Abort");
ErrCntAssertions++; end

Verify3_assert: 	assert property (Verify3) $display("PASS: RX status OK");
				                else begin $error("Fail: RX status not OK after transfer");
ErrCntAssertions++; end

Verify5_assert: 	assert property (Verify5) $display("PASS: Start and end frame inserted properly");
				                else begin $error("Startend frames not inserted");
ErrCntAssertions++; end
/*
Verify6_Insert_Assert: 	assert property (Verify6_insert) $display("PASS: inserted 0 after 5 consecutive ones");
				                else begin $error("No 0 inserted after 5 consecutive ones");
ErrCntAssertions++; end

Verify6_Remove_Assert: 	assert property (Verify6_remove) $display("PASS: removed 0 after 5 consecutive ones");
				                else begin $error("No 0 removed after 5 consecutive ones");
ErrCntAssertions++; end
*/
Verify7_assert: 	assert property (Verify7) /*$display("PASS: Idle pattern generated properly");*/
				                else begin $error("Idle pattern incorrectly generated");
ErrCntAssertions++; end

Verify8_assert: 	assert property (Verify8) $display("PASS: Abort pattern generated properly");
				                else begin $error("8: Abort pattern incorrectly generated");
ErrCntAssertions++; end

verify9_Assert    :  assert property (verify9) $display("PASS: Aborted trans asserted");
                                  else begin $error("Aborted trans not asserted");
ErrCntAssertions++; end

verify10_Assert    :  assert property (verify10) $display("PASS: Abort sequence recognised correctly");
                                  else begin $error("Abort sequence not recognised correctly");
ErrCntAssertions++; end

correct_data_rxBuff_Abort_Error    :  assert property (correct_data_rxBuff_Error) $display("PASS: correct_data_rxBuff_Error");
                                  else begin $error("Wrong data in rx buffer after FrameError");
ErrCntAssertions++; end

verify15_Assert    :  assert property (verify15) $display("PASS: Rx_Ready correctly indicates that Rx buffer is ready to be read");
                                  else begin $error("Rx_Ready is not ready to be read");
ErrCntAssertions++; end

verify17_Assert    :  assert property (verify17) $display("PASS: Entire buffer red for transmission, Tx_Done is high");
                                  else begin $error("Tx_Done not high after transmission");
ErrCntAssertions++; end

verify18_Assert    :  assert property (verify18) $display("PASS: Full buffer, Tx_Full is high");
                                  else begin $error("Full buffer and Tx_Full is not high");
ErrCntAssertions++; end



endmodule
