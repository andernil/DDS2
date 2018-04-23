//////////////////////////////////////////////////
// Title:   testPr_hdlc
// Author:
// Date:
//////////////////////////////////////////////////


program testPr_hdlc(
  in_hdlc uin_hdlc
);

// class data_hdlc;
//   rand logic [0:7] inputValue;
//
//   task get(ref logic [0:7] inputValue);
//     inputValue = inputValue;
//   endtask
// endclass: data_hdlc;
  int TbErrorCnt;
  parameter TX_SC   = 3'b000;
  parameter TX_BUFF = 3'b001;
  parameter RX_SC   = 3'b010;
  parameter RX_BUFF = 3'b011;
  parameter RX_LEN  = 3'b100;

  parameter TX_DONE         = 8'b0000_0001;
  parameter TX_ENABLE       = 8'b0000_0010;
  parameter TX_ABORTFRAME   = 8'b0000_0100;
  parameter TX_ABORTEDTRANS = 8'b0000_1000;
  parameter TX_FULL         = 8'b0001_0000;

  parameter RX_READY        = 8'b0000_0001;
  parameter RX_DROP         = 8'b0000_0010;
  parameter RX_FRAMEERROR   = 8'b0000_0100;
  parameter RX_ABORTSIGNAL  = 8'b0000_1000;
  parameter RX_OVERFLOW     = 8'b0001_0000;
  parameter RX_FCSEN        = 8'b0010_0000;

  parameter FLAG  = 8'b0111_1110;
  parameter ABORT = 8'b0111_1111;

  int num_loops = 10;       //Number of times the random test should loop
    


  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    init();
    //ReceiveTor();
    //Tests:
    //Receive();
    //Verification1_Drop();
    //Verification1_Abort();
    //Verification1_Error();
    //Verification17();
    //Verification9();
    //Verification6();
    //Verification8();
    random_loop;
    $display("*************************************************************");
    $display("%t - Finishing Test Program", $time);
    $display("*************************************************************");
    $stop;
  end

  final begin

    $display("*********************************");
    $display("*                               *");
    $display("* \tAssertion Errors: %0d\t  *", TbErrorCnt + uin_hdlc.ErrCntAssertions);
    $display("*                               *");
    $display("*********************************");

  end

  task init();
    uin_hdlc.Clk         =   1'b0;
    uin_hdlc.Rst         =   1'b0;
    uin_hdlc.Rx          =   1'b0;
    uin_hdlc.RxEN        =   1'b1;
    uin_hdlc.TxEN        =   1'b1;

    TbErrorCnt = 0;

    #1000ns;
    uin_hdlc.Rst         =   1'b1;
  endtask

//Cover
covergroup hdlc_cg () @(posedge uin_hdlc.Clk);
   //
   //
   		dataIn: coverpoint uin_hdlc.DataIn {
   			option.auto_bin_max = 256;
   		}
        Framesize: coverpoint uin_hdlc.Tx_FrameSize {
            option.auto_bin_max = 128;
            bins FrameSize_OverFlow = {128,255};
        }
        Tx_AbortedTrans: coverpoint uin_hdlc.Tx_AbortedTrans {
            bins tx_not_aborted = {0};
            bins tx_aborted = {1};
        }
        Tx_Done: coverpoint uin_hdlc.Tx_Done {
            bins tx_not_done = {0};
            bins tx_done = {1};
        }
        Rx_Overflow: coverpoint uin_hdlc.Rx_Overflow {
            bins rx_no_overflow = {0};
            bins rx_overflow = {1};
        }
        Rx_AbortSignal: coverpoint uin_hdlc.Rx_AbortSignal {
            bins rx_not_aborted = {0};
            bins rx_aborted = {1};
        }
        Rx_FrameError: coverpoint uin_hdlc.Rx_FrameError {
            bins rx_no_frameerror = {0};
            bins rx_frameerror = {1};
        }
   // 		coverpoint data_out {
   // 			bins Zero = {0};
   // 			bins Small = {[1:50]};
   // 			bins Hunds = {[100:200]};
   // 			bins Large = {[200:$]};
   // 			bins others[] = default;
   // 		}
   // 		A: coverpoint data_in;
   // 		B: coverpoint b;
   // 		AB: cross A, B;
    	endgroup
   //
   // //Initialize your covergroup here
        hdlc_cg hdlc_cg_inst = new();
   //
   // //Sample covergroup here
 //   	always @(negedge uin_hdlc.Clk) begin
  //  		hdlc_cg_inst.sample();
   //     end
