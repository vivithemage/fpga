module greeter (
    input clk,
    input rst,
    input new_rx,
    input [(4'd8)-1:0] rx_data,
    output reg new_tx,
    output reg [(4'd8)-1:0] tx_data,
    input tx_busy
  );
  
  
  parameter NUM_LETTERS = 4'd14;
  
  localparam IDLE_state = 2'd0;
  localparam GREET_state = 2'd1;
  
  reg [((2))-1:0] M_state_d, M_state_q = IDLE_state;
  reg [(($clog2(NUM_LETTERS)))-1:0] M_count_d, M_count_q = 0;
  
  wire [(4'd8)-1:0] M_rom_letter;
  reg [(3'd4)-1:0] M_rom_address;
  hello_world_rom rom(
    .address(M_rom_address),
    .letter(M_rom_letter)
  );
  
  always @* begin
    M_state_d = M_state_q;
    M_count_d = M_count_q;
    
    M_rom_address = M_count_q;
    tx_data = M_rom_letter;
    new_tx = 1'd0;
    
    case (M_state_q)
      IDLE_state: begin
        M_count_d = 1'd0;
        if (new_rx && rx_data == "h") begin
          M_state_d = GREET_state;
        end
      end
      GREET_state: begin
        if (!tx_busy) begin
          M_count_d = M_count_q + 1'd1;
          new_tx = 1'd1;
          if (M_count_q == NUM_LETTERS - 1'd1) begin
            M_state_d = IDLE_state;
          end
        end
      end
    endcase
  end
  
  always @(posedge clk) begin
    M_count_q <= M_count_d;
    
    if (rst == 1'b1) begin
      M_state_q <= IDLE_state;
    end else begin
      M_state_q <= M_state_d;
    end
  end
  
endmodule