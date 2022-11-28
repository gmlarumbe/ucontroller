class gpio_agent extends uvm_component;
    `uvm_component_utils(gpio_agent)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    gpio_agent_config m_cfg;

    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(gpio_seq_item) ap;
    uvm_analysis_port #(gpio_seq_item) ext_ap;

    gpio_monitor   m_monitor;
    gpio_sequencer m_sequencer;
    gpio_driver    m_driver;
    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "gpio_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: gpio_agent


function gpio_agent::new(string name = "gpio_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void gpio_agent::build_phase(uvm_phase phase);
    if (!(uvm_config_db #(gpio_agent_config)::get(this, "*", "gpio_agent_config", m_cfg))) begin
        `uvm_fatal(get_name(), $sformatf("Error fetching config for gpio_agent_config"))
    end
    // Monitor is always present
    m_monitor = gpio_monitor::type_id::create("m_monitor", this);
    m_monitor.m_cfg = m_cfg;
    // Only build the driver and sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
        m_driver = gpio_driver::type_id::create("m_driver", this);
        m_driver.m_cfg = m_cfg;
        m_sequencer = gpio_sequencer::type_id::create("m_sequencer", this);
    end
endfunction: build_phase

function void gpio_agent::connect_phase(uvm_phase phase);
    ap = m_monitor.ap;
    if(m_cfg.monitor_external_clock == 1) begin
        ext_ap = m_monitor.ext_ap;
    end
    // Only connect the driver and the sequencer if active
    if(m_cfg.active == UVM_ACTIVE) begin
        m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
endfunction: connect_phase
