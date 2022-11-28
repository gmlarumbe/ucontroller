interface gpio_driver_bfm (
  input logic        Clk,
  output logic [7:0] Gpio
);

  import gpio_agent_pkg::*;

//------------------------------------------
// Data Members
//------------------------------------------

//------------------------------------------
// Methods
//------------------------------------------

function void clear_sigs();
  ext_clk <= 0;
endfunction : clear_sigs

task drive (gpio_seq_item req);
  // @(posedge clk);
  // #1ns;
  // foreach(req.use_ext_clk[i]) begin
  //   if(req.use_ext_clk[i] == 0) begin
  //       gpio[i] <= req.gpio[i];
  //   end
  // end
  // repeat(2)
  //   @(negedge clk);
  // foreach(req.use_ext_clk[i]) begin
  //   if(req.use_ext_clk[i] == 1) begin
  //     if(req.ext_clk_edge[i] == 1) begin
  //       gpio[i] <= req.gpio[i];
  //     end
  //   end
  // end
  // repeat(2)
  //   @(negedge clk);
  // ext_clk <= 1;
  // repeat(5)
  //   @(negedge clk);
  // foreach(req.use_ext_clk[i]) begin
  //   if(req.use_ext_clk[i] == 1) begin
  //     if(req.ext_clk_edge[i] == 0) begin
  //       gpio[i] <= req.gpio[i];
  //     end
  //   end
  // end
  //   repeat(5)
  //     @(negedge clk);
  // ext_clk <= 0;
  // repeat(5)
  //   @(negedge clk);
endtask : drive

endinterface: gpio_driver_bfm
