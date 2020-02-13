///////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 1995/2015 Xilinx, Inc.
//  All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____   ____
//  /   /\/   / 
// /___/  \  /     Vendor      : Xilinx 
// \   \   \/      Version     : 2015.3
//  \   \          Description : Xilinx Unified Simulation Library Component
//  /   /                        Dedicated Dual Data Rate (DDR) Output Register
// /___/   /\      Filename    : ODDRE1.v
// \   \  /  \ 
//  \___\/\___\                    
//                                 
///////////////////////////////////////////////////////////////////////////////
//  Revision:
//
//    10/22/14 - Added #1 to $finish (CR 808642).
//  End Revision:
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

`celldefine

module ODDRE1 #(
  `ifdef XIL_TIMING
  parameter LOC = "UNPLACED",  
  `endif
  parameter [0:0] IS_C_INVERTED = 1'b0,
  parameter [0:0] IS_D1_INVERTED = 1'b0,
  parameter [0:0] IS_D2_INVERTED = 1'b0,
  parameter SIM_DEVICE = "ULTRASCALE",
  parameter [0:0] SRVAL = 1'b0
)(
  output Q,

  input C,
  input D1,
  input D2,
  input SR
);
  
// define constants
  localparam MODULE_NAME = "ODDRE1";

// Parameter encodings and registers

  
// include dynamic registers - XILINX test only
  reg trig_attr = 1'b0;
  `ifdef XIL_DR
  `include "ODDRE1_dr.v"
  `else
  reg [0:0] IS_C_INVERTED_REG = IS_C_INVERTED;
  reg [0:0] IS_D1_INVERTED_REG = IS_D1_INVERTED;
  reg [0:0] IS_D2_INVERTED_REG = IS_D2_INVERTED;
  reg [152:1] SIM_DEVICE_REG = SIM_DEVICE;
  reg [0:0] SRVAL_REG = SRVAL;
  `endif

  wire IS_C_INVERTED_BIN;
  wire IS_D1_INVERTED_BIN;
  wire IS_D2_INVERTED_BIN;
  wire SRVAL_BIN;

  `ifdef XIL_ATTR_TEST
  reg attr_test = 1'b1;
  `else
  reg attr_test = 1'b0;
  `endif
  reg attr_err = 1'b0;
  tri0 glblGSR = glbl.GSR;


  wire C_in;
  wire D1_in;
  wire D2_in;
  wire SR_in;

`ifdef XIL_TIMING
  wire C_delay;
  wire D1_delay;
  wire D2_delay;
`endif  
  

