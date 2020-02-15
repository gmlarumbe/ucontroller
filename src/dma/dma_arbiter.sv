module dma_arbiter (
    input logic        Clk,
    input logic        Rst_n,
    // Input selects
    input logic        TX_Start,
    input logic        Dma_Tx_Ready,
    input logic        RX_Pending,
    input logic        Dma_Rx_End,
    // Arbitrating outputs
    output logic       Enable_tx,
    output logic       Enable_rx,
    input logic [7:0]  Address_tx,
    input logic [7:0]  Address_rx,
    output logic [7:0] Address,
    input logic        Cs_tx,
    input logic        Cs_rx,
    output logic       Cs,
    input logic        Bus_req_tx,
    input logic        Bus_req_rx,
    output logic       Bus_req
    );

    typedef enum logic [1:0] {
                 IDLE,
                 TX_ON,
                 RX_ON
                 } state_t;
    state_t state;


    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            state <= IDLE;
        end
        else begin
            unique case (state)
                IDLE: begin
                    if (TX_Start)
                        state <= TX_ON;
                    else if (RX_Pending)
                        state <= RX_ON;
                end

                TX_ON: begin
                    if (Dma_Tx_Ready)
                        state <= IDLE;
                end

                RX_ON: begin
                    if (Dma_Rx_End)
                        state <= IDLE;
                end

                default : ;
            endcase
        end
    end



    // always_comb begin
    //     unique case ({RX_Pending, TX_Start})
    //         // TX has priority over RX
    //         2'b00: arbiter = TX_ON;
    //         2'b01: arbiter = TX_ON;
    //         2'b10: arbiter = RX_ON;
    //         2'b11: arbiter = RX_ON;
    //     endcase
    // end


    assign Enable_tx = (state == TX_ON || state == IDLE) ? 1'b1 : 1'b0;
    assign Enable_rx = (state == RX_ON)                  ? 1'b1 : 1'b0;


    always_comb begin
        unique case (state)
            TX_ON: begin
                Address = Address_tx;
                Cs      = Cs_tx;
                Bus_req = Bus_req_tx;
            end

            RX_ON: begin
                Address = Address_rx;
                Cs      = Cs_rx;
                Bus_req = Bus_req_rx;
            end

            IDLE: begin
                Address = '0;
                Cs      = 1'b0;
                Bus_req = 1'b0;
            end

            default : ;

        endcase
    end


endmodule: dma_arbiter
