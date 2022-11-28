class gpio_env_config extends uvm_object;
    `uvm_object_utils(gpio_env_config)

    localparam string s_my_config_id = "gpio_env_config";
    localparam string s_no_config_id = "no config";
    localparam string s_my_config_type_error_id = "config type error";

    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Enables for the sub-components
    bit has_temp_agent = 1;
    bit has_switches_agent = 1;
    // Configurations for the sub_components
    gpio_agent_config m_temp_agent_cfg;
    gpio_agent_config m_switches_agent_cfg;

    //------------------------------------------
    // Methods
    //------------------------------------------
    extern task wait_for_interrupt;
    extern static function gpio_env_config get_config( uvm_component c);

    // Standard UVM Methods:
    extern function new(string name = "gpio_env_config");

endclass: gpio_env_config


// Externally declared methods
function gpio_env_config::new(string name = "gpio_env_config");
    super.new(name);
endfunction

//
// Function: get_config
//
// This method gets the my_config associated with component c. We check for
// the two kinds of error which may occur with this kind of
// operation.
//
function gpio_env_config gpio_env_config::get_config( uvm_component c );
    gpio_env_config t;

    if (!uvm_config_db #(gpio_env_config)::get(c, "", s_my_config_id, t) )
        `uvm_fatal("CONFIG_LOAD", $sformatf("Cannot get() configuration %s from uvm_config_db. Have you set() it?", s_my_config_id))

    return t;
endfunction

// Wait for interrupt:
//
task gpio_env_config::wait_for_interrupt;
    INTR.wait_for_interrupt();
endtask: wait_for_interrupt
