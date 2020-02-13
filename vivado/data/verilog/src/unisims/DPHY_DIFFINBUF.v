///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2015 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /     Vendor      : Xilinx
// \   \   \/      Version     : 2015.4
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        _no_description_
// /___/   /\      Filename    : DPHY_DIFFINBUF.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

`celldefine

module DPHY_DIFFINBUF #(
`ifdef XIL_TIMING
  parameter LOC = "UNPLACED",
`endif
  parameter DIFF_TERM = "TRUE",
  parameter ISTANDARD = "DEFAULT"
)(
  output HSRX_O,
  output LPRX_O_N,
  output LPRX_O_P,

  input HSRX_DISABLE,
  input I,
  input IB,
  input LPRX_DISABLE
);
  
// define constants
  localparam MODULE_NAME = "DPHY_DIFFINBUF";

// Parameter encodings and registers
  localparam DIFF_TERM_FALSE = 1;
  localparam DIFF_TERM_TRUE = 0;
  localparam ISTANDARD_DEFAULT = 0;

  reg trig_attr = 1'b0;
// include dynamic registers - XILINX test only
`ifdef XIL_DR
  `include "DPHY_DIFFINBUF_dr.v"
`else
  localparam [40:1] DIFF_TERM_REG = DIFF_TERM;
  localparam [56:1] ISTANDARD_REG = ISTANDARD;
`endif

  wire DIFF_TERM_BIN;
  wire ISTANDARD_BIN;

`ifdef XIL_ATTR_TEST
  reg attr_test = 1'b1;
`else
  reg attr_test = 1'b0;
`endif
  reg attr_err = 1'b0;
  tri0 glblGSR = glbl.GSR;

  wire HSRX_O_out;
  wire LPRX_O_N_out;
  wire LPRX_O_P_out;

  wire HSRX_DISABLE_in;
  wire IB_in;
  wire I_in;
  wire LPRX_DISABLE_in;

  assign HSRX_O = HSRX_O_out;
  assign LPRX_O_N = LPRX_O_N_out;
  assign LPRX_O_P = LPRX_O_P_out;

  assign HSRX_DISABLE_in = HSRX_DISABLE;
  assign IB_in = IB;
  assign I_in = I;
  assign LPRX_DISABLE_in = LPRX_DISABLE;

  assign DIFF_TERM_BIN =
    (DIFF_TERM_REG == "FALSE") ? DIFF_TERM_FALSE :
    (DIFF_TERM_REG == "TRUE")  ? DIFF_TERM_TRUE  :
     DIFF_TERM_TRUE;

  assign ISTANDARD_BIN =
    (ISTANDARD_REG == "DEFAULT") ? ISTANDARD_DEFAULT :
     ISTANDARD_DEFAULT;

`ifndef XIL_TIMING
  initial begin
    $display("Error: [Unisim %s-103] SIMPRIM primitive is not intended for direct instantiation in RTL or functional netlists. This primitive is only available in the SIMPRIM library for implemented netlists, please ensure you are pointing to the correct library. Instance %m", MODULE_NAME);
    #1;
    $finish;
  end
`endif

  initial begin
    #1;
    trig_attr = ~trig_attr;
  end

  always @ (trig_attr) begin
    #1;
    if ((attr_test == 1'b1) ||
        ((DIFF_TERM_REG != "TRUE") &&
         (DIFF_TERM_REG != "FALSE"))) begin
      $display("Error: [Unisim %s-101] DIFF_TERM attribute is set to %s.  Legal values for this attribute are TRUE or FALSE. Instance: %m", MODULE_NAME, DIFF_TERM_REG);
      attr_err = 1'b1;
    end

// no check
//    if ((attr_test == 1'b1) ||
//        ((ISTANDARD_REG != "DEFAULT"))) begin
//      $display("Error: [Unisim %s-102] ISTANDARD attribute is set to %s.  Legal values for this attribute are DEFAULT. Instance: %m", MODULE_NAME, ISTANDARD_REG);
//      attr_err = 1'b1;
//    end

    if (attr_err == 1'b1) #1 $finish;
  end

  reg o_out;
  wire [1:0] lp_out;
  wire lp_mode;
  wire hs_mode;
  wire hs_out;
  reg [3*8:1] strP,strN;  
  
  always @(*)
     begin
        $sformat(strP, "%v", I);
        $sformat(strN, "%v", IB);
     end

  assign lp_mode = (strP[24:17] == "S") & (strN[24:17] == "S");  // For LP strength type Strong

  assign #1 lp_out[0] = lp_mode === 1'b1 ? I_in : 1'b0;
  assign #1 lp_out[1] = lp_mode === 1'b1 ? IB_in : 1'b0;
  
  assign HSRX_O_out = (HSRX_DISABLE_in === 1'b0) ? o_out : (HSRX_DISABLE_in === 1'bx || HSRX_DISABLE_in === 1'bz) ? 1'bx : 1'b0;
  			
  assign LPRX_O_N_out = (LPRX_DISABLE_in === 1'b0) ? lp_out[1] : (LPRX_DISABLE_in === 1'bx || LPRX_DISABLE_in === 1'bz) ? 1'bx : 1'b0; 
  assign LPRX_O_P_out = (LPRX_DISABLE_in === 1'b0) ? lp_out[0] : (LPRX_DISABLE_in === 1'bx || LPRX_DISABLE_in === 1'bz) ? 1'bx : 1'b0; 

  always @ (I_in or IB_in) begin
    if (I_in == 1'b1 && IB_in == 1'b0)
      o_out <= 1'b1;
    else if (I_in == 1'b0 && IB_in == 1'b1)
      o_out <= 1'b0;
    else if ((I_in === 1'bx) || (IB_in === 1'bx) || I_in === 1'bz || IB_in === 1'bz )
      o_out <= 1'bx;
  end

specify
  (HSRX_DISABLE => HSRX_O) = (0:0:0, 0:0:0);
  (I => HSRX_O) = (0:0:0, 0:0:0);
  (I => LPRX_O_P) = (0:0:0, 0:0:0);
  (IB => HSRX_O) = (0:0:0, 0:0:0);
  (IB => LPRX_O_N) = (0:0:0, 0:0:0);
  (LPRX_DISABLE => LPRX_O_N) = (0:0:0, 0:0:0);
  (LPRX_DISABLE => LPRX_O_P) = (0:0:0, 0:0:0);
  specparam PATHPULSE$ = 0;
endspecify

endmodule

`endcelldefine
