module mojo_top (
    input clk,
    input rst_n,
    output reg [(4'd8)-1:0] led,
    input cclk,
    output reg spi_miso,
    input spi_ss,
    input spi_mosi,
    input spi_sck,
    output reg [(3'd4)-1:0] spi_channel,
    input avr_tx,
    output reg avr_rx,
    input avr_rx_busy
  );
  
  
  wire M_avr_spi_miso;
  wire [(3'd4)-1:0] M_avr_spi_channel;
  wire M_avr_tx;
  wire M_avr_new_sample;
  wire [(4'd10)-1:0] M_avr_sample;
  wire [(3'd4)-1:0] M_avr_sample_channel;
  wire M_avr_tx_busy;
  wire [(4'd8)-1:0] M_avr_rx_data;
  wire M_avr_new_rx_data;
  reg M_avr_cclk;
  reg M_avr_spi_mosi;
  reg M_avr_spi_sck;
  reg M_avr_spi_ss;
  reg M_avr_rx;
  reg [(3'd4)-1:0] M_avr_channel;
  reg [(4'd8)-1:0] M_avr_tx_data;
  reg M_avr_new_tx_data;
  reg M_avr_tx_block;
  avr_interface avr(
    .clk(clk),
    .rst(~rst_n),
    .cclk(M_avr_cclk),
    .spi_mosi(M_avr_spi_mosi),
    .spi_sck(M_avr_spi_sck),
    .spi_ss(M_avr_spi_ss),
    .rx(M_avr_rx),
    .channel(M_avr_channel),
    .tx_data(M_avr_tx_data),
    .new_tx_data(M_avr_new_tx_data),
    .tx_block(M_avr_tx_block),
    .spi_miso(M_avr_spi_miso),
    .spi_channel(M_avr_spi_channel),
    .tx(M_avr_tx),
    .new_sample(M_avr_new_sample),
    .sample(M_avr_sample),
    .sample_channel(M_avr_sample_channel),
    .tx_busy(M_avr_tx_busy),
    .rx_data(M_avr_rx_data),
    .new_rx_data(M_avr_new_rx_data)
  );
  wire M_greeter_new_tx;
  wire [(4'd8)-1:0] M_greeter_tx_data;
  reg M_greeter_new_rx;
  reg [(4'd8)-1:0] M_greeter_rx_data;
  reg M_greeter_tx_busy;
  greeter greeter(
    .clk(clk),
    .rst(~rst_n),
    .new_rx(M_greeter_new_rx),
    .rx_data(M_greeter_rx_data),
    .tx_busy(M_greeter_tx_busy),
    .new_tx(M_greeter_new_tx),
    .tx_data(M_greeter_tx_data)
  );
  
  always @* begin
    M_avr_cclk = cclk;
    M_avr_spi_ss = spi_ss;
    M_avr_spi_mosi = spi_mosi;
    M_avr_spi_sck = spi_sck;
    M_avr_rx = avr_tx;
    spi_miso = M_avr_spi_miso;
    spi_channel = M_avr_spi_channel;
    avr_rx = M_avr_tx;
    M_avr_channel = 4'hf;
    M_avr_tx_block = avr_rx_busy;
    M_greeter_new_rx = M_avr_new_rx_data;
    M_greeter_rx_data = M_avr_rx_data;
    M_avr_new_tx_data = M_greeter_new_tx;
    M_avr_tx_data = M_greeter_tx_data;
    M_greeter_tx_busy = M_avr_tx_busy;
    led = 8'h00;
  end
endmodule