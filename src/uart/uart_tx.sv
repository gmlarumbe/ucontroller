module uart_tx # (
    parameter logic [31:0] FREQ_CLK=100000000,
    parameter logic [31:0] TX_SPEED=115200
    )(
    input logic       Rst_n,
    input logic       Clk,
    input logic       Start,
    input logic [7:0] Data,
    output logic      EOT,
    output logic      TX
    );

    // Params
    localparam logic [31:0] PULSE_END_OF_COUNT = FREQ_CLK / TX_SPEED;

    // Typedefs
    typedef enum logic[1:0] {
                 IDLE = 0,
                 START_BIT = 1,
                 SEND_DATA = 2,
                 STOP_BIT = 3
                 } state_t;
    state_t state, next_state;

    // Signals
    logic        load_data;
    logic [7:0]  data_reg;
    logic        bit_end;
    logic        data_send_end;
    logic        bit_ctr_ena;
    logic [31:0] period_cnt;
    logic [31:0] bit_cnt;


    // Comb FSM
    always_comb begin
        EOT = 1'b0;
        unique case (state)
            IDLE : begin
                EOT = 1'b0;
                bit_ctr_ena = 1'b0;
                if (Start) begin
                    next_state = START_BIT;
                end
                else begin
                    next_state = IDLE;
                end
            end

            START_BIT : begin
                bit_ctr_ena = 1'b1;
                load_data = 1'b1;
                if (bit_end) begin
                    next_state = SEND_DATA;
                end
                else begin
                    next_state = START_BIT;
                end
            end

            SEND_DATA : begin
                bit_ctr_ena = 1'b1;
                if (data_send_end) begin
                    next_state = STOP_BIT;
                end
                else begin
                    next_state = SEND_DATA;
                end
            end

            STOP_BIT : begin
                if (bit_end) begin
                    next_state = IDLE;
                    bit_ctr_ena = 1'b0;
                    EOT = 1'b1;
                end
                else begin
                    next_state = STOP_BIT;
                    bit_ctr_ena = 1'b1;
                end
            end

            default : begin
                next_state = state;
            end

        endcase
    end

    // TX line output
    always_comb begin
        unique case (state)
            IDLE:      TX = 1'b1;
            START_BIT: TX = 1'b0;
            SEND_DATA: TX = data_reg[bit_cnt];
            STOP_BIT:  TX = 1'b1;
            default:   TX = 1'b1;
        endcase
    end

    assign bit_end = (state != IDLE && period_cnt == PULSE_END_OF_COUNT) ? 1'b1 : 1'b0;
    assign data_send_end = (state == SEND_DATA && bit_cnt == 7 && bit_end) ? 1'b1 : 1'b0;


    // Seq FSM
    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end



    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            period_cnt <= 0;
        end
        else if (bit_ctr_ena == 1'b1) begin
            if (period_cnt == PULSE_END_OF_COUNT)
                period_cnt <= 0;
            else
                period_cnt <= period_cnt + 1;
        end
        else
            period_cnt <= 0;
    end


    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            bit_cnt <= 0;
        end else begin
            if (state == SEND_DATA) begin
                if (bit_end) begin
                    if (bit_cnt == 7)
                        bit_cnt <= 0;
                    else
                        bit_cnt <= bit_cnt + 1;
                end
            end
            else
                bit_cnt <= 0;
        end
    end



    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            data_reg <= 'h0;
        end else begin
            if (load_data == 1'b1) begin
                data_reg <= Data;
            end
            else begin
                data_reg <= 'h0;
            end
        end
    end


endmodule
