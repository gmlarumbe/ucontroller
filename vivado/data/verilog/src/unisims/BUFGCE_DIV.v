///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2018 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /     Vendor      : Xilinx
// \   \   \/      Version     : 2018.3
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        General Clock Buffer with Divide Function
// /___/   /\      Filename    : BUFGCE_DIV.v
// \   \  /  \
//  \___\/\___\
//
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//    04/30/12 - Initial version.
//    02/28/13 - 703678 - update BUFGCE_DIVIDE attribute type.
//    06/20/13 - 723918 - Add latch on CE to match HW
//    02/06/14 - 717896 - update specify block
//    10/22/14 - Added #1 to $finish (CR 808642).
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

`celldefine

module BUFGCE_DIV #(
`ifdef XIL_TIMING
  parameter LOC = "UNPLACED",
`endif
  parameter integer BUFGCE_DIVIDE = 1,
  parameter CE_TYPE = "SYNC",
  parameter HARDSYNC_CLR = "FALSE",
  parameter [0:0] IS_CE_INVERTED = 1'b0,
  parameter [0:0] IS_CLR_INVERTED = 1'b0,
  parameter [0:0] IS_I_INVERTED = 1'b0
)(
  output O,

  input CE,
  input CLR,
  input I
);
  
// define constants
  localparam MODULE_NAME = "BUFGCE_DIV";

// Parameter encodings and registers
  localparam CE_TYPE_HARDSYNC = 1;
  localparam CE_TYPE_SYNC = 0;
  localparam HARDSYNC_CLR_FALSE = 0;
  localparam HARDSYNC_CLR_TRUE = 1;

  reg trig_attr;
// include dynamic registers - XILINX test only
`ifdef XIL_DR
  `include "BUFGCE_DIV_dr.v"
`else
  reg [31:0] BUFGCE_DIVIDE_REG = BUFGCE_DIVIDE;
  reg [64:1] CE_TYPE_REG = CE_TYPE;
  reg [40:1] HARDSYNC_CLR_REG = HARDSYNC_CLR;
  reg [0:0] IS_CE_INVERTED_REG = IS_CE_INVERTED;
  reg [0:0] IS_CLR_INVERTED_REG = IS_CLR_INVERTED;
  reg [0:0] IS_I_INVERTED_REG = IS_I_INVERTED;
`endif

`ifdef XIL_XECLIB
  wire [3:0] BUFGCE_DIVIDE_BIN;
  wire CE_TYPE_BIN;
  wire HARDSYNC_CLR_BIN;
`else
  reg [3:0] BUFGCE_DIVIDE_BIN;
  reg CE_TYPE_BIN;
  reg HARDSYNC_CLR_BIN;
`endif

`ifdef XIL_XECLIB
reg glblGSR = 1'b0;
`else
tri0 glblGSR = glbl.GSR;
`endif

  wire CE_in;
  wire CLR_in;
  wire I_in;

`ifdef XIL_TIMING
  wire CE_delay;
  wire CLR_delay;
  wire I_delay;
