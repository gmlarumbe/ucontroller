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
        ROM[0] = {TYPE_1, ALU_ADD};
        ROM[1] = {TYPE_1, ALU_SUB};
        ROM[2] = {TYPE_1, ALU_SHIFTL};
        ROM[3] = {TYPE_1, ALU_SHIFTR};
        ROM[4] = {TYPE_1, ALU_AND};
        ROM[5] = {TYPE_1, ALU_OR};
        ROM[6] = {TYPE_1, ALU_CMPE};
        ROM[7] = {TYPE_1, ALU_CMPG};
        ROM[8] = {TYPE_1, ALU_CMPL};
        ROM[9] = {TYPE_1, ALU_ASCII2BIN};
        ROM[10] = {TYPE_1, ALU_BIN2ASCII};
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



    initial begin
        init_rom;
        reset_system;
        $display("Starting simulation...");

        repeat (100) @(posedge Clk);

        $finish;
    end


endmodule: tb_program
