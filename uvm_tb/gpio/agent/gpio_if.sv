interface gpio_if (input logic Clk, input logic Rst_n);

    logic       clk;
    logic [7:0] gpio;

endinterface: gpio_if