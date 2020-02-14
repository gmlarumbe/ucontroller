import global_pkg::*;

module ram (
    input logic        Clk,
    input logic        Rst_n,
    input logic        Cs,
    input logic        Wen,
    input logic        Oen,
    input logic [7:0]  Address,
    input logic [7:0]  DataIn,
    output logic [7:0] DataOut,
    output logic [7:0] Switches,
    output logic [7:0] Temp
    );

    logic 	Cs_gp;
    logic 	Cs_regs;
    logic [7:0] DataOut_gp;
    logic [7:0] DataOut_regs;

    gp_ram I_GP_RAM (
        .Clk     (Clk),
        .Rst_n   (Rst_n),
        .Cs      (Cs_gp),
        .Wen     (Wen),
        .Oen     (Oen),
        .Address (Address),
        .DataIn  (DataIn),
        .DataOut (DataOut_gp)
        );


    regs_ram I_REGS_RAM (
        .Clk      (Clk),
        .Rst_n    (Rst_n),
        .Cs       (Cs_regs),
        .Wen      (Wen),
        .Oen      (Oen),
        .Address  (Address),
        .DataIn   (DataIn),
        .DataOut  (DataOut_regs),
        .Switches (Switches),
        .Temp	  (Temp)
        );


    always_comb begin
	if (Address < GP_RAM_BASE) begin
	    DataOut = DataOut_regs;
	    Cs_regs = Cs;
	    Cs_gp   = 1'b0;
	end
	else begin
	    DataOut = DataOut_gp;
	    Cs_regs = 1'b0;
	    Cs_gp   = Cs;
	end
    end


endmodule
