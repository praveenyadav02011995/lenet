module max_pooling(input [7:0] in1, in2, in3, in4,
                   output reg [7:0] out);

  always @(*) begin
    out = in1 > in2 ? in1 : in2;
    out = out > in3 ? out : in3;
    out = out > in4 ? out : in4;
  end

endmodule
