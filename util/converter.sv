// See LICENSE for license details.

module OHToUInt
  #(
    W = 8                     // width of the one-hot number
    )
   (
    oh,                         // One-hot input
    d                           // unsigned binary output
    );

   input  [W-1:0]         oh;
   output [$clog2(W)-1:0] d;

   genvar i,j;

   logic [W-1:0][$clog2(W)-1:0] m;   // one-hot matrix
   logic [$clog2(W)-1:0][W-1:0] mm;  // OH2UInt matrix
   
   generate
     for(i=0; i<W; i++)
        if(i == 0) assign m[0] = 0;
       else
         assign m[i] = oh[i] ? i : 0;

     for(i=0; i<$clog2(W); i=i+1) begin
        for(j=0; j<W; j=j+1)
          assign mm[i][j] = m[j][i];
        assign d[i] = |mm[i];
     end
   endgenerate

endmodule // OHToUInt

