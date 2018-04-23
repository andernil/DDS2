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
  input logic RxD,
  input logic Rx_EoF,
  input logic Rx_FlagDetect,
  input logic Rx_Ready,
  input logic[7:0] DataOut,
  input logic[7:0] DataIn,
  input logic[2:0]  Address,
  input logic WriteEnable,
  input logic ReadEnable,
  input logic[7:0] Rx_Data,
  input logic Rx_RdBuff,
  input logic Rx_Drop,
  input logic Rx_FCSen,
  input logic Rx_AbortSignal,
  input logic Rx_NewByte,
  input logic Rx_FrameError,
  input logic Rx_ValidFrame,
  input logic Rx_Overflow,
  input logic Rx_StartFCS,
  input logic Rx_WrBuff,
  input logic[7:0] Rx_FrameSize,
  input logic Tx,
  input logic Tx_NewByte,
  input logic Tx_DataAvail,
  input logic Tx_Done,
  input logic Tx_Full,
  input logic[7:0] Tx_FrameSize,
  input logic[7:0] Tx_Data,
  input logic TxEN,
  input logic[127:0][7:0] Tx_DataArray,
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

  property Verify1; //Correct data in RX buffer according to RX input
    logic[127*10:0] Rx_Store;
    logic[127:0][7:0] Rx_DataArray;
    int i = 0;
    int j = 0;
    @(posedge Clk) disable iff (!Rst) $rose(Rx_ValidFrame) ##7 (##0 (Rx_ValidFrame, Rx_Store[i] = $past(RxD,7), i++) [*2:10] ##0 (Rx_WrBuff, Rx_DataArray[j] = Rx_Data,j++))[*1:$] ##3 ($fell(Rx_ValidFrame)) |-> ##3 in_out_equal_rx(Rx_DataArray, Rx_Store, Rx_FrameSize);
  endproperty

function bit in_out_equal_rx(logic [127:0][7:0]Rx_Data, logic [127*10:0]Rx, int size);
	automatic int seq = 0;
	automatic int rx_cnt = 0;
	automatic bit zero_detected = 0;
	automatic bit pass = 1;
    automatic int unroll_count = 0;
    automatic int size_byte = 0;
	automatic logic [(128*8)-1:0]Rx_Data_Unrolled  = 0;
    //0 til framesize ytterst, inni fra 0 til 7
    for(int i = 0; i < size; i++) begin
        for(int j = 0; j < 8; j++) begin
            Rx_Data_Unrolled[unroll_count] = Rx_Data[i][j];
            unroll_count += 1;
        end
    end
    size_byte = size*8;
	for(int i = 0; i < (size_byte); i++) begin
		if(Rx_Data_Unrolled[rx_cnt] == 1) begin
			seq += 1;
		end else begin
			seq = 0;
		end
		if(zero_detected == 1) begin
			pass &= (Rx[i] == 0);
//            $display("Pass: %b, Rx[i]: %b, i: %d",pass,Rx[i],i);
            zero_detected = 0;
            size_byte++;
            seq = 0;
		end else begin
//            $display("Pass: %b, Rx_Data_Unrolled[rx_cnt]: %b, Rx[i]: %b, i: %d",pass,Rx_Data_Unrolled[rx_cnt],Rx[i],i);
			pass &= (Rx[i] == Rx_Data_Unrolled[rx_cnt]);
			rx_cnt += 1;
		end
		if(seq == 5) begin
			zero_detected = 1;
		end
	end
//    $display("1: %b", Rx[511:0]);
//    $display("2: %b", Rx_Data_Unrolled[511:0]);
//    $display("Size: %d", size_byte);
	return pass;
