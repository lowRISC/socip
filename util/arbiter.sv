// See LICENSE for license details.

module arbiter_rr
  #(
    N = 2
    )
   (
    input clk, rstn,
    input [N-1:0]  req,
    output [N-1:0] gnt
    );

   logic [N-1:0] p;           // pointer of last grant
   logic [2*N-1:0] mask, req_ext, p_ext;

   genvar          i;

   assign mask[0] = 0;
   assign req_ext = {req, req};
   assign p_ext = p;

   generate
      for(i=1; i<2*N; i++)
        assign mask[i] = (mask[i-1] || p_ext[i-1]) && !req_ext[i-1];
   endgenerate

   assign gnt = req & (mask[N-1:0] | mask[2*N:N]);

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       p <= 1;
     else if(|req)
       p <= gnt;

endmodule // arbiter_rr
