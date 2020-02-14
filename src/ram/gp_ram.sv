import global_pkg::*;

module gp_ram (
    input logic        Clk,
    input logic        Rst_n,
    input logic        Wen,
    input logic        Oen,
    input logic        Cs,
    input logic [7:0]  Address,
    input logic [7:0]  DataIn,
    output logic [7:0] DataOut
    );


    logic [7:0] mem [RAM_DEPTH];

    always @(posedge Clk) begin
        if (!Rst_n) begin
            DataOut <= 'h0;
        end
        else if (Cs) begin
	    // Write
            if (Wen) begin
                mem[Address] <= DataIn;
	    end
	    // Read
	    else if (Oen)
                DataOut <= mem[Address];
	end
	
	else 
            DataOut <= 'h0;
    end


endmodule