endfunction;

  property Verify3; //Correct bits set in Rx status/control-register after receiving frame
    @(posedge Clk) disable iff (!Rst) $rose(Rx_EoF) |->
    if(Rx_AbortSignal)
        (##0 !Rx_Overflow ##0 Rx_AbortSignal ##0 !Rx_FrameError ##1 !Rx_Ready, $display("Aborted frame at: ",$time))
    else if (Rx_Overflow)
        (##0 Rx_Overflow ##0 !Rx_AbortSignal ##0 !Rx_FrameError ##0 Rx_Ready, $display("Overflow at: ",$time))
    else if (Rx_FrameError)
        (##0 !Rx_Overflow ##0 !Rx_AbortSignal ##0 Rx_FrameError ##0 !Rx_Ready, $display("Frame error at: ",$time))
    else
        ##0 !Rx_Overflow ##0 !Rx_AbortSignal ##0 !Rx_FrameError ##0 Rx_Ready;
  endproperty

  property Verify4; //Tx output is correct based on Tx_buffer
    logic[127*10:0] Tx_Store;
    logic[127:0][7:0] Tx_DataArray_Log;
    int i = 0;
    @(posedge Clk) disable iff (!Rst || Tx_AbortedTrans) ($rose(Tx_ValidFrame), Tx_DataArray_Log = Tx_DataArray) ##10 (##0 (Tx_ValidFrame, Tx_Store[i] = Tx, i++))[*1:$] ##1 ($fell(Tx_ValidFrame)) |-> in_out_equal_tx(Tx_DataArray_Log, Tx_Store, Tx_FrameSize);
  endproperty

//Function to check if Tx_DataArray and Tx is correct in regards to transfer and zero insertion
function bit in_out_equal_tx(logic [127:0][7:0]Tx_Data, logic [127*10:0]Tx, int size); 
	automatic int seq = 0;
	automatic int tx_cnt = 0;
	automatic bit zero_detected = 0;
	automatic bit pass = 1;
    automatic int unroll_count = 0;
	automatic logic [(128*8)-1:0]Tx_Data_Unrolled  = 0;

    for(int i = 0; i < size; i++) begin  //Unroll Tx_Data to one long array
        for(int j = 0; j < 8; j++) begin
            Tx_Data_Unrolled[unroll_count] = Tx_Data[i][j];
            unroll_count += 1;
        end
    end
    size=size*8; //Byte to bit size
	for(int i = 0; i < size; i++) begin //Check bit for bit if the data matches
		if(Tx[i] == 1) begin
			seq += 1;
		end else begin
			seq = 0;
		end
		if(zero_detected == 1) begin
			pass &= (Tx[i] == 0);
            zero_detected = 0;
            size++;
            //$display("Pass: %b, Tx[i]: %b, i: %d",pass,Tx[i],i);
		end else begin
			pass &= (Tx[i] == Tx_Data_Unrolled[tx_cnt]);
			tx_cnt += 1;
            //$display("Pass: %b, Tx_Data_Unrolled[tx_cnt]: %b, Tx[i]: %b, i: %d",pass,Tx_Data_Unrolled[tx_cnt],Tx[i],i);
		end
		if(seq == 5) begin
			zero_detected = 1;
            seq = 0;
		end
	end
//    $display("1: %b", Tx[255:0]);
//    $display("2: %b", Tx_Data_Unrolled[255:0]);
	return pass;
endfunction;


  property Verify5; //Start and end frame generation, 01111110
    @(posedge Clk) disable iff (!Rst) !$stable(Tx_ValidFrame) ##0 $past(!Tx_AbortFrame,2)|-> ##[0:2] startendframe;
  endproperty

  property Verify6_insert; //Zero insert
    @(posedge Clk) disable iff (!Rst || !Tx_ValidFrame ) Tx_NewByte ##1 (Tx_Data==?8'bxx111111 or Tx_Data==?8'bx111111x or Tx_Data==?8'b111111xx or (Tx_Data==?8'b1xxxxxxx ##1 Tx_Data==?8'bxxx11111) or
    (Tx_Data==?8'b11xxxxxx ##1 Tx_Data==?8'bxxxx1111) or (Tx_Data==?8'b111xxxxx ##1 Tx_Data==?8'bxxxxx111) or (Tx_Data==?8'b1111xxxx ##1 Tx_Data==?8'bxxxxxx11) or (Tx_Data==?8'b11111xxx ##1 Tx_Data==?8'bxxxxxxx1))
    ##[24:35] Tx[*5] |=> !Tx;
  endproperty

  property Verify6_remove; //Zero removal
    logic a;
    reg [7:0] data_RX;
    @(posedge Clk) disable iff (!Rst|| !Tx_ValidFrame) (($rose(Rx) ##1 Rx[*4] ##1 !Rx ##1 (Rx==1 or Rx==0)), a = Rx) |->  ##13 (Rx_Data==?{2'bxx, a, 5'b11111} or Rx_Data==?{1'bx, a, 6'b11111x} or Rx_Data==?{a, 7'b11111xx} or (Rx_Data==?8'b1xxxxxxx ##8 Rx_Data==?{3'bxxx, a, 4'b1111}) or
     (Rx_Data==?8'b11xxxxxx ##8 Rx_Data==?{4'bxxxx, a, 3'b111}) or (Rx_Data==?8'b111xxxxx ##8 Rx_Data==?{5'bxxxxx, a, 2'b11}) or (Rx_Data==?8'b1111xxxx ##8 Rx_Data==?{6'bxxxxxx, a, 1'b1}) or (Rx_Data==?8'b11111xxx ##8 Rx_Data==?{7'bxxxxxxx, a}));
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
    @(posedge Clk) disable iff (!Rst) $rose(Tx_AbortFrame) ##0 Tx_ValidFrame |=>  ##3 abort ##3 $rose(Rx_AbortSignal);
  endproperty

  property verify9; //Aborting frame during transmission asserts Tx_AbortedTrans
    @(posedge Clk) disable iff (!Rst) $rose(Tx_AbortFrame) ##0 Tx_DataAvail |=> ##1 $rose(Tx_AbortedTrans);
  endproperty

  property verify10; //Abort pattern detected and Rx_AbortSignal generated properly
    @(posedge Clk) disable iff (!Rst) $stable(Rx_ValidFrame) ##0 $rose(Rx_AbortSignal) |-> prev_abort;
  endproperty

  property verify11_generate; //Check if CRC generation is correct
	logic [127:0] [7:0] Tx_Buff;
  	logic [7:0] framesize;  	
    @(posedge Clk) disable iff (!Rst || Tx_AbortedTrans) ($rose(Tx_FCSDone),Tx_Buff = Tx_DataArray,framesize = Tx_FrameSize) ##0 first_match(##[0:$] Tx_WriteFCS) 
    ##[1:10] (Tx_WriteFCS,Tx_Buff[framesize]=Tx_Data,framesize++) ##1 (1'b1,Tx_Buff[framesize]=Tx_Data)
     |-> checkCRC(Tx_Buff,framesize+1,1'b1);
  endproperty

  property verify11_check; //Check if CRC is checked correctly, and that Rx_FrameError is set if the check fails.
  logic [127:0] [7:0] tempBuffer = '0;
  int framesize = 0;
   @(posedge Clk) disable iff (!Rst) Rx_flag ##[18:19] Rx_NewByte ##0 (##[7:9] (Rx_NewByte,tempBuffer[framesize]=Rx_Data, framesize++)) [*1:128] ##0 Rx_FlagDetect  
   |-> ##6 (1,tempBuffer[framesize]=Rx_Data, framesize++) ##0 (Rx_FrameError == !checkCRC(tempBuffer,framesize,Rx_FCSen));
  endproperty


  function automatic logic checkCRC([127:0] [7:0] arrayA, int size, logic FCSen); //Function for performing CRC-check
    automatic logic noError = 1'b1;
    logic [15:0] tempCRC;
    logic [23:0] tempStore;
//    $display("InArray =%h", arrayA[10:0]);
//    $display("Framesize =%d", size);

	tempCRC = {arrayA[size-1],arrayA[size-2]};
	arrayA[size-1] = '0;
	arrayA[size-2] = '0;

    tempStore[7:0]  = arrayA[0];
    tempStore[15:8] = arrayA[1];

    for (int i = 2; i < size; i++) begin
      tempStore[23:16] = arrayA[i];
      for (int j = 0; j < 8; j++) begin
        tempStore[16] = tempStore[16] ^ tempStore[0];
        tempStore[14] = tempStore[14] ^ tempStore[0];
        tempStore[1]  = tempStore[1]  ^ tempStore[0];
        tempStore[0]  = tempStore[0]  ^ tempStore[0];
        tempStore = tempStore >> 1;
      end
    end
//    $display("time = %t", $time);


//    $display("tempCRC =%h", tempCRC);
//    $display("calcCRC =%h", tempStore[15:0]);

   if (FCSen) begin
//    $display("Return =%b", tempCRC == tempStore[15:0]);

   	 return (tempCRC == tempStore[15:0]);

     end else begin
//    $display("Return force = 1");

   	  return 1'b1;
    end
  endfunction


  property verify12; //Check that Rx_EoF is generated when a whole frame has been received
    @(posedge Clk) disable iff (!Rst) $rose(Rx_FlagDetect) ##8 $rose(Rx_ValidFrame) ##[1:$] $fell(Rx_ValidFrame) |-> !Rx_EoF ##1 Rx_EoF ##1 !Rx_EoF;
  endproperty

  property verify13; //Rx_Overflow is asserted when receiving more than 128 bytes of data, [->x] = consecutive sequence
    @(posedge Clk) disable iff (!Rst || Rx_EoF) $fell(Rx_StartFCS) ##6 (Rx_NewByte)[->129] |=> Rx_Overflow;
  endproperty

  property verify14; //Check that Rx_FrameSize is equal to the number of bytes received during the frame
  int bytecount = 0;
    @(posedge Clk) disable iff (!Rst) $rose(Rx_ValidFrame) ##0 (##[7:9]$rose(Rx_NewByte),bytecount++)[*1:127] ##4 Rx_EoF |-> ##5 Rx_FrameSize == (bytecount-2);
  endproperty

  property verify15; //Rx_Ready should indicate bytes in RX buffer are ready to be read
    @(posedge Clk) disable iff (!Rst) $rose(Rx_Ready) ##1 Rx_Ready |-> $fell(Rx_EoF);
  endproperty
  
  property verify16; //Check if non-byte aligned transfer. During normal operation, Rx_Newbyte and Rx_FlagDetect are triggered simultaneously.
   @(posedge Clk) disable iff (!Rst)  Rx_NewByte ##[1:7] Rx_FlagDetect
   |-> ##2 $rose(Rx_FrameError);
  endproperty


  property verify17; //Tx_Done should be asserted when the entire TX buffer has been read for transmission
    @(posedge Clk) disable iff (!Rst) $fell(Tx_DataAvail) |-> $past(Tx_Done, 1);
  endproperty

  property verify18; //Tx_Full should be asserted after writing 126 or more bytes to Tx buffer
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

Verify1_assert: 	assert property (Verify1)  $display("PASS: Rx out is correct based on Rx_Buffer");
				                else begin $error("Fail: Rx doesn't match Rx_buffer");
ErrCntAssertions++; end

Verify3_assert: 	assert property (Verify3)  $display("PASS: RX status OK");
				                else begin $error("Fail: RX status not OK after transfer");
ErrCntAssertions++; end

Verify4_assert: 	assert property (Verify4)  $display("PASS: Tx out is correct based on Tx_Buffer");
				                else begin $error("Fail: Tx doesn't match Tx_buffer");
ErrCntAssertions++; end

Verify5_assert: 	assert property (Verify5) $display("PASS: Start and end frame inserted properly");
				                else begin $error("Startend frames not inserted");
ErrCntAssertions++; end

Verify6_Insert_Assert: 	assert property (Verify6_insert) $display("PASS: inserted 0 after 5 consecutive ones");
				                else begin $error("No 0 inserted after 5 consecutive ones");
ErrCntAssertions++; end

Verify6_Remove_Assert: 	assert property (Verify6_remove) $display("PASS: removed 0 after 5 consecutive ones");
				                else begin $error("No 0 removed after 5 consecutive ones");
ErrCntAssertions++; end

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

verify11_generate_Assert    :  assert property (verify11_generate) $display("PASS: CRC generated properly");
                                  else begin $error("CRC not generated properly");
ErrCntAssertions++; end

verify11_check_Assert    :  assert property (verify11_check) $display("PASS: CRC checked properly");
                                  else begin $error("CRC not checked properly");
ErrCntAssertions++; end


verify12_Assert    :  assert property (verify12) $display("PASS: Rx_EoF generated correctly");
                                  else begin $error("Rx_EoF not generated properly");
ErrCntAssertions++; end

verify13_Assert    :  assert property (verify13) $display("PASS: Rx_Overflow asserted correctly");
                                  else begin $error("Rx_Overflow not asserted after 128 bytes of data");
ErrCntAssertions++; end

verify14_Assert    :  assert property (verify14) $display("PASS: Framesize match");
                                  else begin $error("Framesize doesn't match");
ErrCntAssertions++; end

correct_data_rxBuff_Abort_Error    :  assert property (correct_data_rxBuff_Error) $display("PASS: correct_data_rxBuff_Error");
                                  else begin $error("Wrong data in rx buffer after FrameError");
ErrCntAssertions++; end

verify15_Assert    :  assert property (verify15) $display("PASS: Rx_Ready correctly indicates that Rx buffer is ready to be read");
                                  else begin $error("Rx_Ready is not ready to be read");
ErrCntAssertions++; end

verify16_Assert    :  assert property (verify16) $display("PASS: Non-byte aligned data transfer, Rx_FrameError asserted properly");
                                  else begin $error("Non-byte aligned data transfer but wasn't reported by Rx_FrameError");
ErrCntAssertions++; end

verify17_Assert    :  assert property (verify17) $display("PASS: Entire buffer red for transmission, Tx_Done is high");
                                  else begin $error("Tx_Done not high after transmission");
ErrCntAssertions++; end

verify18_Assert    :  assert property (verify18) $display("PASS: Full buffer, Tx_Full is high");
                                  else begin $error("Full buffer and Tx_Full is not high");
ErrCntAssertions++; end



endmodule
