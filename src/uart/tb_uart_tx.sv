module tb_uart_tx () ;

    // Simulation parameters
    timeprecision 1ps;
    timeunit      1ns;
    localparam CLKT = 10ns;
    localparam logic [31:0] FREQ_CLK=100000000;
    localparam logic [31:0] TX_SPEED=115200;

    // Signals
    logic Clk = 1'b0;
    logic Rst_n = 1'b1;
    logic [7:0] TXData = '0;
    logic Start = 1'b0;
    logic EOT;
    logic TXD;

    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end


    // DUT Instantiation
    uart_tx # (
        .FREQ_CLK (FREQ_CLK),
        .TX_SPEED (TX_SPEED)
        ) DUT (
        .Clk   (Clk),
        .Rst_n (Rst_n),
        .Data  (Data),
        .Start (Start),
        .EOT   (EOT),
        .TX    (TX)
        );


    // Tasks
    task reset_system;
        repeat (10) @(posedge Clk);
        Rst_n = 0;
        repeat (10) @(posedge Clk);
        Rst_n = 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system


    task serial_tx (input logic [7:0] Data);
        TXData = Data;
        Start = 1'b1;
        @(posedge Clk);
        Start = 1'b0;
        @(posedge EOT);
        $display("@%0d: End of Serial TX", $time);
        @(posedge Clk); // Resync
    endtask: serial_tx



    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_uart_tx.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_uart_tx);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end


    // Stimuli
    initial begin
        reset_system;
        repeat (3000) @(posedge Clk);
        serial_tx('hAA);
        repeat (3000) @(posedge Clk);
        serial_tx('h03);
        repeat (3000) @(posedge Clk);
        serial_tx('hCC);
        repeat (3000) @(posedge Clk);
        $display("@%0d: TEST PASSED", $time);
        $finish;
    end


endmodule // tb_uart_tx
