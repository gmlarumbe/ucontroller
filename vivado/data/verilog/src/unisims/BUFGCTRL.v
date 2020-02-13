///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2018 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \   \   \/      Version     : 2018.3
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        General Clock Control Buffer
// /___/   /\      Filename    : BUFGCTRL.v
// \   \  /  \ 
//  \___\/\___\                    
//                                 
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//  06/27/13 - 723696 - dynamic register change
//  02/06/14 - 771896 - specify block update
//  10/22/14 - 808642 - Added #1 to $finish
//  12/01/14 - 837543 - specify block update, LW template
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps 

`celldefine

module BUFGCTRL #(
`ifdef XIL_TIMING
  parameter LOC = "UNPLACED",  
`endif
  parameter CE_TYPE_CE0 = "SYNC",
  parameter CE_TYPE_CE1 = "SYNC",
  parameter integer INIT_OUT = 0,
  parameter [0:0] IS_CE0_INVERTED = 1'b0,
  parameter [0:0] IS_CE1_INVERTED = 1'b0,
  parameter [0:0] IS_I0_INVERTED = 1'b0,
  parameter [0:0] IS_I1_INVERTED = 1'b0,
  parameter [0:0] IS_IGNORE0_INVERTED = 1'b0,
  parameter [0:0] IS_IGNORE1_INVERTED = 1'b0,
  parameter [0:0] IS_S0_INVERTED = 1'b0,
  parameter [0:0] IS_S1_INVERTED = 1'b0,
  parameter PRESELECT_I0 = "FALSE",
  parameter PRESELECT_I1 = "FALSE"
)(
  output O,

  input CE0,
  input CE1,
  input I0,
  input I1,
  input IGNORE0,
  input IGNORE1,
  input S0,
  input S1
);
  
// define constants
  localparam MODULE_NAME = "BUFGCTRL";

// Parameter encodings and registers
  localparam CE_TYPE_CE0_HARDSYNC = 1;
  localparam CE_TYPE_CE0_SYNC = 0;
  localparam CE_TYPE_CE1_HARDSYNC = 1;
  localparam CE_TYPE_CE1_SYNC = 0;
  localparam PRESELECT_I0_FALSE = 0;
  localparam PRESELECT_I0_TRUE = 1;
  localparam PRESELECT_I1_FALSE = 0;
  localparam PRESELECT_I1_TRUE = 1;

  reg trig_attr;
// include dynamic registers - XILINX test only
`ifdef XIL_DR
  `include "BUFGCTRL_dr.v"
`else
  reg [64:1] CE_TYPE_CE0_REG = CE_TYPE_CE0;
  reg [64:1] CE_TYPE_CE1_REG = CE_TYPE_CE1;
  reg [31:0] INIT_OUT_REG = INIT_OUT;
  reg [0:0] IS_CE0_INVERTED_REG = IS_CE0_INVERTED;
  reg [0:0] IS_CE1_INVERTED_REG = IS_CE1_INVERTED;
  reg [0:0] IS_I0_INVERTED_REG = IS_I0_INVERTED;
  reg [0:0] IS_I1_INVERTED_REG = IS_I1_INVERTED;
  reg [0:0] IS_IGNORE0_INVERTED_REG = IS_IGNORE0_INVERTED;
  reg [0:0] IS_IGNORE1_INVERTED_REG = IS_IGNORE1_INVERTED;
  reg [0:0] IS_S0_INVERTED_REG = IS_S0_INVERTED;
  reg [0:0] IS_S1_INVERTED_REG = IS_S1_INVERTED;
  reg [40:1] PRESELECT_I0_REG = PRESELECT_I0;
  reg [40:1] PRESELECT_I1_REG = PRESELECT_I1;
`endif

`ifdef XIL_XECLIB
  wire CE_TYPE_CE0_BIN;
  wire CE_TYPE_CE1_BIN;
  wire INIT_OUT_BIN;
  wire PRESELECT_I0_BIN;
  wire PRESELECT_I1_BIN;
