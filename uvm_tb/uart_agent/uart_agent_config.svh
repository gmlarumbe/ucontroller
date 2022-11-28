class uart_agent_config extends uvm_object;

    `uvm_object_utils(uart_agent_config)

    bit ACTIVE = 1;
    logic[7:0] lcr = 8'h3f;
    logic[15:0] baud_divisor = 16'h0004;

    // BFM Virtual Interfaces
    virtual uart_monitor_bfm mon_bfm;
    virtual uart_driver_bfm  drv_bfm;

    function new(string name = "uart_agent_config");
        super.new(name);
    endfunction

endclass: uart_agent_config
