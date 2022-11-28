interface uart_driver_bfm (
    output logic sdata,
    input  logic sclk
);

    import uart_agent_pkg::*;

    //------------------------------------------
    // Data Members
    //------------------------------------------

    //------------------------------------------
    // Methods
    //------------------------------------------

    uart_seq_item pkt;

    bit clk;
    logic[15:0] divisor;

    task clk_gen;
        clk = 0;
        divisor = 4;
        forever
            begin
                repeat(divisor)
                    @(posedge sclk);
                clk = ~clk;
            end
    endtask: clk_gen

    function void clear_sigs();
        sdata <= 1;
    endfunction : clear_sigs

    task send_pkt(uart_seq_item pkt);
        // Receives a character according to the appropriate word format
        static integer bitPtr = 0;

        divisor = pkt.baud_divisor;
        // Variable delay
        repeat(pkt.delay)
            @(posedge clk);
        if (pkt.sbe)
            begin
                sdata <= 0;
                repeat(pkt.sbe_clks)
                    @(posedge clk);
                sdata <= 1;
                repeat(pkt.sbe_clks)
                    @(posedge clk);
            end
        // Start bit
        sdata <= 0;
        bitPtr = 0;
        bitPeriod;
        // Data bits 0 to 4
        while(bitPtr < 5)
            begin
                sdata <= pkt.data[bitPtr];
                bitPeriod;
                bitPtr++;
            end
        // Data bits 5 to 7
        if (pkt.lcr[1:0] > 2'b00)
            begin
                sdata <= pkt.data[5];
                bitPeriod;
            end
        if (pkt.lcr[1:0] > 2'b01)
            begin
                sdata <= pkt.data[6];
                bitPeriod;
            end
        if (pkt.lcr[1:0] > 2'b10)
            begin
                sdata <= pkt.data[7];
                bitPeriod;
            end
        // Parity
        if (pkt.lcr[3])
            begin
                sdata <= logic'(calParity(pkt.lcr, pkt.data));
                if (pkt.pe)
                    sdata <= ~sdata;
                bitPeriod;
            end
        // Stop bit
        if (!pkt.fe)
            sdata <= 1;
        else
            sdata <= 0;
        bitPeriod;
        if (!pkt.fe)
            begin
                if (pkt.lcr[2])
                    begin
                        if (pkt.lcr[1:0] == 2'b00)
                            begin
                                repeat(8)
                                    @(posedge clk);
                            end
                        else
                            bitPeriod;
                    end
            end
        else
            begin
                sdata <= 1;
                bitPeriod;
            end // else: !if(!pkt.fe)
    endtask : send_pkt

    task bitPeriod;
        begin
            repeat(16)
                @(posedge clk);
        end
    endtask: bitPeriod

endinterface: uart_driver_bfm
