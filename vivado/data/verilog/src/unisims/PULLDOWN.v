///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2009 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 10.1
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  Resistor to GND
// /___/   /\     Filename : PULLDOWN.v
// \   \  /  \    Timestamp : Thu Mar 25 16:43:32 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/23/07 - Changed timescale to 1 ps / 1 ps.
//    05/23/07 - Added wire declaration for internal signals.

`timescale  1 ps / 1 ps


`celldefine

module PULLDOWN (O);


`ifdef XIL_TIMING

    parameter LOC = "UNPLACED";

`endif


    output O;

    wire A;

    pulldown (A);
    buf (weak0,weak1) #(100,100) (O,A);

endmodule

`endcelldefine

