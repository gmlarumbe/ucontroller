class uart_driver extends uvm_driver #(uart_seq_item, uart_seq_item);
    `uvm_component_utils(uart_driver)

    // Virtual Interface
    local virtual uart_driver_bfm m_bfm;

    //------------------------------------------
    // Data Members
    //------------------------------------------
    uart_agent_config m_cfg;
    uart_seq_item pkt;

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    function new(string name = "uart_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `get_config(uart_agent_config, m_cfg, "uart_agent_config")
        m_bfm = m_cfg.drv_bfm;

    endfunction: build_phase

    task run_phase(uvm_phase phase);
        fork
            send_pkts;
            m_bfm.clk_gen;
        join
    endtask: run_phase

    // Helper Methods:

    task send_pkts;
        m_bfm.clear_sigs();
        forever begin
            seq_item_port.get_next_item(pkt);
            m_bfm.send_pkt(pkt);
            seq_item_port.item_done();
        end
    endtask: send_pkts

endclass: uart_driver
