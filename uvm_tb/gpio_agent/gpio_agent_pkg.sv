package gpio_agent_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // `include "config_macro.svh"

    `include "gpio_seq_item.svh"
    `include "gpio_agent_config.svh"
    `include "gpio_driver.svh"
    `include "gpio_monitor.svh"
    typedef uvm_sequencer#(gpio_seq_item) gpio_sequencer;
    `include "gpio_agent.svh"

    // Utility Sequences
    `include "gpio_seq.svh"

endpackage: gpio_agent_pkg
