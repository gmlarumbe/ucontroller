class gpio_monitor extends uvm_component;
    `uvm_component_utils(gpio_monitor)

    // Virtual Interface
    local virtual gpio_monitor_bfm m_bfm;

    //------------------------------------------
    // Data Members
    //------------------------------------------
    gpio_agent_config m_cfg;
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(gpio_seq_item) ap;
    uvm_analysis_port #(gpio_seq_item) ext_ap;

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:

    extern function new(string name = "gpio_monitor", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    // Proxy Methods:

    extern function void notify_transaction(gpio_seq_item item);
    extern function void notify_transaction_ext_ap(gpio_seq_item item);

endclass: gpio_monitor

function gpio_monitor::new(string name = "gpio_monitor", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void gpio_monitor::build_phase(uvm_phase phase);
    if (!(uvm_config_db #(gpio_agent_config)::get(this, "*", "gpio_agent_config", m_cfg))) begin
        `uvm_fatal(get_name(), $sformatf("Error fetching config for gpio_agent_config"))
    end
    m_bfm = m_cfg.mon_bfm;
    m_bfm.proxy = this;

    ap = new("ap", this);
    if(m_cfg.monitor_external_clock == 1) begin
        ext_ap = new("ext_ap", this);
    end
endfunction: build_phase

task gpio_monitor::run_phase(uvm_phase phase);
    fork
        m_bfm.internal_monitor_loop();
        begin // Only needed if running external clock monitoring
            if(m_cfg.monitor_external_clock == 1) begin
                m_bfm.external_monitor_loop();
            end
        end
    join
endtask: run_phase

function void gpio_monitor::report_phase(uvm_phase phase);
    // Might be a good place to do some reporting on no of analysis transactions sent etc

endfunction: report_phase

function void gpio_monitor::notify_transaction(gpio_seq_item item);
    ap.write(item);
endfunction : notify_transaction

function void gpio_monitor::notify_transaction_ext_ap(gpio_seq_item item);
    ext_ap.write(item);
endfunction : notify_transaction_ext_ap
