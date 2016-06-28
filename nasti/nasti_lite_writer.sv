// See LICENSE for license details.

module nasti_lite_writer
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
    input  [ID_WIDTH-1:0]           nasti_aw_id,
    input  [ADDR_WIDTH-1:0]         nasti_aw_addr,
    input  [7:0]                    nasti_aw_len,
    input  [2:0]                    nasti_aw_size,
    input  [1:0]                    nasti_aw_burst,
    input                           nasti_aw_lock,
    input  [3:0]                    nasti_aw_cache,
    input  [2:0]                    nasti_aw_prot,
    input  [3:0]                    nasti_aw_qos,
    input  [3:0]                    nasti_aw_region,
    input  [USER_WIDTH-1:0]         nasti_aw_user,
    input                           nasti_aw_valid,
    output                          nasti_aw_ready,

    input  [NASTI_DATA_WIDTH-1:0]   nasti_w_data,
    input  [NASTI_DATA_WIDTH/8-1:0] nasti_w_strb,
    input                           nasti_w_last,
    input  [USER_WIDTH-1:0]         nasti_w_user,
    input                           nasti_w_valid,
    output                          nasti_w_ready,

    output [ID_WIDTH-1:0]           nasti_b_id,
    output [1:0]                    nasti_b_resp,
    output [USER_WIDTH-1:0]         nasti_b_user,
    output                          nasti_b_valid,
    input                           nasti_b_ready,

    output [ID_WIDTH-1:0]           lite_aw_id,
    output [ADDR_WIDTH-1:0]         lite_aw_addr,
    output [2:0]                    lite_aw_prot,
    output [3:0]                    lite_aw_qos,
    output [3:0]                    lite_aw_region,
    output [USER_WIDTH-1:0]         lite_aw_user,
    output                          lite_aw_valid,
    input                           lite_aw_ready,

    output [LITE_DATA_WIDTH-1:0]    lite_w_data,
    output [LITE_DATA_WIDTH/8-1:0]  lite_w_strb,
    output [USER_WIDTH-1:0]         lite_w_user,
    output                          lite_w_valid,
    input                           lite_w_ready,

    input  [ID_WIDTH-1:0]           lite_b_id,
    input  [1:0]                    lite_b_resp,
    input  [USER_WIDTH-1:0]         lite_b_user,
    input                           lite_b_valid,
    output                          lite_b_ready
    );

   localparam BUF_LEN = NASTI_DATA_WIDTH > LITE_DATA_WIDTH ? NASTI_DATA_WIDTH/LITE_DATA_WIDTH : 1;
   localparam MAX_TRAN_BITS = $clog2(MAX_TRANSACTION);
   localparam BUF_LEN_BITS = $clog2(BUF_LEN);
   localparam NASTI_W_BITS = $clog2(NASTI_DATA_WIDTH/8);
   localparam LITE_W_BITS = $clog2(LITE_DATA_WIDTH/8);

   genvar                           i;

   initial begin
      assert(LITE_DATA_WIDTH == 32 || LITE_DATA_WIDTH == 64)
        else $fatal(1, "nasti-lite supports only 32/64-bit channels!");
      assert(NASTI_DATA_WIDTH >= LITE_DATA_WIDTH)
        else $fatal(1, "nasti bus cannot be narrower than lite bus!");
   end

   typedef struct packed unsigned {
      logic [ID_WIDTH-1:0]   id;
      logic [ADDR_WIDTH-1:0] addr;
      logic [8:0]            len;
      logic [2:0]            size;
      logic [2:0]            prot;
      logic [3:0]            qos;
      logic [3:0]            region;
      logic [USER_WIDTH-1:0] user;
      } NastiReq;

   // nasti request buffer
   NastiReq [MAX_TRANSACTION-1:0]    aw_buf;
   logic [MAX_TRAN_BITS-1:0]         aw_buf_rp, aw_buf_wp;
   logic                             aw_buf_valid;
   logic                             aw_buf_full, aw_buf_empty;

   // transaction information
   NastiReq                                   xact_req;
   logic                                      xact_req_valid;
   logic [BUF_LEN_BITS+7:0]                   xact_aw_cnt;
   logic [BUF_LEN_BITS+7:0]                   xact_w_cnt;
   logic [BUF_LEN_BITS+7:0]                   xact_b_cnt;
   logic                                      xact_data_valid;
   logic [BUF_LEN-1:0][LITE_DATA_WIDTH-1:0]   xact_data_vec;
   logic [BUF_LEN-1:0][LITE_DATA_WIDTH/8-1:0] xact_strb_vec;
   logic [USER_WIDTH-1:0]                     xact_user;
   logic [1:0]                                xact_resp;
   logic [BUF_LEN_BITS:0]                     xact_data_rp;
   logic [BUF_LEN_BITS:0]                     lite_b_cnt;
   logic                                      xact_finish;

   logic [ADDR_WIDTH-1:0]                   lite_aw_addr_accum;
   logic [ADDR_WIDTH-1:0]                   nasti_w_addr;
   logic [ADDR_WIDTH-1:0]                   nasti_w_addr_accum;
   logic [7:0]                              nasti_b_cnt;

   function int unsigned nasti_step_size(input NastiReq req);
      return 8'd1 << req.size;
   endfunction // nasti_step_size

   function bit unsigned nasti_shrink(input NastiReq req);
      return nasti_step_size(req) > LITE_DATA_WIDTH/8;
   endfunction // nasti_shrink

   function int unsigned lite_step_size(input NastiReq req);
      return nasti_shrink(req) ? LITE_DATA_WIDTH/8 : nasti_step_size(req);
   endfunction // lite_step_size

   function int unsigned lite_packet_ratio(input NastiReq req);
      return nasti_shrink(req) ? 8'd1 << (req.size - LITE_W_BITS) : 1;
   endfunction // lite_packet_ratio

   function int unsigned lite_packet_size(input NastiReq req);
      return lite_packet_ratio(req) * (req.len + 1);
   endfunction // lite_packet_size

   function int unsigned incr(input int unsigned cnt, step, ub);
      return cnt >= ub - step ? 0 : cnt + step;
   endfunction // incr

   // buffer requests

   assign aw_buf_full = aw_buf_valid && aw_buf_wp == aw_buf_rp;
   assign aw_buf_empty = !aw_buf_valid && aw_buf_wp == aw_buf_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
        aw_buf_wp <= 0;
     else if(nasti_aw_valid && nasti_aw_ready) begin
        aw_buf[aw_buf_wp] <= NastiReq'{nasti_aw_id, nasti_aw_addr, nasti_aw_len, nasti_aw_size,
                                       nasti_aw_prot, nasti_aw_qos, nasti_aw_region, nasti_aw_user};
        aw_buf_wp <= incr(aw_buf_wp, 1, MAX_TRANSACTION);
     end

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       aw_buf_valid <= 1'b0;
     else if(nasti_aw_valid && nasti_aw_ready)
       aw_buf_valid <= 1'b1;
     else if((xact_finish || !xact_req_valid) && aw_buf_wp == incr(aw_buf_rp, 1, MAX_TRANSACTION))
       aw_buf_valid <= 1'b0;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       aw_buf_rp <= 0;
     else if(aw_buf_valid && (xact_finish || !xact_req_valid))
       aw_buf_rp <= incr(aw_buf_rp, 1, MAX_TRANSACTION);

   // current transaction

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       lite_aw_addr_accum <= 0;
     else if(lite_aw_valid && lite_aw_ready)
       lite_aw_addr_accum <= lite_aw_addr_accum + lite_step_size(xact_req);
     else if(xact_finish)
       lite_aw_addr_accum <= 0;

   assign lite_aw_id = xact_req.id;
   assign lite_aw_addr = xact_req.addr + lite_aw_addr_accum;
   assign lite_aw_prot = xact_req.prot;
   assign lite_aw_qos = xact_req.qos;
   assign lite_aw_region = xact_req.region;
   assign lite_aw_user = xact_req.user;
   assign lite_aw_valid = xact_req_valid && xact_aw_cnt < lite_packet_size(xact_req);
   assign nasti_aw_ready = !aw_buf_full;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        xact_req_valid <= 1'b0;
        xact_aw_cnt <= 0;
        xact_w_cnt <= 0;
        xact_b_cnt <= 0;
     end else begin
        if(lite_aw_valid && lite_aw_ready)
          xact_aw_cnt <= xact_aw_cnt + 1;
        else if(xact_finish)
          xact_aw_cnt <= 0;

        if(lite_w_valid && lite_w_ready)
          xact_w_cnt <= xact_w_cnt + 1;
        else if(xact_finish)
          xact_w_cnt <= 0;

        if(lite_b_valid && lite_b_ready)
          xact_b_cnt <= xact_b_cnt + 1;
        else if(xact_finish)
          xact_b_cnt <= 0;

        if(xact_finish || !xact_req_valid) begin
           if(aw_buf_valid) xact_req <= aw_buf[aw_buf_rp];
           xact_req_valid <= aw_buf_valid;
        end
     end

   assign xact_finish = nasti_b_valid && nasti_b_ready && nasti_b_cnt == xact_req.len;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       xact_data_valid <= 1'b0;
     else if(nasti_w_valid && nasti_w_ready) begin
        xact_data_vec <= nasti_w_data;
        xact_strb_vec <= nasti_w_strb;
        xact_user <= nasti_w_user;
        xact_data_valid <= 1'b1;
     end else if(lite_b_valid && lite_b_ready && lite_b_cnt == lite_packet_ratio(xact_req)-1)
       xact_data_valid <= 1'b0;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       xact_data_rp <= 0;
     else if(lite_w_valid && lite_w_ready)
       xact_data_rp <= xact_data_rp == lite_packet_ratio(xact_req)-1 ? 0 : xact_data_rp + 1;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       lite_b_cnt <= 0;
     else if(lite_b_valid && lite_b_ready)
       lite_b_cnt <= lite_b_cnt == lite_packet_ratio(xact_req)-1 ? 0 : lite_b_cnt + 1;

   logic [BUF_LEN_BITS:0] xact_data_rp_offset;
   assign xact_data_rp_offset = NASTI_DATA_WIDTH > LITE_DATA_WIDTH ? nasti_w_addr[NASTI_W_BITS-1:LITE_W_BITS] : 0;
   assign lite_w_data = xact_data_vec[xact_data_rp+xact_data_rp_offset];
   assign lite_w_strb = xact_strb_vec[xact_data_rp+xact_data_rp_offset];
   assign lite_w_user = xact_user;
   assign nasti_w_addr = xact_req.addr + nasti_w_addr_accum;
   assign lite_w_valid = xact_data_valid &&  xact_w_cnt < lite_packet_size(xact_req);
   assign nasti_w_ready = !xact_data_valid;

   always_ff @(posedge clk)
     if(lite_b_valid && lite_b_ready)
       xact_resp <= lite_b_resp;

   assign nasti_b_valid = xact_req_valid && xact_b_cnt == lite_packet_size(xact_req);
   assign nasti_b_id = xact_req.id;
   assign nasti_b_resp = xact_resp;
   assign nasti_b_user = xact_req.user;
   assign lite_b_ready = xact_data_valid;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       nasti_w_addr_accum <= 0;
     else if(nasti_w_valid && nasti_w_ready)
       nasti_w_addr_accum <= nasti_w_addr_accum + nasti_step_size(xact_req);
     else if(xact_finish)
       nasti_w_addr_accum <= 0;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
        nasti_b_cnt <= 0;
     else if(nasti_b_valid && nasti_b_ready)
       nasti_b_cnt <= nasti_b_cnt == xact_req.len ? 0 : nasti_b_cnt + 1;

endmodule // nasti_lite_write_buf