//endgroup

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    uin_hdlc.Rx          = uin_hdlc.Tx; //Added to keep transfering Tx to Rx during write.
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx          = uin_hdlc.Tx; //Added to keep transfering Tx to Rx during write.
    uin_hdlc.WriteEnable = 1'b0;
  endtask

  task ReadAddress(input logic [2:0] Address ,output logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address    = Address;
    uin_hdlc.ReadEnable = 1'b1;
    #100ns;
    Data                = uin_hdlc.DataOut;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.ReadEnable = 1'b0;
  endtask

  task random_loop();

    for(int i = 0; i < num_loops; i=i+1) begin
        random_input();
    end
  endtask;


  task Receive();
    logic [7:0] ReadData;

    //RX flag
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
    uin_hdlc.Address = 1'h2;
@(posedge uin_hdlc.Clk);
    uin_hdlc.Address = 1'h2;

    repeat(8)
      @(posedge uin_hdlc.Clk);

    ReadAddress(3'b010 , ReadData);
    $display("Rx_SC=%h", ReadData);

  endtask

  task Verification9();
  logic [7:0] writeData;
  logic [7:0] dataIn;
  logic [7:0] transmitData;
  transmitData = 8'b0000000;
  dataIn = 8'b10101010;
  writeData = 8'b00000100;
  for(int i = 0; i < 126; i=i+1) begin
    WriteAddress(TX_BUFF, dataIn);
  end
  WriteAddress(3'b000, transmitData);
  WriteAddress(3'b000, 8'b0000000);
  for(int i = 0; i < 30; i=i+1) begin
      @(posedge uin_hdlc.Clk);
    //#20;
  end
  WriteAddress(3'b000, writeData);
  for(int i = 0; i < 12600; i=i+1) begin
      @(posedge uin_hdlc.Clk);
  end
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  endtask

  task Verification17();
    // data_hdlc inputValue;
    logic [7:0] readData;
    logic [7:0] dataIn;
    logic [7:0] transmitData;
    dataIn = 8'b10101010;
    transmitData = 8'b0000010;
    for(int i = 0; i < 126; i=i+1) begin
      WriteAddress(3'b001, dataIn);
      //#20;
		end
    WriteAddress(3'b000, transmitData);
    for(int i = 0; i < 12600; i=i+1) begin
        @(posedge uin_hdlc.Clk);
      //#20;
		end
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    ReadAddress(3'b000, readData);
    $display("Tx_SC=%b", readData);

  endtask

  task Verification6();
    // data_hdlc inputValue;
    logic [7:0] readData;
    logic [7:0] dataIn;
    logic [7:0] transmitData;
    dataIn = 255;
    transmitData = 8'b0000010;
    for(int j = 0; j < 40; j=j+1) begin
      //#20;
        ReadAddress(3'b001, readData);
        WriteAddress(3'b001, dataIn);
                uin_hdlc.Rx = uin_hdlc.Tx;
	end
    WriteAddress(3'b001, dataIn);
    
    WriteAddress(3'b000, dataIn);
    repeat(10)
        @(posedge uin_hdlc.Clk)
    for(int j = 0; j < 40; j=j+1) begin
      //#20;
            uin_hdlc.Rx = uin_hdlc.Tx;

	end

    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    ReadAddress(3'b001, readData);
    $display("Tx_SC=%b", readData);

  endtask

 task Verification8();      //Used for generating increasing data_in and aborting at a certain point in time, if desired.
    // data_hdlc inputValue;
    logic [7:0] readData;
    logic [7:0] dataIn;
    logic [7:0] transmitData;
    logic [7:0] receiveData;
    dataIn = 8'b10101010;
    transmitData = 8'b0000010;
    receiveData = 8'b0000010;
    for(int i = 0; i < 1; i=i+1) begin
      WriteAddress(TX_BUFF, 255);                  //Write the data to register 1
		end
    WriteAddress(TX_SC, transmitData);         //Start transfer
    for(int i = 0; i < 2500; i=i+1) begin
       /* if(i==1500) begin
            transmitData = 8'b00000100;
            WriteAddress(3'b000, transmitData);
        end*/
        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = uin_hdlc.Tx;
      //#20;
	end
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    ReadAddress(RX_SC, readData);
    //$display("Rx_SC=%b", readData);

  endtask

  task random_input();
    automatic logic[7:0] Data = '0;
    logic [7:0] size;

    size = $urandom_range(3, 126); 
    //Generate random data and write it to TX_buffer
    for (int i = 0; i < size; i++) begin
        Data = $urandom();
        WriteAddress(TX_BUFF, Data);
        hdlc_cg_inst.sample();
    end
    $display("%d bytes of data written to TX_BUFF", size);
    //Initiate transfer
    WriteAddress(TX_SC, TX_ENABLE);  
    for(int i = 0; i < 2200; i=i+1) begin
       /* if(i==1500) begin
            transmitData = 8'b00000100;
            WriteAddress(3'b000, transmitData);
        end*/
        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = uin_hdlc.Tx;
      //#20;
	end
    

  endtask


  task Verification1_Error();
    logic [7:0] readData;
    logic [7:0] writeData;

    writeData = 8'b00100000;
    WriteAddress(3'b010, writeData);

  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);


// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);

// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);

//CRC Code
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);


uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
//ABORT FRAME
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);

  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  ReadAddress(3'b011, readData);
  $display("Rx_SC=%b", readData);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  ReadAddress(3'b011, readData);
  $display("Rx_Data=%b", readData);
  endtask


  task Verification1_Drop();


    logic [7:0] readData;
    logic [7:0] writeData;

  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);


uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);

//ABORT FRAME
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);


  writeData = 8'b00000000;
  WriteAddress(3'b010, writeData);
  ReadAddress(3'b010, readData);
  $display("Rx_SC=%b", readData);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);


  uin_hdlc.Address     = 3'b010;
  uin_hdlc.WriteEnable = 1'b1;
  uin_hdlc.DataIn      = 8'b00000010;
  @(posedge uin_hdlc.Clk);
  ReadAddress(3'b011, readData);
  $display("Rx_Data=%b", readData);
  endtask


  task Verification1_Abort();


    logic [7:0] readData;
    logic [7:0] writeData;

  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b1;
  @(posedge uin_hdlc.Clk);
  uin_hdlc.Rx = 1'b0;
  @(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);

uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);


uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);

// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b1;
// @(posedge uin_hdlc.Clk);
// uin_hdlc.Rx = 1'b0;
// @(posedge uin_hdlc.Clk);

//ABORT FRAME
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b1;
@(posedge uin_hdlc.Clk);
uin_hdlc.Rx = 1'b0;
@(posedge uin_hdlc.Clk);


  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);
  @(posedge uin_hdlc.Clk);

  ReadAddress(3'b011, readData);
  $display("Rx_Data=%b", readData);
  endtask

  task ReceiveTor();
    logic [7:0] ReadData;
    logic [7:0] ReadLen;
  automatic logic [4:0][7:0] shortmessage = '0;
  automatic logic [135:0][7:0] Data = '0;


   WriteAddress(RX_SC,RX_FCSEN);

/*
	Rx_Byte(FLAG);
	Rx_Byte(ABORT);
*/
	$display("%t New remove zero message ================", $time);
    uin_hdlc.Rx = 1'b1;
	    repeat(2)
	      @(posedge uin_hdlc.Clk);
	Rx_Byte(FLAG);

/////////////////////////////////
//Data
//	Rx_Byte('h2D);
//	Rx_Byte('h2D);
//Checksum
//	Rx_Byte('hDD);
//	Rx_Byte('h4D);
////////////////////////////////

	//Data
	Rx_Byte('h2D);
	//7E
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;	//Will be removed
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b1;
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Rx = 1'b0;
    @(posedge uin_hdlc.Clk);

	//Checksum
	Rx_Byte('h9D);
	Rx_Byte('h70);
	
	Rx_Byte(FLAG);
    uin_hdlc.Rx = 1'b1;


	$display("%t New remove zero message ================", $time);

	shortmessage[0] = 'h71;
	shortmessage[1] = 'h9B;

	//shortmessage[0] = 8'b11111000;
	//shortmessage[1] = 8'b01001000;


	CalculateFCS(shortmessage, 2, {shortmessage[3],shortmessage[2]});
    Rx_Byte(FLAG);
    Rx_multisend(shortmessage,4);

    Rx_Byte(FLAG);
    uin_hdlc.Rx = 1'b1;
/*
	$display("%t New Overflow message ================", $time);

  for (int i = 0; i < 134; i++) begin
  	Data[i] = $urandom();
  end
   Rx_Byte(FLAG);
   Rx_multisend(Data,130);
   Rx_Byte(FLAG);

*/

  //Loop for reciving lots of valid random data
  for (int i = 0; i < num_loops; i++) begin
	    $display("%t New random message ================", $time);

	    Rx_Random();
	    uin_hdlc.Rx = 1'b1;

	    repeat(8)
	      @(posedge uin_hdlc.Clk);

	    ReadAddress(RX_SC, ReadData);
	    $display("Rx_SC=%b", ReadData);


	    ReadAddress(RX_LEN , ReadLen);
	    $display("Rx_Len=%d", ReadLen);

	  for (int i = 0; i < ReadLen; i++) begin
   		ReadAddress(RX_BUFF , ReadData);
	  end

  end

    uin_hdlc.Rx = 1'b1;

    repeat(8)
      @(posedge uin_hdlc.Clk);
    ReadAddress(RX_SC, ReadData);
    $display("Rx_SC=%b", ReadData);


    ReadAddress(RX_LEN , ReadData);
    $display("Rx_Len=%h", ReadData);

    ReadAddress(RX_BUFF , ReadData);
    $display("Rx_D =%h", ReadData);
    ReadAddress(RX_BUFF , ReadData);
    $display("Rx_D =%b", ReadData);

    ReadAddress(RX_BUFF , ReadData);
    $display("Rx_D =%b", ReadData);

  endtask

  task Rx_Byte(input logic [7:0] Data);
  for (int i = 0; i < 8; i++) begin
        uin_hdlc.Rx = Data[i];
      @(posedge uin_hdlc.Clk);
  end
  endtask

  task Rx_Random();
  automatic logic [127:0][7:0] Data = '0;
  logic [7:0] size;
  logic        [15:0] FCSbytes;

  size = $urandom_range(1, 140);

  for (int i = 0; i < size; i++) begin
  	Data[i] = $urandom();
  end

  CalculateFCS(Data, size, {Data[size+1],Data[size]});

  size = size + 2;
  Rx_Byte(FLAG);
  Rx_multisend(Data,size);
  Rx_Byte(FLAG);
  endtask

  task Rx_multisend(input logic [132:0][7:0] data,
                       input int             size);
    automatic logic      [4:0] zeroPadding  = '0;

    for (int i = 0; i < size; i++) begin
      for (int j = 0; j < 8; j++) begin
        if (&zeroPadding) begin
          uin_hdlc.Rx      = 1'b0;
          @(posedge uin_hdlc.Clk);
          zeroPadding      = zeroPadding >> 1;
          zeroPadding[4]   = 0;
        end
        zeroPadding      = zeroPadding >> 1;
        zeroPadding[4]   = data[i][j];
        uin_hdlc.Rx      = data[i][j];
        @(posedge uin_hdlc.Clk);
      end
    end
  endtask

  task CalculateFCS(input  logic [127:0][7:0]  data, 
                    input  logic [7:0]         size, 
                    output logic [15:0]        FCSbytes );

    logic [23:0] tempStore;
    tempStore[7:0]  = data[0];
    tempStore[15:8] = data[1];

    for (int i = 2; i < size + 2; i++) begin
      tempStore[23:16] = data[i];
      for (int j = 0; j < 8; j++) begin
        tempStore[16] = tempStore[16] ^ tempStore[0];
        tempStore[14] = tempStore[14] ^ tempStore[0];
        tempStore[1]  = tempStore[1]  ^ tempStore[0];
        tempStore[0]  = tempStore[0]  ^ tempStore[0];
        tempStore = tempStore >> 1;
      end
    end
    FCSbytes = tempStore[15:0];
  endtask



endprogram
