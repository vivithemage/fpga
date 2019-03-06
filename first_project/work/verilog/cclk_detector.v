module cclk_detector #(
    parameter CLK_FREQ = 50000000
  )(
    input clk,
    input rst,
    input cclk,
    output reg ready
  );
  
  
  parameter CTR_SIZE = $clog2(CLK_FREQ / 13'd5000);
  
  reg [((CTR_SIZE))-1:0] M_ctr_d, M_ctr_q = 0;
  
  always @* begin
    M_ctr_d = M_ctr_q;
    
    ready = (&M_ctr_q);
    if (cclk == 1'd0) begin
      M_ctr_d = 1'd0;
    end else begin
      if (!(&M_ctr_q)) begin
        M_ctr_d = M_ctr_q + 1'd1;
      end
    end
  end
  
  always @(posedge clk) begin
    if (rst == 1'b1) begin
      M_ctr_q <= 0;
    end else begin
      M_ctr_q <= M_ctr_d;
    end
  end
  
endmodule