`else
  reg CE_TYPE_CE0_BIN;
  reg CE_TYPE_CE1_BIN;
  reg INIT_OUT_BIN;
  reg PRESELECT_I0_BIN;
  reg PRESELECT_I1_BIN;
`endif

`ifdef XIL_XECLIB
reg glblGSR = 1'b0;
`else
  tri0 glblGSR = glbl.GSR;
`endif

  wire CE0_in;
  wire CE1_in;
  wire I0_in;
  wire I1_in;
  wire IGNORE0_in;
  wire IGNORE1_in;
  wire S0_in;
  wire S1_in;

`ifdef XIL_TIMING
  wire CE0_delay;
  wire CE1_delay;
  wire I0_delay;
  wire I1_delay;
  wire S0_delay;
  wire S1_delay;
`endif

`ifdef XIL_TIMING
  assign CE0_in = (CE0 !== 1'bz) && (CE0_delay ^ IS_CE0_INVERTED_REG); // rv 0
  assign CE1_in = (CE1 !== 1'bz) && (CE1_delay ^ IS_CE1_INVERTED_REG); // rv 0
  assign I0_in = I0_delay ^ IS_I0_INVERTED_REG;
  assign I1_in = I1_delay ^ IS_I1_INVERTED_REG;
  assign S0_in = (S0 !== 1'bz) && (S0_delay ^ IS_S0_INVERTED_REG); // rv 0
  assign S1_in = (S1 !== 1'bz) && (S1_delay ^ IS_S1_INVERTED_REG); // rv 0
`else
  assign CE0_in = (CE0 !== 1'bz) && (CE0 ^ IS_CE0_INVERTED_REG); // rv 0
  assign CE1_in = (CE1 !== 1'bz) && (CE1 ^ IS_CE1_INVERTED_REG); // rv 0
  assign I0_in = I0 ^ IS_I0_INVERTED_REG;
  assign I1_in = I1 ^ IS_I1_INVERTED_REG;
  assign S0_in = (S0 !== 1'bz) && (S0 ^ IS_S0_INVERTED_REG); // rv 0
  assign S1_in = (S1 !== 1'bz) && (S1 ^ IS_S1_INVERTED_REG); // rv 0
`endif

  assign IGNORE0_in = (IGNORE0 !== 1'bz) && (IGNORE0 ^ IS_IGNORE0_INVERTED_REG); // rv 0
  assign IGNORE1_in = (IGNORE1 !== 1'bz) && (IGNORE1 ^ IS_IGNORE1_INVERTED_REG); // rv 0

`ifndef XIL_XECLIB
  reg attr_test;
  reg attr_err;
  
  initial begin
    trig_attr = 1'b0;
  `ifdef XIL_ATTR_TEST
    attr_test = 1'b1;
  `else
    attr_test = 1'b0;
  `endif
    attr_err = 1'b0;
    #1;
    trig_attr = ~trig_attr;
  end
`endif

`ifdef XIL_XECLIB
  assign CE_TYPE_CE0_BIN =
      (CE_TYPE_CE0_REG == "SYNC") ? CE_TYPE_CE0_SYNC :
      (CE_TYPE_CE0_REG == "HARDSYNC") ? CE_TYPE_CE0_HARDSYNC :
       CE_TYPE_CE0_SYNC;
  
  assign CE_TYPE_CE1_BIN =
      (CE_TYPE_CE1_REG == "SYNC") ? CE_TYPE_CE1_SYNC :
      (CE_TYPE_CE1_REG == "HARDSYNC") ? CE_TYPE_CE1_HARDSYNC :
       CE_TYPE_CE1_SYNC;
  
  assign INIT_OUT_BIN = INIT_OUT_REG[0];

  assign PRESELECT_I0_BIN =
    (PRESELECT_I0_REG == "FALSE") ? PRESELECT_I0_FALSE :
    (PRESELECT_I0_REG == "TRUE")  ? PRESELECT_I0_TRUE  :
    PRESELECT_I0_FALSE;

  assign PRESELECT_I1_BIN =
    (PRESELECT_I1_REG == "FALSE") ? PRESELECT_I1_FALSE :
    (PRESELECT_I1_REG == "TRUE")  ? PRESELECT_I1_TRUE  :
    PRESELECT_I1_FALSE;

`else
  always @ (trig_attr) begin
  #1;
  CE_TYPE_CE0_BIN =
      (CE_TYPE_CE0_REG == "SYNC") ? CE_TYPE_CE0_SYNC :
      (CE_TYPE_CE0_REG == "HARDSYNC") ? CE_TYPE_CE0_HARDSYNC :
       CE_TYPE_CE0_SYNC;
  
  CE_TYPE_CE1_BIN =
      (CE_TYPE_CE1_REG == "SYNC") ? CE_TYPE_CE1_SYNC :
      (CE_TYPE_CE1_REG == "HARDSYNC") ? CE_TYPE_CE1_HARDSYNC :
       CE_TYPE_CE1_SYNC;
  
  INIT_OUT_BIN = INIT_OUT_REG[0];
  
  PRESELECT_I0_BIN =
      (PRESELECT_I0_REG == "FALSE") ? PRESELECT_I0_FALSE :
      (PRESELECT_I0_REG == "TRUE")  ? PRESELECT_I0_TRUE  :
       PRESELECT_I0_FALSE;

  PRESELECT_I1_BIN =
      (PRESELECT_I1_REG == "FALSE") ? PRESELECT_I1_FALSE :
      (PRESELECT_I1_REG == "TRUE")  ? PRESELECT_I1_TRUE  :
       PRESELECT_I1_FALSE;

  end
`endif

`ifndef XIL_XECLIB
  always @ (trig_attr) begin
    #1;
    if ((attr_test == 1'b1) ||
        ((CE_TYPE_CE0_REG != "SYNC") &&
         (CE_TYPE_CE0_REG != "HARDSYNC"))) begin
      $display("Error: [Unisim %s-101] CE_TYPE_CE0 attribute is set to %s.  Legal values for this attribute are SYNC or HARDSYNC. Instance: %m", MODULE_NAME, CE_TYPE_CE0_REG);
      attr_err = 1'b1;
    end
    
    if ((attr_test == 1'b1) ||
        ((CE_TYPE_CE1_REG != "SYNC") &&
         (CE_TYPE_CE1_REG != "HARDSYNC"))) begin
      $display("Error: [Unisim %s-102] CE_TYPE_CE1 attribute is set to %s.  Legal values for this attribute are SYNC or HARDSYNC. Instance: %m", MODULE_NAME, CE_TYPE_CE1_REG);
      attr_err = 1'b1;
    end
    
    if ((attr_test == 1'b1) ||
        ((INIT_OUT_REG != 0) &&
         (INIT_OUT_REG != 1))) begin
      $display("Error: [Unisim %s-104] INIT_OUT attribute is set to %d.  Legal values for this attribute are 0 or 1. Instance: %m", MODULE_NAME, INIT_OUT_REG);
      attr_err = 1'b1;
    end
    
    if ((attr_test == 1'b1) ||
        ((PRESELECT_I0_REG != "FALSE") &&
         (PRESELECT_I0_REG != "TRUE"))) begin
      $display("Error: [Unisim %s-113] PRESELECT_I0 attribute is set to %s.  Legal values for this attribute are FALSE or TRUE. Instance: %m", MODULE_NAME, PRESELECT_I0_REG);
      attr_err = 1'b1;
    end
    
    if ((attr_test == 1'b1) ||
        ((PRESELECT_I1_REG != "FALSE") &&
         (PRESELECT_I1_REG != "TRUE"))) begin
      $display("Error: [Unisim %s-114] PRESELECT_I1 attribute is set to %s.  Legal values for this attribute are FALSE or TRUE. Instance: %m", MODULE_NAME, PRESELECT_I1_REG);
      attr_err = 1'b1;
    end

  if (attr_err == 1'b1) #1 $finish;
  end
`endif

`ifdef XIL_TIMING
  reg notifier;
`endif

// begin behavioral model

  reg[2:0] CE0_reg;
  reg[2:0] CE1_reg;
  reg O_out;
  wire CE0_int;
  wire CE1_int;

  assign O = O_out;

`ifndef XIL_XECLIB
  always @ (trig_attr) begin
    #1;

// *** both preselects can not be 1 simultaneously.
   if ((PRESELECT_I0_REG == "TRUE") && (PRESELECT_I1_REG == "TRUE")) begin
      $display("Error : [Unisim %s-1] The attributes PRESELECT_I0 and PRESELECT_I1 should not be set to TRUE simultaneously. Instance: %m", MODULE_NAME);
      attr_err = 1'b1;
   end

  if (attr_err == 1'b1) #1 $finish;
  end
`endif

  reg q0, q1;
  reg q0_enable, q1_enable;
  wire I0t, I1t;
  
// *** Start here
  assign I0t = INIT_OUT_BIN ^ I0_in;
  assign I1t = INIT_OUT_BIN ^ I1_in;

  assign CE0_int = (CE_TYPE_CE0_BIN == CE_TYPE_CE0_SYNC) ? CE0_in : CE0_reg[2];
  assign CE1_int = (CE_TYPE_CE1_BIN == CE_TYPE_CE1_SYNC) ? CE1_in : CE1_reg[2];

  initial begin
    CE0_reg = 3'b000;
    CE1_reg = 3'b000;
  end

  always @ (posedge I0_in or posedge glblGSR) begin
    if (glblGSR || (CE_TYPE_CE0_BIN == CE_TYPE_CE0_SYNC)) begin
      CE0_reg <= 3'b000;
    end else begin
      CE0_reg <= {CE0_reg[1:0], CE0_in};
    end
  end

  always @ (posedge I1_in or posedge glblGSR) begin
    if (glblGSR || (CE_TYPE_CE1_BIN == CE_TYPE_CE1_SYNC)) begin
      CE1_reg <= 3'b000;
    end else begin
      CE1_reg <= {CE1_reg[1:0], CE1_in};
    end
  end

// *** input enable for i1
  always @(IGNORE1_in or I1t or S1_in or glblGSR or q0 or PRESELECT_I1_BIN) begin
    if (glblGSR == 1)
      q1_enable <= PRESELECT_I1_BIN;
    else if (glblGSR == 0) begin
      if ((I1t == 0) && (IGNORE1_in == 0))
        q1_enable <= q1_enable;
    else if ((I1t == 1) || (IGNORE1_in == 1))
      q1_enable <= (~q0 && S1_in);
    end
  end

// *** Output q1 for i1
  always @(*) begin
    if (glblGSR !== 1'b0) begin
      q1 <= (q1_enable === 1'b1);
    end else if (((I1t == 0) || (IGNORE1_in == 1)) && (q1 != (CE1_int && q1_enable)))begin
      q1 <= (CE1_int && q1_enable);
    end
  end

// *** input enable for i0
  always @(IGNORE0_in or I0t or S0_in or glblGSR or q1 or PRESELECT_I0_BIN) begin
    if (glblGSR == 1)
      q0_enable <= PRESELECT_I0_BIN;
    else if (glblGSR == 0) begin
      if ((I0t == 0) && (IGNORE0_in == 0))
        q0_enable <= q0_enable;
    else if ((I0t == 1) || (IGNORE0_in == 1))
      q0_enable <= (~q1 && S0_in);
    end
  end

// *** Output q0 for i0
  always @(*) begin
    if (glblGSR !== 1'b0) begin
      q0 <= (q0_enable === 1'b1);
    end else if (((I0t == 0) || (IGNORE0_in == 1)) && (q0 != (CE0_int && q0_enable)))begin
      q0 <= (CE0_int && q0_enable);
    end
  end

  always @(q0 or q1 or I0_in or I1_in) begin 
    if (I0_in === I1_in) begin
      if (q0 === 1'b1) begin
        O_out = I0_in;
      end else if (q1 === 1'b1) begin
        O_out = I1_in;
      end else begin
        O_out = INIT_OUT_BIN;
      end
    end else begin
      case ({q1, q0})
        2'b01: O_out = I0_in;
        2'b10: O_out = I1_in; 
        2'b00: O_out = INIT_OUT_BIN;
        2'b11: begin
          q0 = 1'bx;
          q1 = 1'bx;
          q0_enable = 1'bx;
          q1_enable = 1'bx;
          O_out = 1'bx;
        end
      endcase
    end
  end

// end behavioral model

`ifndef XIL_XECLIB
`ifdef XIL_TIMING

  wire i0_en_n;
  wire i0_en_p;
  wire i1_en_n;
  wire i1_en_p;

  assign i0_en_n = IS_I0_INVERTED_REG;
  assign i0_en_p = ~IS_I0_INVERTED_REG;
  assign i1_en_n = IS_I1_INVERTED_REG;
  assign i1_en_p = ~IS_I1_INVERTED_REG;
`endif

// I0/I1 are clocks but do not clock anything in this model. do not need the 100 ps.
// specify absorbs a potential glitch in functional simuation when S0/S1 switch
// that needs to remain to match rtl.
// IO paths are combinatorial through muxes and not registers
`ifdef XIL_TIMING
  specify
    (CE0 => O) = (0:0:0, 0:0:0);
    (CE1 => O) = (0:0:0, 0:0:0);
    (I0 => O) = (0:0:0, 0:0:0);
    (I1 => O) = (0:0:0, 0:0:0);
    $period (negedge I0, 0:0:0, notifier);
    $period (negedge I1, 0:0:0, notifier);
    $period (posedge I0, 0:0:0, notifier);
    $period (posedge I1, 0:0:0, notifier);
    $setuphold (negedge I0, negedge CE0, 0:0:0, 0:0:0, notifier,i0_en_n,i0_en_n, I0_delay, CE0_delay);
    $setuphold (negedge I0, negedge S0, 0:0:0, 0:0:0, notifier,i0_en_n,i0_en_n, I0_delay, S0_delay);
    $setuphold (negedge I0, posedge CE0, 0:0:0, 0:0:0, notifier,i0_en_n,i0_en_n, I0_delay, CE0_delay);
    $setuphold (negedge I0, posedge S0, 0:0:0, 0:0:0, notifier,i0_en_n,i0_en_n, I0_delay, S0_delay);
    $setuphold (negedge I1, negedge CE1, 0:0:0, 0:0:0, notifier,i1_en_n,i1_en_n, I1_delay, CE1_delay);
    $setuphold (negedge I1, negedge S1, 0:0:0, 0:0:0, notifier,i1_en_n,i1_en_n, I1_delay, S1_delay);
    $setuphold (negedge I1, posedge CE1, 0:0:0, 0:0:0, notifier,i1_en_n,i1_en_n, I1_delay, CE1_delay);
    $setuphold (negedge I1, posedge S1, 0:0:0, 0:0:0, notifier,i1_en_n,i1_en_n, I1_delay, S1_delay);
    $setuphold (posedge I0, negedge CE0, 0:0:0, 0:0:0, notifier,i0_en_p,i0_en_p, I0_delay, CE0_delay);
    $setuphold (posedge I0, negedge S0, 0:0:0, 0:0:0, notifier,i0_en_p,i0_en_p, I0_delay, S0_delay);
    $setuphold (posedge I0, posedge CE0, 0:0:0, 0:0:0, notifier,i0_en_p,i0_en_p, I0_delay, CE0_delay);
    $setuphold (posedge I0, posedge S0, 0:0:0, 0:0:0, notifier,i0_en_p,i0_en_p, I0_delay, S0_delay);
    $setuphold (posedge I1, negedge CE1, 0:0:0, 0:0:0, notifier,i1_en_p,i1_en_p, I1_delay, CE1_delay);
    $setuphold (posedge I1, negedge S1, 0:0:0, 0:0:0, notifier,i1_en_p,i1_en_p, I1_delay, S1_delay);
    $setuphold (posedge I1, posedge CE1, 0:0:0, 0:0:0, notifier,i1_en_p,i1_en_p, I1_delay, CE1_delay);
    $setuphold (posedge I1, posedge S1, 0:0:0, 0:0:0, notifier,i1_en_p,i1_en_p, I1_delay, S1_delay);
    specparam PATHPULSE$ = 0;
  endspecify
`endif
`endif

endmodule

`endcelldefine
