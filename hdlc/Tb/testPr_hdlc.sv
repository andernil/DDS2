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

  int num_loops = 3000;       //Number of times the random test should loop



  initial begin
    $display("*************************************************************");
    $display("%t - Starting Test Program", $time);
    $display("*************************************************************");

    init();
    //Tests:
    Verification1_Drop();
    random_loop();
    Rx_Random();
    random_input();
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

//Cover
covergroup hdlc_cg () @(posedge uin_hdlc.Clk);
   //
   //
   		dataIn: coverpoint uin_hdlc.DataIn {
   			bins DataIn[] = {[0:255]};
   		}
        Framesize: coverpoint uin_hdlc.Tx_FrameSize {
            bins FrameSizes[] = {[0:126]};
        }
        Tx_AbortedTrans: coverpoint uin_hdlc.Tx_AbortedTrans {
            bins Tx_not_Aborted = {0};
            bins Tx_Aborted = {1};
        }
        Tx_Full: coverpoint uin_hdlc.Tx_Full {
            bins Tx_not_Full = {0};
            bins Tx_Full = {1};
        }
        Tx_Done: coverpoint uin_hdlc.Tx_Done {
            bins Tx_not_Done = {0};
            bins Tx_Done = {1};
        }
        Rx_Overflow: coverpoint uin_hdlc.Rx_Overflow {
            bins Rx_no_Overflow = {0};
            bins Rx_Overflow = {1};
        }
        Rx_AbortSignal: coverpoint uin_hdlc.Rx_AbortSignal {
            bins Rx_not_Aborted = {0};
            bins Rx_Aborted = {1};
        }
        Rx_FrameError: coverpoint uin_hdlc.Rx_FrameError {
            bins Rx_no_FrameError = {0};
            bins Rx_FrameError = {1};
        }
		dataIn_and_FrameSize: cross dataIn, Framesize;

    	endgroup
  //Instantiate covergroup
  hdlc_cg hdlc_cg_inst = new();

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
      WriteAddress(TX_BUFF, 'h00);                  //Write the data to register 1
      WriteAddress(TX_BUFF, 'h71);                  //Write the data to register 1
      WriteAddress(TX_BUFF, 'h9b);                  //Hvis checksummen har 5 enere setter Tx inn en 0, men Rx fjerner den ikke, så det blir non-aligned data og FrameError hos Rx.
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

    size = $urandom_range(0, 129);
    //Generate random data and write it to TX_buffer
    for (int i = 0; i < size; i++) begin
        Data = $urandom();
        WriteAddress(TX_BUFF, Data);
    end
    // $display("%d bytes of data written to TX_BUFF", size);
    //Initiate transfer
    WriteAddress(TX_SC, TX_ENABLE);
    for(int i = 0; i < 2200; i=i+1) begin
        Data = $urandom();
        if(i==1000 && Data==127) begin
            WriteAddress(3'b000, 8'b00000100);
        end
        @(posedge uin_hdlc.Clk);
        uin_hdlc.Rx = uin_hdlc.Tx;
      //#20;
	end
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

  size = $urandom_range(128, 130);

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

endprogram
