module conv_2d (
  input clk,                      // clock signal
  input rst,                      // reset signal
  input signed [7:0] in_data [0:27][0:27],  // 28x28 input matrix
  input signed [7:0] kernel [0:4][0:4],     // 5x5 kernel
  output reg signed [15:0] out_data [0:23][0:23] // 24x24 output matrix
);
parameter IN_DIM = 28;    // input matrix dimension
parameter K_DIM = 5;      // kernel dimension
parameter OUT_DIM = 24;   // output matrix dimension
reg[15:0] conv_result;
  always @ (posedge clk) begin
    if (rst) begin
      // reset output matrix to 0
      for (integer i = 0; i < OUT_DIM; i = i + 1) begin
        for (integer j = 0; j < OUT_DIM; j = j + 1) begin
          out_data[i][j] <= 0;
        end
      end
    end else begin
      // perform 2D convolution
      for (integer i = 0; i < OUT_DIM; i = i + 1) begin
        for (integer j = 0; j < OUT_DIM; j = j + 1) begin
          
          // perform convolution operation
          conv_result = 0;
          for (integer k = 0; k < K_DIM; k = k + 1) begin
            for (integer l = 0; l < K_DIM; l = l + 1) begin
              conv_result = conv_result + (in_data[k+i][l+j] * kernel[k][l]);
            end
          end
          out_data[i][j] <= conv_result;
        end
      end
    end

endmodule