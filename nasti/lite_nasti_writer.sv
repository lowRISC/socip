// See LICENSE for license details.

module lite_nasti_writer
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
    input  [ID_WIDTH-1:0]           lite_aw_id,
    input  [ADDR_WIDTH-1:0]         lite_aw_addr,
    input  [2:0]                    lite_aw_prot,
    input  [3:0]                    lite_aw_qos,
    input  [3:0]                    lite_aw_region,
    input  [USER_WIDTH-1:0]         lite_aw_aw_user,
    input                           lite_aw_valid,
    output                          lite_aw_ready,

    input  [LITE_DATA_WIDTH-1:0]    lite_w_data,
    input  [LITE_DATA_WIDTH/8-1:0]  lite_w_strb,
    input  [USER_WIDTH-1:0]         lite_w_user,
    input                           lite_w_valid,
    output                          lite_w_ready,

    output [ID_WIDTH-1:0]           lite_b_id,
    output [1:0]                    lite_b_resp,
    output [USER_WIDTH-1:0]         lite_b_user,
    output                          lite_b_valid,
    input                           lite_b_ready,

    output [ID_WIDTH-1:0]           nasti_aw_id,
    output [ADDR_WIDTH-1:0]         nasti_aw_addr,
    output [7:0]                    nasti_aw_len,
    output [2:0]                    nasti_aw_size,
    output [1:0]                    nasti_aw_burst,
    output                          nasti_aw_lock,
    output [3:0]                    nasti_aw_cache,
    output [2:0]                    nasti_aw_prot,
    output [3:0]                    nasti_aw_qos,
    output [3:0]                    nasti_aw_region,
    output [USER_WIDTH-1:0]         nasti_aw_user,
    output                          nasti_aw_valid,
    input                           nasti_aw_ready,

    output [NASTI_DATA_WIDTH-1:0]   nasti_w_data,
    output [NASTI_DATA_WIDTH/8-1:0] nasti_w_strb,
    output                          nasti_w_last,
    output [USER_WIDTH-1:0]         nasti_w_user,
    output                          nasti_w_valid,
    input                           nasti_w_ready,

    input  [ID_WIDTH-1:0]           nasti_b_id,
    input  [1:0]                    nasti_b_resp,
    input  [USER_WIDTH-1:0]         nasti_b_user,
    input                           nasti_b_valid,
    output                          nasti_b_ready
    );
    
endmodule // lite_nasti_writer
