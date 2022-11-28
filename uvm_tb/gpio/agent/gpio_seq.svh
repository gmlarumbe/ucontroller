class gpio_seq extends uvm_sequence #(gpio_seq_item);
    `uvm_object_utils(gpio_seq)

    rand logic [7:0] data;

    extern function new(string name = "gpio_seq");
    extern task body;

endclass:gpio_seq


function gpio_seq::new(string name = "gpio_seq");
    super.new(name);
endfunction

task gpio_seq::body;
    gpio_seq_item req;

    begin
        req = gpio_seq_item::type_id::create("req");
        start_item(req);
        if (!req.randomize()) begin
            `uvm_fatal("RND_ERROR", "Error randomizing GPIO Request");
        end
        finish_item(req);
    end

endtask : body


