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
  
  
  always @* begin
    led = 8'h00;
    spi_miso = 1'bz;
    spi_channel = 4'bzzzz;
    avr_rx = 1'bz;
  end
endmodule