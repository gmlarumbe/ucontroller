package gpio_env_pkg;

    // Standard UVM import & include:
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Any further package imports:
    import apb_agent_pkg::*;
    import gpio_agent_pkg::*;
    import gpio_reg_pkg::*;

    localparam string s_my_config_id = "gpio_env_config";
    localparam string s_no_config_id = "no config";
    localparam string s_my_config_type_error_id = "config type error";

    // Includes
    `include "gpio_env_config.svh"
    `include "gpio_out_scoreboard.svh"
    `include "gpio_in_scoreboard.svh"
    `include "gpio_env.svh"

endpackage: gpio_env_pkg
