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
  



  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    init();

    //Tests:
    //Receive();
    //Verification1_Drop();
    //Verification1_Abort();
    //Verification1_Error();
    //Verification17();
    //Verification9();
    //Verification6();
    Verification8();
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

  task WriteAddress(input logic [2:0] Address ,input logic [7:0] Data);
    @(posedge uin_hdlc.Clk);
    uin_hdlc.Address     = Address;
    uin_hdlc.WriteEnable = 1'b1;
    uin_hdlc.DataIn      = Data;
    @(posedge uin_hdlc.Clk);
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
    WriteAddress(3'b001, dataIn);
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

 task Verification8();
    // data_hdlc inputValue;
    logic [7:0] readData;
    logic [7:0] dataIn;
    logic [7:0] transmitData;
    logic [7:0] receiveData;
    dataIn = 8'b10101010;
    transmitData = 8'b0000010;
    receiveData = 8'b0000010;
    for(int i = 0; i < 126; i=i+1) begin
      WriteAddress(3'b001, i);                  //Write the data to register 1
		end
    WriteAddress(3'b000, transmitData);         //Start transfer
    for(int i = 0; i < 2500; i=i+1) begin
        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = uin_hdlc.Tx;
      //#20;
		end
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    @(posedge uin_hdlc.Clk);
    ReadAddress(3'b000, readData);
    $display("Tx_SC=%b", readData);

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

endprogram
