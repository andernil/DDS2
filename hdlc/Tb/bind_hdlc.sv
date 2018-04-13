//////////////////////////////////////////////////
// Title:   bind_hdlc
// Author:
// Date:
//////////////////////////////////////////////////

module bind_hdlc ();

  bind test_hdlc assertions_hdlc u_assertion_bind(
    .ErrCntAssertions(uin_hdlc.ErrCntAssertions),
    .Clk(uin_hdlc.Clk),
    .Rst(uin_hdlc.Rst),
    .Rx(uin_hdlc.Rx),
    .Rx_FlagDetect(uin_hdlc.Rx_FlagDetect),
    .Rx_Ready(uin_hdlc_Rx_Ready),
    .DataOut(uin_hdlc.DataOut),
    .DataIn(uin_hdlc.DataIn),
    .Address(uin_hdlc.Address),
    .WriteEnable(uin_hdlc.WriteEnable),
    .ReadEnable(uin_hdlc.ReadEnable),
    .Rx_Drop(uin_hdlc.Rx_Drop),
    .Rx_AbortSignal(uin_hdlc.Rx_AbortSignal),
    .Rx_FrameError(uin_hdlc.Rx_FrameError),
    .Tx(uin_hdlc.Tx),
    .Tx_DataAvail(uin_hdlc.Tx_DataAvail),
    .Tx_Done(uin_hdlc.Tx_Done),
    .Tx_Full(uin_hdlc.Tx_Full),
    .Tx_FrameSize(uin_hdlc.Tx_FrameSize),
    .TxEN(uin_hdlc.TxEN),
    .Tx_Enable(uin_hdlc.Tx_Enable),
    .Tx_AbortedTrans(uin_hdlc.Tx_AbortedTrans),
    .Tx_AbortFrame(uin_hdlc.Tx_AbortFrame),
    .Tx_ValidFrame(uin_hdlc.Tx_ValidFrame),
    .Tx_NewByte(uin_hdlc.Tx_NewByte),
    .Tx_Data(uin_hdlc.Tx_Data),
    .Rx_Data(uin_hdlc.Rx_Data),
    .Tx_WriteFCS(uin_hdlc.Tx_WriteFCS),
    .Tx_FCSDone(uin_hdlc.Tx_FCSDone)
  );

endmodule
