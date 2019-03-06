module uart_tx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 500000
  )(
    input clk,
    input rst,
    output reg tx,
    input block,
    output reg busy,
    input [(4'd8)-1:0] data,
    input new_data
  );
  
  
  parameter CLK_PER_BIT = (CLK_FREQ + BAUD) / BAUD - 1'd1;
  
  parameter CTR_SIZE = $clog2(CLK_PER_BIT);
  
  localparam IDLE_state = 3'd0;
  localparam START_BIT_state = 3'd1;
  localparam DATA_state = 3'd2;
  localparam STOP_BIT_state = 3'd3;
  
  reg [((3))-1:0] M_state_d, M_state_q = IDLE_state;
  reg [((CTR_SIZE))-1:0] M_ctr_d, M_ctr_q = 0;
  reg [((2'd3))-1:0] M_bitCtr_d, M_bitCtr_q = 0;
  reg [((4'd8))-1:0] M_savedData_d, M_savedData_q = 0;
  reg M_txReg_d, M_txReg_q = 0;
  reg M_blockFlag_d, M_blockFlag_q = 0;
  
  always @* begin
    M_state_d = M_state_q;
    M_txReg_d = M_txReg_q;
    M_bitCtr_d = M_bitCtr_q;
    M_savedData_d = M_savedData_q;
    M_ctr_d = M_ctr_q;
    M_blockFlag_d = M_blockFlag_q;
    
    tx = M_txReg_q;
    busy = 1'd1;
    M_blockFlag_d = block;
    
    case (M_state_q)
      IDLE_state: begin
        M_txReg_d = 1'd1;
        if (!M_blockFlag_q) begin
          busy = 1'd0;
          M_bitCtr_d = 1'd0;
          M_ctr_d = 1'd0;
          if (new_data) begin
            M_savedData_d = data;
            M_state_d = START_BIT_state;
          end
        end
      end
      START_BIT_state: begin
        M_ctr_d = M_ctr_q + 1'd1;
        M_txReg_d = 1'd0;
        if (M_ctr_q == CLK_PER_BIT - 1'd1) begin
          M_ctr_d = 1'd0;
          M_state_d = DATA_state;
        end
      end
      DATA_state: begin
        M_txReg_d = M_savedData_q[((M_bitCtr_q))];
        M_ctr_d = M_ctr_q + 1'd1;
        if (M_ctr_q == CLK_PER_BIT - 1'd1) begin
          M_ctr_d = 1'd0;
          M_bitCtr_d = M_bitCtr_q + 1'd1;
          if (M_bitCtr_q == 3'd7) begin
            M_state_d = STOP_BIT_state;
          end
        end
      end
      STOP_BIT_state: begin
        M_txReg_d = 1'd1;
        M_ctr_d = M_ctr_q + 1'd1;
        if (M_ctr_q == CLK_PER_BIT - 1'd1) begin
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
    M_txReg_q <= M_txReg_d;
    M_blockFlag_q <= M_blockFlag_d;
    
    if (rst == 1'b1) begin
      M_state_q <= IDLE_state;
    end else begin
      M_state_q <= M_state_d;
    end
  end
  
endmodule