

module tb_clocks (
    output logic Clk
    );

    localparam CLKT = 10ns;  // 100 MHz

    // System Clock
    always begin
        #(CLKT/2) Clk = ~Clk;
    end

    // Initial clock values
    initial begin
        Clk = 0;
    end


endmodule: tb_clocks
