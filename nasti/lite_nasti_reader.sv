// See LICENSE for license details.

module lite_nasti_reader
  #(
    MAX_TRANSACTION = 2,        // the number of parallel transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    NASTI_DATA_WIDTH = 8,       // width of data on the nasti side
    LITE_DATA_WIDTH = 32,       // width of data on the nasti-lite side
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input  clk, rstn,
    input  [ID_WIDTH-1:0]           lite_ar_id,
    input  [ADDR_WIDTH-1:0]         lite_ar_addr,
    input  [2:0]                    lite_ar_prot,
    input  [3:0]                    lite_ar_qos,
    input  [3:0]                    lite_ar_region,
    input  [USER_WIDTH-1:0]         lite_ar_user,
    input                           lite_ar_valid,
    output                          lite_ar_ready,

    output [ID_WIDTH-1:0]           lite_b_id,
    output [LITE_DATA_WIDTH-1:0]    lite_r_data,
    output [1:0]                    lite_b_resp,
    output [USER_WIDTH-1:0]         lite_r_user,
    output                          lite_r_valid,
    input                           lite_r_ready

    output  [ID_WIDTH-1:0]          nasti_ar_id,
    output  [ADDR_WIDTH-1:0]        nasti_ar_addr,
    output  [7:0]                   nasti_ar_len,
    output  [2:0]                   nasti_ar_size,
    output  [1:0]                   nasti_ar_burst,
    output                          nasti_ar_lock,
    output  [3:0]                   nasti_ar_cache,
    output  [2:0]                   nasti_ar_prot,
    output  [3:0]                   nasti_ar_qos,
    output  [3:0]                   nasti_ar_region,
    output  [USER_WIDTH-1:0]        nasti_ar_user,
    output                          nasti_ar_valid,
    input                           nasti_ar_ready,

    input  [ID_WIDTH-1:0]           nasti_r_id,
    input  [NASTI_DATA_WIDTH-1:0]   nasti_r_data,
    input  [1:0]                    nasti_r_resp,
    input                           nasti_r_last,
    input  [USER_WIDTH-1:0]         nasti_r_user,
    input                           nasti_r_valid,
    output                          nasti_r_ready,
    );


endmodule // lite_nasti_reader

