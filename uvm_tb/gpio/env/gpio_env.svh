class gpio_env extends uvm_env;
    `uvm_component_utils(gpio_env)

    gpio_agent m_temp_agent;
    gpio_agent m_switches_agent;
    gpio_env_config m_cfg;

    // Standard UVM Methods:
    extern function new(string name = "gpio_env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass:gpio_env


function gpio_env::new(string name = "gpio_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void gpio_env::build_phase(uvm_phase phase);
    if (!uvm_config_db #(gpio_env_config)::get(this, "", "gpio_env_config", m_cfg)) begin
        `uvm_fatal("CONFIG_LOAD", "Cannot get() configuration gpio_env_config from uvm_config_db. Have you set() it?")
    end
    if(m_cfg.has_GPO_agent) begin
        uvm_config_db #(gpio_agent_config)::set(this,"m_GPO_agent*", "gpio_agent_config", m_cfg.m_GPO_agent_cfg);
        m_GPO_agent = gpio_agent::type_id::create("m_GPO_agent", this);
    end
    end
endfunction:build_phase


function void gpio_env::connect_phase(uvm_phase phase);


endfunction: connect_phase

