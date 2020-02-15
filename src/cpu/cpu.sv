import global_pkg::*;

module cpu (
    input logic         Clk,
    input logic         Rst_n,

    input logic [11:0]  ROM_Data,
    output logic [11:0] ROM_Addr,

    output logic [7:0]  Databus,
    output logic [7:0]  RAM_Addr,
    output logic        RAM_Cs,
    output logic        RAM_Wen,
    output logic        RAM_Oen,

    input logic         DMA_Req,
    output logic        DMA_Ack,
    output logic        DMA_Tx_Start,
    input logic         DMA_Ready,

    output alu_op       ALU_op,
    input logic         FlagZ,
    input logic         FlagC,
    input logic         FlagN,
    input logic         FlagE
    );

    typedef enum logic[1:0] {
                 IDLE,
                 FETCH,
                 DECODE,
                 EXECUTE
                 } state_t;

    state_t state, next_state;

    logic        pc_ena;
    logic        load_inst;
    logic        load_inst_auxbyte;
    logic [11:0] rom_instruction;
    logic [11:0] rom_aux;
    logic [11:0] addr;
    logic [11:0] addr_aux;



    always_comb begin

        Databus           = 'h0;
        RAM_Addr          = 'h0;
        RAM_Cs            = 1'b0;
        RAM_Wen           = 1'b0;
        RAM_Oen           = 1'b1;
        DMA_Ack           = 1'b0;
        DMA_Tx_Start      = 1'b0;
        ALU_op            = nop;

        pc_ena            = 1'b0;
        load_inst         = 1'b0;
        load_inst_auxbyte = 1'b0;

        unique case (state)
            IDLE : begin
                if (DMA_Req) begin
                    DMA_Ack = 1'b1;
                    Databus = 'h0;
                    next_state = IDLE;
                end
                else begin
                    next_state = FETCH;
                end
            end


            FETCH : begin
                load_inst = 1'b1;
                next_state = DECODE;
            end


            DECODE : begin
                unique case (rom_instruction[7:6])

                    TYPE_1 : begin
                        case (rom_instruction[5:0])
                            ALU_ADD       : ALU_op = op_add;
                            ALU_SUB       : ALU_op = op_sub;
                            ALU_SHIFTL    : ALU_op = op_shiftl;
                            ALU_SHIFTR    : ALU_op = op_shiftr;
                            ALU_AND       : ALU_op = op_and;
                            ALU_OR        : ALU_op = op_or;
                            ALU_XOR       : ALU_op = op_xor;
                            ALU_CMPE      : ALU_op = op_cmpe;
                            ALU_CMPG      : ALU_op = op_cmpg;
                            ALU_CMPL      : ALU_op = op_cmpl;
                            ALU_ASCII2BIN : ALU_op = op_ascii2bin;
                            ALU_BIN2ASCII : ALU_op = op_bin2ascii;
                            default       : ;
                        endcase
                        pc_ena = 1'b1;
                        addr = addr_aux + 12'h001;
                        next_state = IDLE;
                    end

                    TYPE_2 : begin
                        pc_ena = 1'b1;
                        addr = addr_aux + 12'h1;
                        load_inst_auxbyte = 1'b1;
                        next_state = EXECUTE;
                    end

                    TYPE_3 : begin
                        if (rom_instruction[5:3] == {LD, SRC_ACC}) begin
			    
                            unique case (rom_instruction[2:0])
                                DST_A    : ALU_op = op_mvacc2a;
                                DST_B    : ALU_op = op_mvacc2b;
                                DST_INDX : ALU_op = op_mvacc2id;
                                default  : ;
                            endcase
			    
                            pc_ena = 1'b1;
                            addr = addr_aux + 12'h001;
                            next_state = IDLE;
                        end

                        else begin
                            pc_ena = 1'b1;
                            addr = addr_aux + 12'h001;
                            load_inst_auxbyte = 1'b1;
                            next_state = EXECUTE;
                        end
                    end

                    TYPE_4 : begin

                        unique case (rom_instruction[5:0])
                            6'b000000 : begin
                                pc_ena = 1'b1;
                                addr = addr_aux + 12'h001;
                                DMA_Tx_Start = 1'b1;
                                next_state = IDLE;
                            end
                            default : begin
                            end
                        endcase
                    end

                    default : ;
                endcase
            end


            EXECUTE : begin
                if (rom_instruction[7:6] == TYPE_2) begin

                    unique case (rom_instruction[5:0])
                        JMP_UNCOND : begin
                            pc_ena = 1'b1;
                            addr = rom_aux;
                        end
                        JMP_COND : begin
                            if (FlagZ) begin
                                pc_ena = 1'b1;
                                addr = rom_aux;
                            end
                            else begin
                                pc_ena = 1'b1;
                                addr = addr_aux + 12'h001;
                            end
                        end
                        default : ;
                    endcase
                    next_state = IDLE;
                end


                if (rom_instruction[7:6] == TYPE_3) begin
                    unique case (rom_instruction[5:3])
                        LD_SRC_CONSTANT : begin
                            unique case (rom_instruction[2:0])
                                DST_A : begin
                                    Databus = rom_aux[7:0];
                                    ALU_op = op_lda;
                                end
                                DST_B : begin
                                    Databus = rom_aux[7:0];
                                    ALU_op = op_ldb;
                                end
                                DST_ACC : begin
                                    Databus = rom_aux[7:0];
                                    ALU_op = op_ldacc;
                                end
                                DST_INDX : begin
                                    Databus = rom_aux[7:0];
                                    ALU_op = op_ldid;
                                end
                                default : begin
                                    pc_ena = 1'b1;
                                    addr = addr_aux + 12'h001;
                                    next_state = IDLE;
                                end
                            endcase
                        end

                        LD_SRC_MEM : begin
                            unique case (rom_instruction[2:0])
                                DST_ACC : begin
                                    RAM_Cs = 1'b1;
                                    RAM_Oen = 1'b1;
                                    RAM_Addr = rom_aux[7:0];
                                    ALU_op = op_ldacc;
                                end
                                DST_A : begin
                                    RAM_Cs = 1'b1;
                                    RAM_Oen = 1'b1;
                                    RAM_Addr = rom_aux[7:0];
                                    ALU_op = op_lda;
                                end
                                DST_B : begin
                                    RAM_Cs = 1'b1;
                                    RAM_Oen = 1'b1;
                                    RAM_Addr = rom_aux[7:0];
                                    ALU_op = op_ldb;
                                end
                                DST_INDX : begin
                                    RAM_Cs = 1'b1;
                                    RAM_Oen = 1'b1;
                                    RAM_Addr = rom_aux[7:0];
                                    ALU_op = op_ldid;
                                end
                                default : begin
                                    pc_ena = 1'b1;
                                    addr = addr_aux + 12'h001;
                                    next_state = IDLE;
                                end
                            endcase

                        end

                        WR_SRC_ACC : begin
                            unique case (rom_instruction[2:0])
                                DST_MEM : begin
                                    RAM_Cs = 1'b1;
                                    RAM_Wen = 1'b1;
                                    RAM_Addr = rom_aux[7:0];
                                end
                                default : begin
                                    pc_ena = 1'b1;
                                    addr = addr_aux + 12'h001;
                                    next_state = IDLE;
                                end
                            endcase
                        end
                        default : ;
                    endcase
                end
            end
        endcase
    end



    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            ROM_Addr <= 'h0;
            addr_aux <= 'h0;
        end else if (pc_ena) begin
            ROM_Addr <= addr;
            addr_aux <= addr;
        end
    end


    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            rom_instruction <= 'h0;
        end else if (load_inst) begin
            rom_instruction <= ROM_Data;
        end
    end


    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            rom_aux <= 'h0;
        end else if (load_inst_auxbyte) begin
            rom_aux <= ROM_Data;
        end
    end


    always_ff @(posedge Clk) begin
        if (!Rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end


endmodule
