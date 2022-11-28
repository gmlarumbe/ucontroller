class uart_seq_item extends uvm_sequence_item;

    rand int         delay;
    rand bit         sbe;
    rand int         sbe_clks;
    rand logic [7:0] data;
    rand bit         fe;
    rand logic [7:0] lcr;
    rand bit         pe;
    rand logic [15:0] baud_divisor;

    // Need some constraints

    constraint BR_DIVIDE {baud_divisor == 16'h02;}

    constraint error_dists {fe dist {1:= 1, 0:=99};
        pe dist {1:= 1, 0:=99};
        sbe dist {1:=1, 0:=50};}

    constraint clks {delay inside {[0:20]};
        sbe_clks inside {[1:4]};}

    constraint lcr_setup {lcr == 8'h3f;}

    `uvm_object_utils_begin(uart_seq_item)
        `uvm_field_int(delay, UVM_ALL_ON);
        `uvm_field_int(sbe, UVM_ALL_ON);
        `uvm_field_int(sbe_clks, UVM_ALL_ON);
        `uvm_field_int(data, UVM_ALL_ON);
        `uvm_field_int(fe, UVM_ALL_ON);
        `uvm_field_int(lcr, UVM_ALL_ON);
        `uvm_field_int(pe, UVM_ALL_ON);
        `uvm_field_int(baud_divisor, UVM_ALL_ON);
    `uvm_object_utils_end

    function new(string name = "uart_seq_item",
                 uvm_sequencer_base sequencer = null,
                 uvm_sequence_base parent_sequence = null);
        super.new(name); // NOTE: [super.new(name, sequencer, parent_sequence);]
    endfunction

endclass: uart_seq_item

