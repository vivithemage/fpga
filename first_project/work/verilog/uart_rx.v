module uart_rx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 500000
  )(
    input clk,
    input rst,
    input rx,
    output reg [(4'd8)-1:0] data,
    output reg new_data
  );
  
  
  parameter CLK_PER_BIT = (CLK_FREQ + BAUD) / BAUD - 1'd1;
  
  parameter CTR_SIZE = $clog2(CLK_PER_BIT);
  
  localparam IDLE_state = 3'd0;
  localparam WAIT_HALF_state = 3'd1;
  localparam WAIT_FULL_state = 3'd2;
  localparam WAIT_HIGH_state = 3'd3;
  
  reg [((3))-1:0] M_state_d, M_state_q = IDLE_state;
  reg [((CTR_SIZE))-1:0] M_ctr_d, M_ctr_q = 0;
  reg [((2'd3))-1:0] M_bitCtr_d, M_bitCtr_q = 0;
  reg [((4'd8))-1:0] M_savedData_d, M_savedData_q = 0;
  reg M_newData_d, M_newData_q = 0;
  reg M_rxd_d, M_rxd_q = 0;
  
  always @* begin
    M_state_d = M_state_q;
    M_newData_d = M_newData_q;
    M_bitCtr_d = M_bitCtr_q;
    M_savedData_d = M_savedData_q;
    M_rxd_d = M_rxd_q;
    M_ctr_d = M_ctr_q;
    
    M_rxd_d = rx;
    M_newData_d = 1'd0;
    data = M_savedData_q;
    new_data = M_newData_q;
    
    case (M_state_q)
      IDLE_state: begin
        M_bitCtr_d = 1'd0;
        M_ctr_d = 1'd0;
        if (M_rxd_q == 1'd0) begin
          M_state_d = WAIT_HALF_state;
        end
      end
      WAIT_HALF_state: begin
        M_ctr_d = M_ctr_q + 1'd1;
        if (M_ctr_q == (CLK_PER_BIT >> 1'd1)) begin
          M_ctr_d = 1'd0;
          M_state_d = WAIT_FULL_state;
        end
      end
      WAIT_FULL_state: begin
        M_ctr_d = M_ctr_q + 1'd1;
        if (M_ctr_q == CLK_PER_BIT - 1'd1) begin
          M_savedData_d = {M_rxd_q, M_savedData_q[((3'd7))-:((3'd7)-(1'd1)+1)]};
          M_bitCtr_d = M_bitCtr_q + 1'd1;
          M_ctr_d = 1'd0;
          if (M_bitCtr_q == 3'd7) begin
            M_state_d = WAIT_HIGH_state;
            M_newData_d = 1'd1;
          end
        end
      end
      WAIT_HIGH_state: begin
        if (M_rxd_q == 1'd1) begin
          M_state_d = IDLE_state;
        end
      end
      default: begin
        M_state_d = IDLE_state;
      end
    endcase
  end
  
  always @(posedge clk) begin
    M_ctr_q <= M_ctr_d;
    M_bitCtr_q <= M_bitCtr_d;
    M_savedData_q <= M_savedData_d;
    M_newData_q <= M_newData_d;
    M_rxd_q <= M_rxd_d;
    
    if (rst == 1'b1) begin
      M_state_q <= IDLE_state;
    end else begin
      M_state_q <= M_state_d;
    end
  end
  
endmodule