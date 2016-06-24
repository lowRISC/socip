module nasti_lite_reader
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
    input  [ID_WIDTH-1:0]           nasti_ar_id,
    input  [ADDR_WIDTH-1:0]         nasti_ar_addr,
    input  [7:0]                    nasti_ar_len,
    input  [2:0]                    nasti_ar_size,
    input  [1:0]                    nasti_ar_burst,
    input                           nasti_ar_lock,
    input  [3:0]                    nasti_ar_cache,
    input  [2:0]                    nasti_ar_prot,
    input  [3:0]                    nasti_ar_qos,
    input  [3:0]                    nasti_ar_region,
    input  [USER_WIDTH-1:0]         nasti_ar_user,
    input                           nasti_ar_valid,
    output                          nasti_ar_ready,

    output [ID_WIDTH-1:0]           nasti_r_id,
    output [NASTI_DATA_WIDTH-1:0]   nasti_r_data,
    output [1:0]                    nasti_r_resp,
    output                          nasti_r_last,
    output [USER_WIDTH-1:0]         nasti_r_user,
    output                          nasti_r_valid,
    input                           nasti_r_ready,

    output [ID_WIDTH-1:0]           lite_ar_id,
    output [ADDR_WIDTH-1:0]         lite_ar_addr,
    output [2:0]                    lite_ar_prot,
    output [3:0]                    lite_ar_qos,
    output [3:0]                    lite_ar_region,
    output [USER_WIDTH-1:0]         lite_ar_user,
    output                          lite_ar_valid,
    input                           lite_ar_ready,

    input  [ID_WIDTH-1:0]           lite_r_id,
    input  [LITE_DATA_WIDTH-1:0]    lite_r_data,
    input  [1:0]                    lite_r_resp,
    input  [USER_WIDTH-1:0]         lite_r_user,
    input                           lite_r_valid,
    output                          lite_r_ready
    );


   localparam BUF_LEN = NASTI_DATA_WIDTH/LITE_DATA_WIDTH;

   genvar i;

   initial begin
      assert(NASTI_DATA_WIDTH > LITE_DATA_WIDTH)
        else $fatal(1, "Do not support narrower lite than nasti!");
      
      assert(LITE_DATA_WIDTH == 32 || LITE_DATA_WIDTH == 64)
        else $fatal(1, "nasti-lite supports only 32/64-bit channels!");
   end

   typedef struct packed {
      logic [ID_WIDTH-1:0]   id,
      logic [ADDR_WIDTH-1:0] addr,
      logic [8:0]            len,
      logic [2:0]            size,
      logic [2:0]            prot,
      logic [3:0]            qos,
      logic [3:0]            region,
      logic [USER_WIDTH-1:0] user
      } NastiAR;

   // nasti request buffer
   NastiAR [MAX_TRANSACTION-1:0]     ar_buf;
   logic [$clog2(MAX_TRANSACTION):0] ar_buf_rp, ar_buf_wp;
   logic                             ar_buf_valid;
   logic                             ar_buf_full, ar_buf_empty;
   
   // transaction information
   NastiAR                                  xact_req;
   logic                                    xact_req_valid;
   logic [8+$clog2(BUF_LEN):0]              xact_ar_cnt;
   logic [8+$clog2(BUF_LEN):0]              xact_r_cnt;
   logic [BUF_LEN-1:0][LITE_DATA_WIDTH-1:0] xact_data_vec;
   logic [1:0]                              xact_resp;
   logic [$clog2(BUF_LEN):0]                xact_data_wp;
   logic                                    xact_finish;
   logic [7:0]                              nasti_r_cnt;
   logic [ADDR_WIDTH-1:0]                   nasti_r_addr;

   function int unsigned nasti_step_size(input NastiAR req) begin
      return (8'd1 << req.size);
   endfunction

   function int unsigned lite_step_size(input NastiAR req) begin
      return nasti_step_size(req) > LITE_DATA_WIDTH/8 ? LITE_DATA_WIDTH/8 : (8'd1 << req.size);
   endfunction // lite_step_size

   function int unsigned lite_packet_ratio(input NastiAR req) begin
      return nasti_step_size(req) > LITE_DATA_WIDTH/8 ? BUF_LEN : 1;
   endfunction // lite_packet_ratio

   function int unsigned lite_packet_size(input NastiAR req) begin
      return lite_packet_ratio(req) * (req.len + 1);
   endfunction // lite_packet_size

   // buffer requests

   assign ar_buf_full = ar_buf_valid && ar_buf_wp == ar_buf_rp;
   assign ar_buf_empty = !ar_buf_valid && ar_buf_wp == ar_buf_rp;   

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
        ar_buf_wp <= 0;
     else if(nasti_ar_valid && nasti_ar_ready) begin
        ar_buf[ar_buf_wp] <= NastiAR'{nasti_ar_id, nasti_ar_addr, nasti_ar_len, nasti_ar_size,
                                      nasti_ar_prot, nasti_ar_qos, nasti_ar_region, nasti_ar_uaer};
        ar_buf_wp <= ar_buf_wp == MAX_TRANSACTION-1 ? 0 : ar_buf_wp + 1;
     end

   assign nasti_ar_ready = !ar_buf_full;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       ar_buf_valid <= 1'b0;
     else if(nasti_ar_valid && nasti_ar_ready)
       ar_buf_valid <= 1'b1;
     else if(xact_finish && (ar_buf_wp == 0 ? ar_buf_rp == MAX_TRANSACTION-1 : ar_buf_rp + 1 == ar_buf_wp))
       ar_buf_valid <= 1'b0;

   always_ff(posedge clk or negedge rstn)
     if(!rstn)
       ar_buf_rp <= 0;
     else if(xact_finish)
       ar_buf_rp <= ar_buf_rp == MAX_TRANSACTION-1 ? 0 : ar_buf_rp + 1;
   
   // current transaction

   assign lite_ar_id = xact_req.id;
   assign lite_ar_addr = xact_req.addr + xact_ar_cnt * lite_step_size(xact_req);
   assign lite_ar_prot = xact_req.prot;
   assign lite_ar_region = xact_req.region;
   assign lite_ar_user = xact_req.user;
   assign lite_ar_valid = xact_req_valid && xact_ar_cnt < lite_packet_size(xact_req);
   assign lite_r_ready = xact_req_valid && xact_r_cnt < lite_packet_size(xact_req) && xact_data_wp < lite_packet_ratio(xact_req);

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        xact_req_valid <= 1'b0;
        xact_finish <= 1'b0;
     end else if(lite_r_ready) begin
        if(lite_ar_valid && lite_ar_ready)
          xact_ar_cnt <= xact_ar_cnt + 1;
        if(lite_r_valid && lite_r_ready)
          xact_r_cnt <= xact_r_cnt + 1;
     end else if(nasti_r_valid && nasti_r_ready && nasti_r_cnt == xact_req.len)
       xact_finish <= 1;
     else if(xact_finish) begin
        xact_req <= ar_buf[ar_buf_rp];
        xact_req_valid <= ar_buf_valid;
        xact_ar_cnt <= 0;
        xact_r_cnt <= 0;
        xact_finish <= 0;
     end

   always_ff @(posedge clk)
     if(lite_r_valid && lite_r_ready) begin
        xact_data_vec[xact_data_wp] <= lite_r_data;
        xact_resp <= lite_r_resp;
     end

   assign nasti_r_valid = xact_req_valid && xact_data_wp == lite_packet_ratio(xact_req);
   assign nasti_r_id = xact_req.id;
   assign nasti_r_data = xact_data_vec << {nasti_r_addr[$clog2(NASTI_DATA_WIDTH)-1:0], 3'b000};
   assign nasti_r_resp = xact_resp;
   assign nasti_r_last = nasti_r_cnt == xact_req.len;
   assign nasti_r_user = xact_req.user;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        nasti_r_cnt <= 0;
     end else if(nasti_r_valid && nasti_r_ready) begin
        nasti_r_cnt <= nasti_r_cnt == xact_req.len ? 0 : nasti_r_cnt + 1;
        nasti_r_addr <= (nasti_r_cnt == 0 ? xact_req.addr : nasti_r_addr) + nasti_step_size(xact_req);
     end

endmodule // nasti_lite_reader