`ifdef XIL_TIMING
  assign C_in = C_delay ^ IS_C_INVERTED_BIN;
  assign D1_in = D1_delay ^ IS_D1_INVERTED_BIN;
  assign D2_in = D2_delay ^ IS_D2_INVERTED_BIN;
`endif
`ifndef XIL_TIMING
  assign C_in = C ^ IS_C_INVERTED_BIN;
  assign D1_in = D1 ^ IS_D1_INVERTED_BIN;
  assign D2_in = D2 ^ IS_D2_INVERTED_BIN;
`endif
  assign SR_in = SR;

  assign IS_C_INVERTED_BIN = IS_C_INVERTED_REG;

  assign IS_D1_INVERTED_BIN = IS_D1_INVERTED_REG;

  assign IS_D2_INVERTED_BIN = IS_D2_INVERTED_REG;

  assign SRVAL_BIN = SRVAL_REG;


  initial begin
    #1;
    trig_attr = ~trig_attr;
  end

  always @ (trig_attr) begin
  #1;
    if ((attr_test == 1'b1) ||
        ((SIM_DEVICE_REG != "EVEREST") &&
         (SIM_DEVICE_REG != "EVEREST_ES1") &&
         (SIM_DEVICE_REG != "EVEREST_ES2") &&
         (SIM_DEVICE_REG != "ULTRASCALE") &&
         (SIM_DEVICE_REG != "ULTRASCALE_PLUS") &&
         (SIM_DEVICE_REG != "ULTRASCALE_PLUS_ES1") &&
         (SIM_DEVICE_REG != "ULTRASCALE_PLUS_ES2"))) begin
      $display("Error: [Unisim %s-114] SIM_DEVICE attribute is set to %s.  Legal values for this attribute are EVEREST, EVEREST_ES1, EVEREST_ES2, ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1 or ULTRASCALE_PLUS_ES2. Instance: %m", MODULE_NAME, SIM_DEVICE_REG);
      attr_err = 1'b1;
    end

    if ((attr_test == 1'b1) ||
        ((SRVAL_REG !== 1'b0) && (SRVAL_REG !== 1'b1))) begin
      $display("Error: [Unisim %s-106] SRVAL attribute is set to %b.  Legal values for this attribute are 1'b0 to 1'b1. Instance: %m", MODULE_NAME, SRVAL_REG);
      attr_err = 1'b1;
    end

    if (attr_err == 1'b1) #1 $finish;
  end

`ifdef XIL_TIMING
  reg notifier;
`endif

// begin behavioral model

  reg Q_out;
  reg QD2_posedge_int;
  reg R_sync1 = 1'b0;
  reg R_sync2 = 1'b0;
  reg R_sync3 = 1'b0;
  wire R_sync;
  wire R_async;

  assign Q = Q_out;
  assign R_async = ((SIM_DEVICE_REG == "EVEREST") || (SIM_DEVICE_REG == "EVEREST_ES1") || (SIM_DEVICE_REG == "EVEREST_ES2"));
  assign R_sync = R_async ? SR_in : (R_sync1 || R_sync2 || R_sync3);

  always @(posedge C_in) begin
    if (~R_async) begin
      R_sync1 <= SR_in;
      R_sync2 <= R_sync1;
      R_sync3 <= R_sync2;
    end
  end
  
  always @ (glblGSR or SR_in or R_sync) begin
    if (glblGSR == 1'b1) begin
      assign Q_out = SRVAL_REG;
      assign QD2_posedge_int = SRVAL_REG;
    end else if (glblGSR == 1'b0) begin
      if (SR_in == 1'b1 || R_sync == 1'b1) begin
        assign Q_out = SRVAL_REG;
        assign QD2_posedge_int = SRVAL_REG;
      end else if (R_sync == 1'b0) begin
        deassign Q_out;
        deassign QD2_posedge_int;
      end
    end
  end
 
  always @(posedge C_in) begin
    if (SR_in == 1'b1 || R_sync ==1'b1) begin
      Q_out <= SRVAL_REG;
      QD2_posedge_int <= SRVAL_REG;
    end else if (R_sync == 1'b0) begin
      Q_out <= D1_in;
	   QD2_posedge_int <= D2_in;
    end
  end

  always @(negedge C_in) begin
    if (SR_in == 1'b1 || R_sync == 1'b1) begin
      Q_out <= SRVAL_REG;
    end else if (R_sync == 1'b0) begin
      Q_out <= QD2_posedge_int;
    end
  end

// end behavioral model

`ifdef XIL_TIMING
  wire c_en_n;
  wire c_en_p;
  
  assign c_en_n =  IS_C_INVERTED_BIN;
  assign c_en_p = ~IS_C_INVERTED_BIN;
`endif

  specify
    (C => Q) = (100:100:100, 100:100:100);
    (D1 => Q) = (0:0:0, 0:0:0);
    (posedge SR => (Q +: 0)) = (100:100:100, 100:100:100);
`ifdef XIL_TIMING
    $period (negedge C, 0:0:0, notifier);
    $period (posedge C, 0:0:0, notifier);
    $setuphold (negedge C, negedge D1, 0:0:0, 0:0:0, notifier, c_en_n, c_en_n, C_delay, D1_delay);
    $setuphold (negedge C, negedge D2, 0:0:0, 0:0:0, notifier, c_en_n, c_en_n, C_delay, D2_delay);
    $setuphold (negedge C, posedge D1, 0:0:0, 0:0:0, notifier, c_en_n, c_en_n, C_delay, D1_delay);
    $setuphold (negedge C, posedge D2, 0:0:0, 0:0:0, notifier, c_en_n, c_en_n, C_delay, D2_delay);
    $setuphold (posedge C, negedge D1, 0:0:0, 0:0:0, notifier, c_en_p, c_en_p, C_delay, D1_delay);
    $setuphold (posedge C, negedge D2, 0:0:0, 0:0:0, notifier, c_en_p, c_en_p, C_delay, D2_delay);
    $setuphold (posedge C, posedge D1, 0:0:0, 0:0:0, notifier, c_en_p, c_en_p, C_delay, D1_delay);
    $setuphold (posedge C, posedge D2, 0:0:0, 0:0:0, notifier, c_en_p, c_en_p, C_delay, D2_delay);
    $width (negedge C, 0:0:0, 0, notifier);
    $width (negedge SR, 0:0:0, 0, notifier);
    $width (posedge C, 0:0:0, 0, notifier);
    $width (posedge SR, 0:0:0, 0, notifier);
`endif
    specparam PATHPULSE$ = 0;
  endspecify

endmodule

`endcelldefine
