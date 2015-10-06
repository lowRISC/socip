// See LICENSE for license details.

// bridge for NASTI/NASTI-Lite conversion

module nasti_to_lite
  #(
    BUF_DEPTH = 0,              // buffer transactions
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

   




endmodule // nasti_to_lite

