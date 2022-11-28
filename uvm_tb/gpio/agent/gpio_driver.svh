class gpio_driver extends uvm_driver #(gpio_seq_item);
    `uvm_component_utils(gpio_driver)

    // Virtual Interface
    virtual gpio_driver_bfm m_bfm;

    //------------------------------------------
    // Data Members
    //------------------------------------------
    gpio_agent_config m_cfg;

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "gpio_driver", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass: gpio_driver


function gpio_driver::new(string name = "gpio_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction : new


function void gpio_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!(uvm_config_db #(gpio_agent_config)::get(this, "*", "gpio_agent_config", m_cfg))) begin
        `uvm_fatal(get_name(), $sformatf("Error fetching config for gpio_agent_config"))
    end
    m_bfm = m_cfg.drv_bfm;
endfunction : build_phase


task gpio_driver::run_phase(uvm_phase phase);
    gpio_seq_item req;

    m_bfm.clear_sigs();
    forever begin
        seq_item_port.get_next_item(req);
        m_bfm.drive(req);
        seq_item_port.item_done();
    end

endtask: run_phase
