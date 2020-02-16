import global_pkg::*;

module tb_alu () ;

    // Simulation parameters
    timeprecision 1ps;
    timeunit      1ns;
    localparam CLKT = 10ns;  // 100 MHz

    logic 	Clk   = 1'b0;
    logic 	Rst_n = 1'b1;

    logic [7:0] InData;
    logic [7:0] OutData;
    logic 	FlagC;
    logic 	FlagE;
    logic 	FlagN;
    logic 	FlagZ;

    alu_op ALU_op;

    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end

    // DUT
    alu DUT (
        .Clk           (Clk),
        .Rst_n         (Rst_n),
        .ALU_op        (ALU_op),
        .InData        (InData),
        .OutData       (OutData),
        .FlagZ         (FlagZ),
        .FlagC         (FlagC),
        .FlagN         (FlagN),
        .FlagE         (FlagE)
        );


    // Tasks
    task reset_system;
        repeat (10) @(posedge Clk);
        Rst_n = 0;
        repeat (10) @(posedge Clk);
        Rst_n = 1;
        repeat (10) @(posedge Clk);
    endtask : reset_system


    task execute_instruction (input alu_op inst, input logic[7:0] DATA = 'h0);
        localparam integer CYCLES = 10;
        repeat (CYCLES) @(posedge Clk);
        ALU_op = inst;
        InData = DATA;
        repeat (CYCLES) @(posedge Clk);
    endtask : execute_instruction


    task do_sum (input logic [7:0] sumA, input logic [7:0] sumB);
        execute_instruction(nop);
        execute_instruction(op_lda, sumA);
        execute_instruction(op_ldb, sumB);
        execute_instruction(op_add);
        execute_instruction(op_oeacc);
        assert (OutData == sumA + sumB);
        execute_instruction(nop);
    endtask: do_sum


    task do_sub (input logic [7:0] subA, input logic [7:0] subB);
        execute_instruction(nop);
        execute_instruction(op_lda, subA);
        execute_instruction(op_ldb, subB);
        execute_instruction(op_sub);
        execute_instruction(op_oeacc);
        assert (OutData == subA - subB);
        execute_instruction(nop);
    endtask: do_sub


    task do_and (input logic [7:0] andA, input logic [7:0] andB);
        execute_instruction(nop);
        execute_instruction(op_lda, andA);
        execute_instruction(op_ldb, andB);
        execute_instruction(op_and);
        execute_instruction(op_oeacc);
        assert (OutData == (andA & andB));
        execute_instruction(nop);
    endtask: do_and


    task do_or (input logic [7:0] orA, input logic [7:0] orB);
        execute_instruction(nop);
        execute_instruction(op_lda, orA);
        execute_instruction(op_ldb, orB);
        execute_instruction(op_or);
        execute_instruction(op_oeacc);
        assert (OutData == (orA | orB));
        execute_instruction(nop);
    endtask: do_or


    task do_xor (input logic [7:0] xorA, input logic [7:0] xorB);
        execute_instruction(nop);
        execute_instruction(op_lda, xorA);
        execute_instruction(op_ldb, xorB);
        execute_instruction(op_xor);
        execute_instruction(op_oeacc);
        assert (OutData == (xorA ^ xorB));
        execute_instruction(nop);
    endtask: do_xor


    // === TB Setup === \\
    //$timeformat params:
    //1) Scaling factor (–9 for nanoseconds, –12 for picoseconds)
    //2) Number of digits to the right of the decimal point
    //3) A string to print after the time value
    //4) Minimum field width
    initial begin
        $dumpfile("tb_alu.lx2");  // iverilog, vpp & gtkwave
        $dumpvars(0, tb_alu);     // Module Output file
        $timeformat(-9, 3, "ns", 8);
    end


    // Stimuli
    initial begin
        reset_system;
        do_sum('h1, 'h1);
        do_sum('h3, 'h2);
        do_sum('hA, 'hA);
        do_sum('hFF, 'h02);

        do_sub('h1, 'h1);
        do_sub('h5, 'h0);
        do_sub('h5, 'h6);
        do_sub('h10, 'h10);

        do_and('hFF, 'h88);
        do_or('h77, 'hCC);
        do_xor('hF0, 'h0F);

        $display("@%0d: TEST PASSED", $time);
        $finish;
    end


endmodule // tb_alu
