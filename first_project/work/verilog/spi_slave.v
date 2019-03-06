module spi_slave #(
    parameter CPOL = 0,
    parameter CPHA = 0
  )(
    input clk,
    input rst,
    input ss,
    input mosi,
    output reg miso,
    input sck,
    output reg done,
    input [(4'd8)-1:0] data_in,
    output reg [(4'd8)-1:0] data_out
  );
  
  
  reg [((2'd3))-1:0] M_bit_ct_d, M_bit_ct_q = 0;
  reg [((4'd8))-1:0] M_data_d, M_data_q = 0;
  reg M_mosi_reg_d, M_mosi_reg_q = 0;
  reg M_miso_reg_d, M_miso_reg_q = 0;
  reg [((2'd2))-1:0] M_sck_reg_d, M_sck_reg_q = 0;
  reg M_ss_reg_d, M_ss_reg_q = 0;
  reg [((4'd8))-1:0] M_data_out_reg_d, M_data_out_reg_q = 0;
  reg M_done_reg_d, M_done_reg_q = 0;
  
  always @* begin
    M_sck_reg_d = M_sck_reg_q;
    M_mosi_reg_d = M_mosi_reg_q;
    M_done_reg_d = M_done_reg_q;
    M_ss_reg_d = M_ss_reg_q;
    M_data_d = M_data_q;
    M_bit_ct_d = M_bit_ct_q;
    M_data_out_reg_d = M_data_out_reg_q;
    M_miso_reg_d = M_miso_reg_q;
    
    miso = M_miso_reg_q;
    done = M_done_reg_q;
    data_out = M_data_out_reg_q;
    M_ss_reg_d = ss;
    M_mosi_reg_d = mosi;
    M_sck_reg_d = {M_sck_reg_q[((1'd0))], sck};
    M_done_reg_d = 1'd0;
    if (M_ss_reg_q) begin
      M_bit_ct_d = 3'b111;
      M_data_d = data_in;
      M_miso_reg_d = data_in[((3'd7))];
    end else begin
      if (M_sck_reg_q == (2'b01 ^ {2'd2{CPOL[((1'd0))] ^ CPHA[((1'd0))]}})) begin
        M_data_out_reg_d[((M_bit_ct_q))] = M_mosi_reg_q;
        M_bit_ct_d = M_bit_ct_q - 1'd1;
        if (M_bit_ct_q == 1'b0) begin
          M_done_reg_d = 1'd1;
          M_data_d = data_in;
        end
      end else begin
        if (M_sck_reg_q == (2'b10 ^ {2'd2{CPOL[((1'd0))] ^ CPHA[((1'd0))]}})) begin
          M_miso_reg_d = M_data_q[((M_bit_ct_q))];
        end
      end
    end
  end
  
  always @(posedge clk) begin
    M_mosi_reg_q <= M_mosi_reg_d;
    M_miso_reg_q <= M_miso_reg_d;
    M_sck_reg_q <= M_sck_reg_d;
    M_ss_reg_q <= M_ss_reg_d;
    M_data_out_reg_q <= M_data_out_reg_d;
    M_done_reg_q <= M_done_reg_d;
    
    if (rst == 1'b1) begin
      M_bit_ct_q <= 0;
      M_data_q <= 0;
    end else begin
      M_bit_ct_q <= M_bit_ct_d;
      M_data_q <= M_data_d;
    end
  end
  
endmodule