module tb_dma_tx () ;

    // Simulation parameters
    timeprecision 1ps;
    timeunit      1ns;
    localparam CLKT = 10ns;  // 100 MHz

    localparam logic [31:0] FREQ_CLK = 100000000;
    localparam logic [31:0] TX_SPEED = 115200;
    localparam integer BIT_CYCLES = FREQ_CLK / TX_SPEED;

    // Non-auto signals
    logic       Clk       = 1'b0;
    logic       Rst_n     = 1'b1;

    /* DUT Inputs */
    logic       Bus_grant = 1'b0;
    logic [7:0] Databus   = '0;
    logic       Ena       = 1'b0;
    logic       Start     = 1'b0;

    /* DUT Outputs */
    logic [7:0] Address;
    logic [7:0] TX_Data;
    logic       Bus_req;
    logic       Cs;
    logic       Dma_Ready;
    logic       Oen;
    logic       TX_Valid;

    logic       TXD;
    logic       TX_Ready;


    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end

    // DUT Instantiation
    dma_tx I_DMA_TX (
        // Inputs
        .Clk       (Clk),
        .Rst_n     (Rst_n),
        .Ena       (Ena),
        .Databus   (Databus),
        .TX_Ready  (TX_Ready),
        .Bus_grant (Bus_grant),
        .Start     (Start),
        // Outputs
        .Address   (Address),
        .TX_Valid  (TX_Valid),
        .TX_Data   (TX_Data),
        .Cs        (Cs),
        .Oen       (Oen),
        .Bus_req   (Bus_req),
        .Dma_Ready (Dma_Ready)
        );


    uart # (
        .FREQ_CLK (FREQ_CLK),
        .TX_SPEED (TX_SPEED)
        ) I_UART (
        .Clk       (Clk),
        .Rst_n     (Rst_n),
        .TX_Valid  (TX_Valid),
        .TX_DataIn (TX_Data),
        .TX_Ready  (TX_Ready),
        .TXD       (TXD),
        // RX Interface not relevant for this testbench
        .Data_Read (),
        .Data_Out  (),
        .Full      (),
        .Empty     (),
        .RXD       ()
        );


    // Tasks
    task reset_system;
        repeat (10) @(posedge Clk);
        Rst_n = 0;
        repeat (10) @(posedge Clk);
        Rst_n = 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system


    task start_dma;
        repeat (10) @(posedge Clk);
        Ena   <= 1'b1;
        repeat (10) @(posedge Clk);
        Start <= 1'b1;
        @(posedge Clk);
        Start <= 1'b0;
        Databus <= 'hAA;  // MSB
        repeat (10) @(posedge Clk);
    endtask: start_dma


    task get_databus;
        @(posedge Clk);
        Bus_grant <= 1'b1;
        @(posedge Clk);
        Bus_grant <= 1'b0;
        repeat (10) @(posedge Clk);
    endtask: get_databus


    task wait_msb_send_lsb;
        @(posedge TX_Ready);    // MSB
        @(posedge Clk);
        Databus <= 'hBB;
        @(posedge TX_Ready);    // LSB
    endtask: wait_msb_send_lsb


    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_dma_tx.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_dma_tx);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end

    // Stimuli
    initial begin
        reset_system;
        start_dma;
        get_databus;
        wait_msb_send_lsb;

        repeat (500) @(posedge Clk);
        repeat (500) @(posedge Clk);
        $display("@%0d: TEST PASSED", $time);
        $finish;
    end



endmodule // tb_dma_tx
