// Signed/Unsigned Multiplier Accumulator Unit
// Y = C + AB
// Parallel Multiplier 
// A size is La-bit and Lb size is M-bits
// if sg = 0, it will perform unsigned multiplication 
// else (sg = 1) it will perform signed multiplication (Baugh-Wooley Multiplier)
//------------ End of Multiplier ---------
// Ly is the size of Y 
// Lc is the size of C
// ---- Written by Vikramkumar Pudi  ---

module MAC_Array_MUL_Sign #(parameter La=4,Lb=4, Lc = 8, Ly = 9)(A,B,C, sg,Y);
    input [La-1:0]A;
    input [Lb-1:0]B;
    input [Lc-1:0]C; // Lc = La + Lb
    input sg;
    output [Ly:0]Y; // Ly = La+Lb+1
    
wire [La+Lb-1:0]Ym;

// Calling Multiplier code 
  Array_MUL_Sign #(.N(La),.M(Lb)) AMS1 (.A(A),.B(B),.sg(sg),.Y(Ym));

assign Y = {C[Lc-1]&sg,C } + {Ym[La+Lb-1]&sg, Ym};


endmodule