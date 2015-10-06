// See LICENSE for license details.

// bridge for NASTI/NASTI-Lite conversion

module nasti_to_lite
  #(
    NASTI_BUF_DEPTH = 0,        // buffer for nasti
    LITE_BUF_DEPTH = 0,         // buffer for lite side
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    NASTI_DATA_WIDTH = 8,       // width of data on the nasti side
    LITE_DATA_WIDTH = 32,       // width of data on the nasti-lite side
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input clk, rstn,
    nasti_channel.slave nasti_s,
    nasti_channel.master lite_m
    );

   init
     assert(LITE_DATA_WIDTH == 32 || LITE_DATA_WIDTH == 64)
       else $fatal(1, "nasti-lite support only 32/64-bit channels!");

   // buff the nasti side
   nasti_channel #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                   .DATA_WIDTH(NASTI_DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   nasti_buf();

   nasti_buf #(.DEPTH(NASTI_BUF_DEPTH), ID_WIDTH(ID_WIDTH),
               .ADDR_WIDTH(ADDR_WIDTH), DATA_WIDTH(NASTI_DATA_WIDTH),
               .USER_WIDTH(USER_WIDTH))
   input_buf (.*, s(nasti_s), .m(nasti_buf));

   // buff the lite side
   nasti_channel #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                   .DATA_WIDTH(LITE_DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   lite_buf;

   nasti_buf #(.DEPTH(LITE_BUF_DEPTH), ID_WIDTH(ID_WIDTH),
               .ADDR_WIDTH(ADDR_WIDTH), DATA_WIDTH(LITE_DATA_WIDTH))
   input_buf (.*, s(lite_buf), .m(lite_m));

endmodule // nasti_to_lite

