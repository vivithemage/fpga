module hello_world_rom (
    input [(3'd4)-1:0] address,
    output reg [(4'd8)-1:0] letter
  );
  
  
  parameter TEXT = "\r\n!dlroW olleH";
  
  always @* begin
    letter = TEXT[((((address << 2'd3)+(4'd8)-1)))-:4'd8];
  end
endmodule