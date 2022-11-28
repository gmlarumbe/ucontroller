class gpio_seq_item extends uvm_sequence_item;
    `uvm_object_utils(gpio_seq_item)

    rand logic [7:0] gpio;

    //------------------------------------------
    // Methods
    //------------------------------------------
    extern function new(string name = "gpio_seq_item");
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
    extern function void do_print(uvm_printer printer);
    extern function void do_record(uvm_recorder recorder);

endclass : gpio_seq_item


function gpio_seq_item::new(string name = "gpio_seq_item");
    super.new(name);
endfunction


function void gpio_seq_item::do_copy(uvm_object rhs);
    gpio_seq_item rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs);
    gpio = rhs_.gpio;

endfunction:do_copy


function bit gpio_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    gpio_seq_item rhs_;
    bit equals;

    if(!$cast(rhs_, rhs)) begin
        `uvm_error("do_copy", "cast of rhs object failed")
        return 0;
    end
    equals = super.do_compare(rhs, comparer) && (gpio == rhs_.gpio);
    return equals;

endfunction:do_compare


function string gpio_seq_item::convert2string();
    string s;

    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s gpio:%0h\n", s, gpio);
    return s;

endfunction:convert2string


function void gpio_seq_item::do_print(uvm_printer printer);
    printer.m_string = convert2string();
endfunction:do_print


function void gpio_seq_item::do_record(uvm_recorder recorder);
    super.do_record(recorder);

    // Use the record macros to record the item fields:
    `uvm_record_field("gpio", gpio)

endfunction:do_record
