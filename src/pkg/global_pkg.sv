
package global_pkg;

    //////////////////////////////////////////////////////////////////////////////-
    // Types for the RAM memory
    //////////////////////////////////////////////////////////////////////////////-

    localparam integer RAM_DEPTH = 256;


    //////////////////////////////////////////////////////////////////////////////-
    // Useful constants for addressing purposes
    //////////////////////////////////////////////////////////////////////////////-

    localparam logic [7:0] DMA_RX_BUFFER_MSB  = 'h00;
    localparam logic [7:0] DMA_RX_BUFFER_MID  = 'h01;
    localparam logic [7:0] DMA_RX_BUFFER_LSB  = 'h02;
    localparam logic [7:0] NEW_INST           = 'h03;
    localparam logic [7:0] DMA_TX_BUFFER_MSB  = 'h04;
    localparam logic [7:0] DMA_TX_BUFFER_LSB  = 'h05;
    localparam logic [7:0] SWITCH_BASE        = 'h10;
    localparam logic [7:0] LEVER_BASE         = 'h20;
    localparam logic [7:0] CAL_OP             = 'h30;
    localparam logic [7:0] T_STAT             = 'h31;
    localparam logic [7:0] GP_RAM_BASE        = 'h40;

    // //////////////////////////////////////////////////////////////////////////////-
    // // Constants to define Type 1 instructions (ALU)
    // //////////////////////////////////////////////////////////////////////////////-

    // localparam TYPE_1        logic [1:0] = 'b00';
    // localparam ALU_ADD       logic [5:0] = 'b000000';
    // localparam ALU_SUB       logic [5:0] = 'b000001';
    // localparam ALU_SHIFTL    logic [5:0] = 'b000010';
    // localparam ALU_SHIFTR    logic [5:0] = 'b000011';
    // localparam ALU_AND       logic [5:0] = 'b000100';
    // localparam ALU_OR        logic [5:0] = 'b000101';
    // localparam ALU_XOR       logic [5:0] = 'b000110';
    // localparam ALU_CMPE      logic [5:0] = 'b000111';
    // localparam ALU_CMPG      logic [5:0] = 'b001000';
    // localparam ALU_CMPL      logic [5:0] = 'b001001';
    // localparam ALU_ASCII2BIN logic [5:0] = 'b001010';
    // localparam ALU_BIN2ASCII logic [5:0] = 'b001011';

    // //////////////////////////////////////////////////////////////////////////////-
    // // Constants to define Type 2 instructions (JUMP)
    // //////////////////////////////////////////////////////////////////////////////-

    // localparam TYPE_2     logic [1:0] = 'b01';
    // localparam JMP_UNCOND logic [5:0] = 'b000000';
    // localparam JMP_COND   logic [5:0] = 'b000001';

    // //////////////////////////////////////////////////////////////////////////////-
    // // Constants to define Type 3 instructions (LOAD & STORE)
    // //////////////////////////////////////////////////////////////////////////////-

    // localparam TYPE_3        logic [1:0] = 'b10';
    // // instruction
    // localparam L             logic = 'b0';
    // localparam WR            logic = 'b1';
    // // source
    // localparam SRC_ACC       logic [1:0] = 'b00';
    // localparam SRC_CONSTANT  logic [1:0] = 'b01';
    // localparam SRC_MEM       logic [1:0] = 'b10';
    // localparam SRC_INDXD_MEM logic [1:0] = 'b11';
    // // destination
    // localparam DST_ACC       logic [2:0] = 'b000';
    // localparam DST_A         logic [2:0] = 'b001';
    // localparam DST_B         logic [2:0] = 'b010';
    // localparam DST_INDX      logic [2:0] = 'b011';
    // localparam DST_MEM       logic [2:0] = 'b100';
    // localparam DST_INDXD_MEM logic [2:0] = 'b101';


    // //////////////////////////////////////////////////////////////////////////////-
    // // Constantes utilizadas en los CASEs para evitar warnings (valores sin &)
    // //////////////////////////////////////////////////////////////////////////////-


    // localparam LD_SRC_CONSTANT     logic [2:0] = 'b001';
    // localparam LD_SRC_MEM          logic [2:0] = 'b010';
    // localparam LD_SRC_INDXD_MEM    logic [2:0] = 'b011';
    // localparam WR_SRC_ACC          logic [2:0] = 'b100';

    // //////////////////////////////////////////////////////////////////////////////-
    // // Constants to define Type 4 instructions (SEND)
    // //////////////////////////////////////////////////////////////////////////////-

    // localparam TYPE_4        : [1:0] := 'b11';

    // //////////////////////////////////////////////////////////////////////////////-
    // // Type containing the ALU instruction set
    // //////////////////////////////////////////////////////////////////////////////-


    typedef enum logic[4:0] {
                 nop,                                  // no operation
                 op_lda, op_ldb, op_ldacc, op_ldid,    // external value load
                 op_mvacc2id, op_mvacc2a, op_mvacc2b,  // internal load
                 op_add, op_sub, op_shiftl, op_shiftr, // arithmetic operations
                 op_and, op_or, op_xor,                // logic operations
                 op_cmpe, op_cmpl, op_cmpg,            // compare operations
                 op_ascii2bin, op_bin2ascii,           // conversion operations
                 op_oeacc                              // output enable
                 } alu_op;


endpackage: global_pkg



