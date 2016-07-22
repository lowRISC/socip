// See LICENSE for license details.
module nasti_narrower_writer
  #(
    ID_WIDTH          = 2,      // NASTI ID size
    ADDR_WIDTH        = 32,     // NASTI address width
    MASTER_DATA_WIDTH = 64,     // data width on the master side
    SLAVE_DATA_WIDTH  = 32,     // data width on the slave side
    USER_WIDTH        = 1       // size of USER field
    )
   (
    input                           clk, rstn,

    input [ID_WIDTH-1:0]            master_aw_id,
    input [ADDR_WIDTH-1:0]          master_aw_addr,
    input [7:0]                     master_aw_len,
    input [2:0]                     master_aw_size,
    input [1:0]                     master_aw_burst,
    input                           master_aw_lock,
    input [3:0]                     master_aw_cache,
    input [2:0]                     master_aw_prot,
    input [3:0]                     master_aw_qos,
    input [3:0]                     master_aw_region,
    input [USER_WIDTH-1:0]          master_aw_user,
    input                           master_aw_valid,
    output                          master_aw_ready,

    input [MASTER_DATA_WIDTH-1:0]   master_w_data,
    input [MASTER_DATA_WIDTH/8-1:0] master_w_strb,
    input                           master_w_last,
    input [USER_WIDTH-1:0]          master_w_user,
    input                           master_w_valid,
    output                          master_w_ready,

    output [ID_WIDTH-1:0]           master_b_id,
    output [1:0]                    master_b_resp,
    output [USER_WIDTH-1:0]         master_b_user,
    output                          master_b_valid,
    input                           master_b_ready

    output [ID_WIDTH-1:0]           slave_aw_id,
    output [ADDR_WIDTH-1:0]         slave_aw_addr,
    output [7:0]                    slave_aw_len,
    output [2:0]                    slave_aw_size,
    output [1:0]                    slave_aw_burst,
    output                          slave_aw_lock,
    output [3:0]                    slave_aw_cache,
    output [2:0]                    slave_aw_prot,
    output [3:0]                    slave_aw_qos,
    output [3:0]                    slave_aw_region,
    output [USER_WIDTH-1:0]         slave_aw_user,
    output                          slave_aw_valid,
    input                           slave_aw_ready,

    output [SLAVE_DATA_WIDTH-1:0]   slave_w_data,
    output [SLAVE_DATA_WIDTH/8-1:0] slave_w_strb,
    output                          slave_w_last,
    output [USER_WIDTH-1:0]         slave_w_user,
    output                          slave_w_valid,
    input                           slave_w_ready,

    input  [ID_WIDTH-1:0]           slave_b_id,
    input  [1:0]                    slave_b_resp,
    input  [USER_WIDTH-1:0]         slave_b_user,
    input                           slave_b_valid,
    output                          slave_b_ready
    );

   localparam SLAVE_CHANNEL_SIZE = $clog2(SLAVE_DATA_WIDTH/8);
   
   `include "nasti_request.vh"

   NastReq                          request;
   logic [7:0]                      w_cnt;

   enum {S_IDEL, S_AR, S_R}         state;



endmodule // nasti_narrower_writer


