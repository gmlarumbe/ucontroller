///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2017 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /     Vendor      : Xilinx
// \   \   \/      Version     : 2018.1
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        Synchronizer for BUFG_GT Control Signals
// /___/   /\      Filename    : BUFG_GT_SYNC.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//    02/03/14 - Initial version.
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

`celldefine

module BUFG_GT_SYNC
`ifdef XIL_TIMING
#(
  parameter LOC = "UNPLACED"
)
`endif
(
  output CESYNC,
  output CLRSYNC,

  input CE,
  input CLK,
  input CLR
);
  
// define constants
  localparam MODULE_NAME = "BUFG_GT_SYNC";
  
`ifdef XIL_XECLIB
  reg glblGSR = 1'b0;
`else
  tri0 glblGSR = glbl.GSR;
`endif

  wire CE_in;
  wire CLK_in;
  wire CLR_in;

  assign CE_in = (CE === 1'bz) || CE; // rv 1
  assign CLK_in = CLK;
  assign CLR_in = (CLR !== 1'bz) && CLR; // rv 0

// begin behavioral model

  assign CESYNC = CE_in;
  assign CLRSYNC = CLR_in;

// end behavioral model

endmodule

`endcelldefine
