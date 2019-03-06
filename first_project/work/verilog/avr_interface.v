module avr_interface #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 500000
  )(
    input clk,
    input rst,
    input cclk,
    output reg spi_miso,
    input spi_mosi,
    input spi_sck,
    input spi_ss,
    output reg [(3'd4)-1:0] spi_channel,
    output reg tx,
    input rx,
    input [(3'd4)-1:0] channel,
    output reg new_sample,
    output reg [(4'd10)-1:0] sample,
    output reg [(3'd4)-1:0] sample_channel,
    input [(4'd8)-1:0] tx_data,
    input new_tx_data,
    output reg tx_busy,
    input tx_block,
    output reg [(4'd8)-1:0] rx_data,
    output reg new_rx_data
  );
  
  
  reg n_rdy;
  
  wire M_cclk_detector_ready;
  reg M_cclk_detector_cclk;
  cclk_detector #(.CLK_FREQ(CLK_FREQ)) cclk_detector(
    .clk(clk),
    .rst(rst),
    .cclk(M_cclk_detector_cclk),
    .ready(M_cclk_detector_ready)
  );
  wire M_spi_slave_miso;
  wire M_spi_slave_done;
  wire [(4'd8)-1:0] M_spi_slave_data_out;
  reg M_spi_slave_ss;
  reg M_spi_slave_mosi;
  reg M_spi_slave_sck;
  reg [(4'd8)-1:0] M_spi_slave_data_in;
  spi_slave #(.CPOL(0), .CPHA(0)) spi_slave(
    .clk(clk),
    .rst(n_rdy),
    .ss(M_spi_slave_ss),
    .mosi(M_spi_slave_mosi),
    .sck(M_spi_slave_sck),
    .data_in(M_spi_slave_data_in),
    .miso(M_spi_slave_miso),
    .done(M_spi_slave_done),
    .data_out(M_spi_slave_data_out)
  );
  wire [(4'd8)-1:0] M_uart_rx_data;
  wire M_uart_rx_new_data;
  reg M_uart_rx_rx;
  uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) uart_rx(
    .clk(clk),
    .rst(n_rdy),
    .rx(M_uart_rx_rx),
    .data(M_uart_rx_data),
    .new_data(M_uart_rx_new_data)
  );
  wire M_uart_tx_tx;
  wire M_uart_tx_busy;
  reg M_uart_tx_block;
  reg [(4'd8)-1:0] M_uart_tx_data;
  reg M_uart_tx_new_data;
  uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) uart_tx(
    .clk(clk),
    .rst(n_rdy),
    .block(M_uart_tx_block),
    .data(M_uart_tx_data),
    .new_data(M_uart_tx_new_data),
    .tx(M_uart_tx_tx),
    .busy(M_uart_tx_busy)
  );
  reg M_newSampleReg_d, M_newSampleReg_q = 0;
  reg [((4'd10))-1:0] M_sampleReg_d, M_sampleReg_q = 0;
  reg [((3'd4))-1:0] M_sampleChannelReg_d, M_sampleChannelReg_q = 0;
  reg [((2'd2))-1:0] M_byteCt_d, M_byteCt_q = 0;
  reg [((3'd4))-1:0] M_block_d, M_block_q = 0;
  reg M_busy_d, M_busy_q = 0;
  
  always @* begin
    M_newSampleReg_d = M_newSampleReg_q;
    M_sampleChannelReg_d = M_sampleChannelReg_q;
    M_byteCt_d = M_byteCt_q;
    M_busy_d = M_busy_q;
    M_block_d = M_block_q;
    M_sampleReg_d = M_sampleReg_q;
    
    n_rdy = ~M_cclk_detector_ready;
    M_cclk_detector_cclk = cclk;
    M_spi_slave_sck = spi_sck;
    M_spi_slave_mosi = spi_mosi;
    M_spi_slave_data_in = 8'hff;
    M_spi_slave_ss = spi_ss;
    M_uart_rx_rx = rx;
    M_uart_tx_data = tx_data;
    M_uart_tx_new_data = new_tx_data;
    M_uart_tx_block = M_busy_q;
    M_block_d = {M_block_q[((2'd2))-:((2'd2)-(1'd0)+1)], tx_block};
    new_sample = M_newSampleReg_q;
    sample = M_sampleReg_q;
    sample_channel = M_sampleChannelReg_q;
    tx_busy = M_uart_tx_busy;
    rx_data = M_uart_rx_data;
    new_rx_data = M_uart_rx_new_data;
    spi_channel = M_cclk_detector_ready ? channel : 4'bzzzz;
    spi_miso = M_cclk_detector_ready && !spi_ss ? M_spi_slave_miso : 1'bz;
    tx = M_cclk_detector_ready ? M_uart_tx_tx : 1'bz;
    M_newSampleReg_d = 1'd0;
    if (M_block_q[((2'd3))] ^ M_block_q[((2'd2))]) begin
      M_busy_d = 1'd0;
    end
    if (!M_uart_tx_busy && new_tx_data) begin
      M_busy_d = 1'd1;
    end
    if (spi_ss) begin
      M_byteCt_d = 1'd0;
    end
    if (M_spi_slave_done) begin
      if (M_byteCt_q == 1'd0) begin
        M_sampleReg_d[((3'd7))-:((3'd7)-(1'd0)+1)] = M_spi_slave_data_out;
        M_byteCt_d = 1'd1;
      end else begin
        if (M_byteCt_q == 1'd1) begin
          M_sampleReg_d[((4'd9))-:((4'd9)-(4'd8)+1)] = M_spi_slave_data_out[((1'd1))-:((1'd1)-(1'd0)+1)];
          M_sampleChannelReg_d = M_spi_slave_data_out[((3'd7))-:((3'd7)-(3'd4)+1)];
          M_byteCt_d = 2'd2;
          M_newSampleReg_d = 1'd1;
        end
      end
    end
  end
  
  always @(posedge clk) begin
    M_block_q <= M_block_d;
    M_busy_q <= M_busy_d;
    
    if (n_rdy == 1'b1) begin
      M_newSampleReg_q <= 0;
      M_sampleReg_q <= 0;
      M_sampleChannelReg_q <= 0;
      M_byteCt_q <= 0;
    end else begin
      M_newSampleReg_q <= M_newSampleReg_d;
      M_sampleReg_q <= M_sampleReg_d;
      M_sampleChannelReg_q <= M_sampleChannelReg_d;
      M_byteCt_q <= M_byteCt_d;
    end
  end
  
endmodule