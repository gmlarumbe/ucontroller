module uvm_tb_top () ;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import gpio_agent_pkg::*;


    logic Clk;
    logic Rst_n;

    // uart_if I_UART_IF ();
    gpio_if I_TEMP_IF (.Clk(Clk), .Rst_n(Rst_n));
    gpio_if I_SWITCHES_IF (.Clk(Clk), .Rst_n(Rst_n));

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
        m_gpio_config = new ("m_gpio_config");
        uvm_config_db #(gpio_agent_config)::set(null,"uvm_tb_top","gpio_agent_config", m_gpio_config);
        // Set config here...
        // m_top_config.
        // ...

    end


    initial begin
        run_test();
    end



endmodule