`endif

`ifdef XIL_TIMING
  assign CE_in = (CE === 1'bz) || (CE_delay ^ IS_CE_INVERTED_REG); // rv 1
  assign CLR_in = (CLR !== 1'bz) && (CLR_delay ^ IS_CLR_INVERTED_REG); // rv 0
  assign I_in = I_delay ^ IS_I_INVERTED_REG;
`else
  assign CE_in = (CE === 1'bz) || (CE ^ IS_CE_INVERTED_REG); // rv 1
  assign CLR_in = (CLR !== 1'bz) && (CLR ^ IS_CLR_INVERTED_REG); // rv 0
  assign I_in = I ^ IS_I_INVERTED_REG;
`endif

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
  assign BUFGCE_DIVIDE_BIN = BUFGCE_DIVIDE_REG[3:0];
  
  assign CE_TYPE_BIN =
      (CE_TYPE_REG == "SYNC") ? CE_TYPE_SYNC :
      (CE_TYPE_REG == "HARDSYNC") ? CE_TYPE_HARDSYNC :
       CE_TYPE_SYNC;
  
  assign HARDSYNC_CLR_BIN =
      (HARDSYNC_CLR_REG == "FALSE") ? HARDSYNC_CLR_FALSE :
      (HARDSYNC_CLR_REG == "TRUE") ? HARDSYNC_CLR_TRUE :
       HARDSYNC_CLR_FALSE;
  
`else
  always @ (trig_attr) begin
  #1;
  BUFGCE_DIVIDE_BIN = BUFGCE_DIVIDE_REG[3:0];
  
  CE_TYPE_BIN =
      (CE_TYPE_REG == "SYNC") ? CE_TYPE_SYNC :
      (CE_TYPE_REG == "HARDSYNC") ? CE_TYPE_HARDSYNC :
       CE_TYPE_SYNC;
  
  HARDSYNC_CLR_BIN =
      (HARDSYNC_CLR_REG == "FALSE") ? HARDSYNC_CLR_FALSE :
      (HARDSYNC_CLR_REG == "TRUE") ? HARDSYNC_CLR_TRUE :
       HARDSYNC_CLR_FALSE;
  
  end
`endif

`ifndef XIL_XECLIB
  always @ (trig_attr) begin
  #1;
    if ((attr_test == 1'b1) ||
        ((BUFGCE_DIVIDE_REG != 1) &&
         (BUFGCE_DIVIDE_REG != 2) &&
         (BUFGCE_DIVIDE_REG != 3) &&
         (BUFGCE_DIVIDE_REG != 4) &&
         (BUFGCE_DIVIDE_REG != 5) &&
         (BUFGCE_DIVIDE_REG != 6) &&
         (BUFGCE_DIVIDE_REG != 7) &&
         (BUFGCE_DIVIDE_REG != 8))) begin
      $display("Error: [Unisim %s-101] BUFGCE_DIVIDE attribute is set to %d.  Legal values for this attribute are 1, 2, 3, 4, 5, 6, 7 or 8. Instance: %m", MODULE_NAME, BUFGCE_DIVIDE_REG);
      attr_err = 1'b1;
    end

    if ((attr_test == 1'b1) ||
        ((CE_TYPE_REG != "SYNC") &&
         (CE_TYPE_REG != "HARDSYNC"))) begin
      $display("Error: [Unisim %s-102] CE_TYPE attribute is set to %s.  Legal values for this attribute are SYNC or HARDSYNC. Instance: %m", MODULE_NAME, CE_TYPE_REG);
      attr_err = 1'b1;
    end

    if ((attr_test == 1'b1) ||
        ((HARDSYNC_CLR_REG != "FALSE") &&
         (HARDSYNC_CLR_REG != "TRUE"))) begin
      $display("Error: [Unisim %s-103] HARDSYNC_CLR attribute is set to %s.  Legal values for this attribute are FALSE or TRUE. Instance: %m", MODULE_NAME, HARDSYNC_CLR_REG);
      attr_err = 1'b1;
    end

  if (attr_err == 1'b1) #1 $finish;
  end
`endif

`ifdef XIL_TIMING
  reg notifier;
`endif

// begin behavioral model

  integer clk_count, first_toggle_count, second_toggle_count;
  reg first_rise, first_half_period;
  reg  o_out_divide;
  wire i_ce;
  wire CLR_int;
  reg [2:0] ce_en;
  reg [2:0] CLR_reg;

  assign O = o_out_divide;

  initial begin
    clk_count=1;
    first_toggle_count=1;
    second_toggle_count=1;
    o_out_divide = 1'b0;
    ce_en = 3'b000;
    CLR_reg = 3'b000;
  end

  always @ (trig_attr) begin
  #1;
    case (BUFGCE_DIVIDE_REG)
      1 : begin
       first_toggle_count = 1;
       second_toggle_count = 1;
     end
      2 : begin
       first_toggle_count = 2;
       second_toggle_count = 2;
          end
      3 : begin
       first_toggle_count = 2;
       second_toggle_count = 4;
     end
      4 : begin
       first_toggle_count = 4;
       second_toggle_count = 4;
     end
      5 : begin
       first_toggle_count = 4;
       second_toggle_count = 6;
     end
      6 : begin
       first_toggle_count = 6;
       second_toggle_count = 6;
     end
      7 : begin
       first_toggle_count = 6;
       second_toggle_count = 8;
     end
      8 : begin
       first_toggle_count = 8;
       second_toggle_count = 8;
          end
    endcase // case(BUFGCE_DIV)

  end

  always begin
    if (glblGSR == 1'b1) begin
      assign o_out_divide = 1'b0;
      assign clk_count = 0;
      assign first_rise = 1'b1;
      assign first_half_period = 1'b0;
    end
    else if (glblGSR == 1'b0) begin
      deassign o_out_divide;
      deassign clk_count;
      deassign first_rise;
      deassign first_half_period;
    end
    @(glblGSR);
  end

  always @(posedge glblGSR or negedge I_in) begin
    if (glblGSR || (HARDSYNC_CLR_BIN == HARDSYNC_CLR_FALSE))
      CLR_reg <= 3'b0;
    else if (~I_in)
      CLR_reg <= {CLR_reg[1:0], CLR_in};
  end

  assign CLR_int = ((HARDSYNC_CLR_BIN == HARDSYNC_CLR_FALSE) && CLR_in) || CLR_reg[2];

  always @(glblGSR, CLR_int, I_in, CE_in) begin
    if(glblGSR || CLR_int)
      ce_en <= 3'b000;
    else if (~I_in)
      ce_en <= {ce_en[1:0], CE_in};
  end

  assign i_ce = (I_in & (CE_TYPE_BIN == CE_TYPE_SYNC) && ce_en[0]) ||
                (I_in & (CE_TYPE_BIN == CE_TYPE_HARDSYNC) && ce_en[2]);

  always @(i_ce or posedge glblGSR or posedge CLR_int) begin
    if (first_toggle_count == 1) begin
      o_out_divide = i_ce;
    end
    else begin
      if(CLR_int == 1'b1 || glblGSR == 1'b1) begin
        o_out_divide = 1'b0;
        clk_count = 1;
        first_half_period = 1'b1;
        first_rise = 1'b1;
      end
      else if(CLR_int == 1'b0 && glblGSR == 1'b0) begin
        if (i_ce == 1'b1 && first_rise == 1'b1) begin
          o_out_divide = 1'b1;
          clk_count = 1;
          first_half_period = 1'b1;
          first_rise = 1'b0;
        end
        else if (clk_count == second_toggle_count && first_half_period == 1'b0) begin
          o_out_divide = ~o_out_divide;
          clk_count = 1;
          first_half_period = 1'b1;
        end
        else if (clk_count == first_toggle_count && first_half_period == 1'b1) begin
          o_out_divide = ~o_out_divide;
          clk_count = 1;
          first_half_period = 1'b0;
        end
        else if (first_rise == 1'b0) begin
          clk_count = clk_count + 1;
        end
      end
    end
  end

// end behavioral model

`ifndef XIL_XECLIB
`ifdef XIL_TIMING

  wire i_en_n;
  wire i_en_p;

  assign i_en_n =  IS_I_INVERTED_REG;
  assign i_en_p = ~IS_I_INVERTED_REG;

`endif

  specify
    (I => O) = (0:0:0, 0:0:0);
    (negedge CLR => (O +: 0)) = (0:0:0, 0:0:0);
    (posedge CLR => (O +: 0)) = (0:0:0, 0:0:0);
`ifdef XIL_TIMING
    $period (negedge I, 0:0:0, notifier);
    $period (posedge I, 0:0:0, notifier);
    $recrem (negedge CLR, negedge I, 0:0:0, 0:0:0, notifier, i_en_n, i_en_n, CLR_delay, I_delay);
    $recrem (negedge CLR, posedge I, 0:0:0, 0:0:0, notifier, i_en_p, i_en_p, CLR_delay, I_delay);
    $recrem (posedge CLR, negedge I, 0:0:0, 0:0:0, notifier, i_en_n, i_en_n, CLR_delay, I_delay);
    $recrem (posedge CLR, posedge I, 0:0:0, 0:0:0, notifier, i_en_p, i_en_p, CLR_delay, I_delay);
    $setuphold (negedge I, negedge CE, 0:0:0, 0:0:0, notifier, i_en_n, i_en_n, I_delay, CE_delay);
    $setuphold (negedge I, posedge CE, 0:0:0, 0:0:0, notifier, i_en_n, i_en_n, I_delay, CE_delay);
    $setuphold (posedge I, negedge CE, 0:0:0, 0:0:0, notifier, i_en_p, i_en_p, I_delay, CE_delay);
    $setuphold (posedge I, posedge CE, 0:0:0, 0:0:0, notifier, i_en_p, i_en_p, I_delay, CE_delay);
    $width (negedge CLR, 0:0:0, 0, notifier);
    $width (posedge CLR, 0:0:0, 0, notifier);
`endif
    specparam PATHPULSE$ = 0;
  endspecify
`endif
endmodule

`endcelldefine
