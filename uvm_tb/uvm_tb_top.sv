module uvm_tb_top () ;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import gpio_agent_pkg::*;


    logic Clk;
    logic Rst_n;

    // uart_if I_UART_IF ();
    gpio_if I_TEMP_IF ();
    gpio_if I_SWITCHES_IF ();

    gpio_monitor_bfm I_TEMP_IF_MON_BFM (
        .Clk  (I_TEMP_IF_BFM.Clk),
        .Gpio (I_TEMP_IF_BFM.gpio)
    );

    gpio_monitor_bfm I_SWITCHES_IF_MON_BFM (
        .Clk  (I_SWITCHES_IF_BFM.Clk),
        .Gpio (I_SWITCHES_IF_BFM.gpio)
    );

    // DUT
    ucontroller I_UCONTROLLER (
        .Clk      (Clk),
        .Rst_n    (Rst_n),
        // .TXD      (I_UART_IF.TXD),
        // .RXD      (I_UART_IF.RXD),
        .Temp     (I_TEMP_IF.gpio),
        .Switches (I_SWITCHES_IF.gpio),
        .ROM_Data (ROM_Data),
        .ROM_Addr (ROM_Addr)
        );


    initial begin
        gpio_agent_config m_gpio_config;

        uvm_config_db #(virtual gpio_if)::set(null,"uvm_test_top","switches_drv_vif", I_SWITCHES_DRV_IF);
        uvm_config_db #(virtual gpio_if)::set(null,"uvm_test_top","switches_mon_vif", I_SWITCHES_MON_IF);

        m_gpio_config = new ("m_gpio_config");
        uvm_config_db #(gpio_agent_config)::set(null,"uvm_test_top","gpio_agent_config", m_gpio_config);
        m_gpio_config.


        // Set config here...
        // m_top_config.
        // ...

    end


    initial begin
        run_test();
    end



endmodule
