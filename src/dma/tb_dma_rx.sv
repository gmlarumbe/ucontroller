
module tb_dma_rx () ;

    // Simulation parameters
    timeprecision 1ps;
    timeunit      1ns;
    localparam CLKT = 10ns;  // 100 MHz

    localparam logic [31:0] FREQ_CLK = 100000000;
    localparam logic [31:0] TX_SPEED = 115200;
    localparam integer BIT_CYCLES = FREQ_CLK / TX_SPEED;

    // Non-auto signals
    logic       Clk   = 1'b0;
    logic       Rst_n = 1'b1;

    /* DUT Inputs */
    logic       RXD       = 1'b1;
    logic       Bus_grant = 1'b0;
    logic       Ena       = 1'b0;

    // INFO: Unisims library force these signals to be declared as nets
    wire  [7:0] RX_Data;
    wire        RX_Empty;
    wire        RX_Full;

    /* DUT Outputs */
    logic [7:0] Address;
    logic [7:0] Databus;
    logic       Bus_req;
    logic       Cs;
    logic       Data_Read;
    logic       Wena;


    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end

    // DUT Instantiation
    dma_rx I_DMA_RX (
        // Inputs
        .Clk       (Clk),
        .Rst_n     (Rst_n),
        .Ena       (Ena),
        .RX_Data   (RX_Data),
        .RX_Full   (RX_Full),
        .RX_Empty  (RX_Empty),
        .Bus_grant (Bus_grant),
        // Outputs
        .Address   (Address),
        .Databus   (Databus),
        .Data_Read (Data_Read),
        .Cs        (Cs),
        .Wena      (Wena),
        .Bus_req   (Bus_req)
        );


    uart # (
        .FREQ_CLK (FREQ_CLK),
        .TX_SPEED (TX_SPEED)
        ) I_UART (
        .Clk       (Clk),
        .Rst_n     (Rst_n),
        .Data_Read (Data_Read),
        .Data_Out  (RX_Data),
        .Full      (RX_Full),
        .Empty     (RX_Empty),
        .RXD       (RXD),
        // TX Interface not relevant for this testbench
        .TX_Valid  (),
        .TX_DataIn (),
        .TX_Ready  (),
        .TXD       ()
        );



    // Tasks
    task reset_system;
        repeat (10) @(posedge Clk);
        Rst_n = 0;
        repeat (10) @(posedge Clk);
        Rst_n = 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system


    task serial_rx (input logic [7:0] Data);
        @(posedge Clk);
        // Start bit
        RXD = 1'b0;
        repeat (BIT_CYCLES) @(posedge Clk);
        // Data bits
        for (int i=0; i<8; ++i) begin
            RXD = Data[i];
            repeat (BIT_CYCLES) @(posedge Clk);
        end
        // Stop bit
        RXD = 1'b1;
        repeat (BIT_CYCLES) @(posedge Clk);
        // Wrapup
        $display("@%0d: End of Serial RX", $time);
        @(posedge Clk); // Resync
    endtask: serial_rx


    task receive_1byte ();
        Bus_grant <= 1'b0;
        @(posedge Clk);
        serial_rx('h77);
        repeat (3000) @(posedge Clk);
        Bus_grant <= 1'b1;
        repeat (30) @(posedge Clk);
    endtask: receive_1byte


    task receive_2bytes ();
        Bus_grant <= 1'b0;
        @(posedge Clk);
        serial_rx('h55);
        repeat (3000) @(posedge Clk);
        serial_rx('h55);
        repeat (3000) @(posedge Clk);
        Bus_grant <= 1'b1;
        repeat (30) @(posedge Clk);
    endtask: receive_2bytes


    task receive_3bytes ();
        Bus_grant <= 1'b0;
        @(posedge Clk);
        serial_rx('hAA);
        repeat (3000) @(posedge Clk);
        serial_rx('h03);
        repeat (3000) @(posedge Clk);
        serial_rx('hCC);
        repeat (3000) @(posedge Clk);
        Bus_grant <= 1'b1;
        repeat (30) @(posedge Clk);
    endtask: receive_3bytes


    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_dma_rx.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_dma_rx);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end


    // Stimuli
    initial begin
        reset_system;

        @(posedge Clk);
        Ena <= 1'b1;
        repeat (10) @(posedge Clk);

	receive_1byte;
	receive_2bytes;
	receive_3bytes;
	
        repeat (150) @(posedge Clk);
        $display("@%0d: TEST PASSED", $time);
        $finish;
    end


endmodule // tb_dma_rx
