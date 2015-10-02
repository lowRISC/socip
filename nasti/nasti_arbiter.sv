// See LICENSE for license details.


module axi_arbiter
  #(
    ADDR_WIDTH = 32,
    DATA_WIDTH = 64,
    ID_WIDTH = 8
    )
   (
   input clk, rstn,

   // output AXI port 0
   nasti_aw.slave   aw_i_0,
   nasti_w.slave    w_i_0,
   nasti_b.slave    b_i_0,
   nasti_ar.slave   ar_i_0,
   nasti_r.slave    r_i_0,

   // output AXI port 1
   nasti_aw.slave   aw_i_1,
   nasti_w.slave    w_i_1,
   nasti_b.slave    b_i_1,
   nasti_ar.slave   ar_i_1,
   nasti_r.slave    r_i_1

   // input AXI port
   nasti_aw.master  aw_o,
   nasti_w.master   w_o,
   nasti_b.master   b_o,
   nasti_ar.master  ar_o,
   nasti_r.master   r_o,
   );



   // nasti.r
   assign r_i_0.id = r_o.id;
   assign r_i_0.data = r_o.data;
   assign r_i_0.resp = r_o.resp;
   assign 


endmodule // axi_arbiter


   
