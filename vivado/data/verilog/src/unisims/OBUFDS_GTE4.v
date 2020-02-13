///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2018 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \   \   \/      Version     : 2018.3
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        Gigabit Transceiver Buffer
// /___/   /\      Filename    : OBUFDS_GTE4.v
// \   \  /  \ 
//  \___\/\___\                    
//                                 
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//  03/27/2015 - Initial version from E3
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

`celldefine

module OBUFDS_GTE4 #(
`ifdef XIL_TIMING
  parameter LOC = "UNPLACED",  
`endif
  parameter [0:0] REFCLK_EN_TX_PATH = 1'b0,
  parameter [4:0] REFCLK_ICNTL_TX = 5'b00000
)(
  output O,
  output OB,

  input CEB,
  input I
);
  
// define constants
  localparam MODULE_NAME = "OBUFDS_GTE4";

  reg trig_attr;
// include dynamic registers - XILINX test only
`ifdef XIL_DR
  `include "OBUFDS_GTE4_dr.v"
`else
  reg [0:0] REFCLK_EN_TX_PATH_REG = REFCLK_EN_TX_PATH;
  reg [4:0] REFCLK_ICNTL_TX_REG = REFCLK_ICNTL_TX;
`endif

`ifdef XIL_XECLIB
reg glblGSR = 1'b0;
reg glblGTS = 1'b0;
`else
tri0 glblGSR = glbl.GSR;
tri0 glblGTS = glbl.GTS;
`endif

   
//  wire CEB_in;
//  wire I_in;

//  assign CEB_in = (CEB !== 1'bz) && CEB; // rv 0
//  assign I_in = I;

// =====================
// Generate O
// =====================

  assign O = (~REFCLK_EN_TX_PATH_REG || (CEB === 1'b1) || glblGTS) ? 1'bz : I;
  assign OB = (~REFCLK_EN_TX_PATH_REG || (CEB === 1'b1) || glblGTS) ? 1'bz : ~I;

`ifndef XIL_XECLIB
`ifdef XIL_TIMING
  specify
    (I => O) = (0:0:0, 0:0:0);
    (I => OB) = (0:0:0, 0:0:0);
    specparam PATHPULSE$ = 0;
  endspecify
`endif
`endif
endmodule

`endcelldefine
