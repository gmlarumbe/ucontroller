import global_pkg::*;

module tb_cpu () ;

    // Simulation parameters
    timeprecision 1ps;
    timeunit      1ns;
    localparam CLKT = 10ns;  // 100 MHz

    // Non-auto signals
    logic Clk       = 1'b0;
    logic Rst_n     = 1'b1;

    /* DUT Inputs */
    logic DMA_Ready = '0;
    logic DMA_Req   = '0;
    logic FlagC     = '0;
    logic FlagE     = '0;
    logic FlagN     = '0;
    logic FlagZ     = '0;
    logic [11:0] ROM_Data  = '0;

    /* DUT Outputs */
    alu_op ALU_op;
    logic DMA_Ack;
    logic DMA_Tx_Start;
    logic [7:0] Databus;
    logic [7:0] RAM_Addr;
    logic RAM_Cs;
    logic RAM_Oen;
    logic RAM_Wen;
    logic [11:0] ROM_Addr;


    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end

    // DUT Instantiation
    cpu I_CPU (
        // Inputs
        .Clk          (Clk),
        .Rst_n        (Rst_n),
        .ROM_Data     (ROM_Data),
        .DMA_Req      (DMA_Req),
        .DMA_Ready    (DMA_Ready),
        .FlagZ        (FlagZ),
        .FlagC        (FlagC),
        .FlagN        (FlagN),
        .FlagE        (FlagE),
        // Interfaces
        .ALU_op       (ALU_op),
        // Outputs
        .ROM_Addr     (ROM_Addr),
        .Databus      (Databus),
        .RAM_Addr     (RAM_Addr),
        .RAM_Cs       (RAM_Cs),
        .RAM_Wen      (RAM_Wen),
        .RAM_Oen      (RAM_Oen),
        .DMA_Ack      (DMA_Ack),
        .DMA_Tx_Start (DMA_Tx_Start)
        );


    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_cpu.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_cpu);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end


    // Tasks
    task reset_system;
        repeat (10) @(posedge Clk);
        Rst_n <= 0;
        repeat (10) @(posedge Clk);
        Rst_n <= 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system

    // Stimuli
    initial begin
        reset_system;
        repeat (100) @(posedge Clk);
        $display("@%0d: TEST PASSED", $time);
        $finish;
    end


endmodule // tb_cpu