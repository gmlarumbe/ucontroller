import global_pkg::*;

module automatic tb_program (
    input logic         Clk,
    output logic        Rst_n,
    output logic        RXD,
    input logic         TXD,
    input logic [7:0]   Temp,
    input logic [7:0]   Switches,
    output logic [11:0] ROM_Data,
    input logic [11:0]  ROM_Addr
    );

    timeprecision 1ps;
    timeunit      1ns;

    localparam logic [31:0] FREQ_CLK = 100000000;
    localparam logic [31:0] TX_SPEED = 115200;
    localparam integer BIT_CYCLES = FREQ_CLK / TX_SPEED;

    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_top.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_top);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end


    // ROM Model
    logic [11:0] ROM [4096];
    assign ROM_Data = ROM[ROM_Addr];

    task init_rom ();
        $display("@%0d: Initializing ROM", $time);
        // Sum 2 and 3
        ROM['h0]  = {TYPE_3, LD_SRC_CONSTANT, DST_A}; // LD #2 Ra
        ROM['h1]  = 8'h2;
        ROM['h2]  = {TYPE_3, LD_SRC_CONSTANT, DST_B}; // LD #3 Rb
        ROM['h3]  = 8'h3;
        ROM['h4]  = {TYPE_1, ALU_ADD};
        // And store result in memory addres 0x40
        ROM['h5]  = {TYPE_3, WR_SRC_ACC, DST_MEM}; // MV Acc #40
        ROM['h6]  = 8'h40;
        // Readback from address 0x40
        ROM['h7]  = {TYPE_3, LD_SRC_MEM, DST_A}; // LD  0x40 Ra
        ROM['h8]  = 8'h40;
        // Shift operations (acc)
        ROM['h9]  = {TYPE_1, ALU_SHIFTL}; // SHL
        ROM['hA]  = {TYPE_1, ALU_SHIFTR}; // SHR
        // Jump to address 0x30
        ROM['hB] = {TYPE_1, ALU_ASCII2BIN};
        ROM['hC] = {TYPE_1, ALU_BIN2ASCII};
        ROM['hD] = {TYPE_1, ALU_AND};
        ROM['hE] = {TYPE_2, JMP_UNCOND};
        ROM['hF] = 8'h20;

        // BUG: Iverilog freezes if infinite main loop is inferred
        // ROM['h20] = {TYPE_2, JMP_UNCOND};
        // ROM['h21] = 8'h0;
        // BUG: Iverilog also hangs for DMA_TX requests
        // ROM['h20] = {TYPE_4, 6'h0};

    endtask: init_rom


    // Tasks
    task init_values;
        RXD = 1'b1;
    endtask : init_values


    task reset_system;
        init_values;
        repeat (10) @(posedge Clk);
        Rst_n <= 0;
        repeat (10) @(posedge Clk);
        Rst_n <= 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system


    // RX DMA - UART to Memory
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


    initial begin
        init_rom;
        reset_system;
        $display("Starting simulation...");
        serial_rx('hAB);
        serial_rx('hCD);
        repeat (1000) @(posedge Clk);
        $finish;
    end


    initial begin
        #10ms;
        $display("@%0d: Timeout occurred", $time);
        $finish();
    end


endmodule: tb_program
