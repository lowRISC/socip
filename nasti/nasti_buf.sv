// See LICENSE for license details.

module nasti_buf
  #(
    DEPTH = 1,                  // buffer depth
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not in use
    BUF_REQ = 1,                // whether to buffer for AW/AR/W
    BUF_RESP = 1                // whether to buffer B/R
    )
   (
    input clk, rstn,
    nasti_channel.slave master,
    nasti_channel.master slave
    );

   localparam DEPTH_LOC = DEPTH == 0 ? 1 : DEPTH;

   // a little bit awkward implementation due to the fact that
   // isim (Xilinx) is not happy with parameterized assign.
   // Code such as:
   //
   // generate
   //   if(A)
   //      assign sig = 1;
   //   else
   //      assign sig = 2;
   // endgenerate
   //
   // may result into sig == x
   //
   // but
   //
   // assign sig = A ? 1 : 2;
   //
   // seems working.
   //
   // And it is not happy with struct
   // Force me to use simple arrays

   function logic [$clog2(DEPTH_LOC)-1:0] incr(logic [$clog2(DEPTH_LOC)-1:0] p);
      logic [$clog2(DEPTH_LOC):0] p_incr;
      p_incr = {1'b0,p} + 1;
      return p_incr >= DEPTH_LOC ? p_incr - DEPTH_LOC : p_incr;
   endfunction // incr

   // AW
   logic [ID_WIDTH-1:0]           aw_q_id     [DEPTH_LOC-1:0];
   logic [ADDR_WIDTH-1:0]         aw_q_addr   [DEPTH_LOC-1:0];
   logic [7:0]                    aw_q_len    [DEPTH_LOC-1:0];
   logic [2:0]                    aw_q_size   [DEPTH_LOC-1:0];
   logic [1:0]                    aw_q_burst  [DEPTH_LOC-1:0];
   logic                          aw_q_lock   [DEPTH_LOC-1:0];
   logic [3:0]                    aw_q_cache  [DEPTH_LOC-1:0];
   logic [2:0]                    aw_q_prot   [DEPTH_LOC-1:0];
   logic [3:0]                    aw_q_qos    [DEPTH_LOC-1:0];
   logic [3:0]                    aw_q_region [DEPTH_LOC-1:0];
   logic [USER_WIDTH-1:0]         aw_q_user   [DEPTH_LOC-1:0];
   logic [DEPTH_LOC-1:0]          aw_valid;
   logic [$clog2(DEPTH_LOC)-1:0]  aw_wp, aw_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        aw_rp <= 0;
        aw_wp <= 0;
        aw_valid <= 0;
     end else begin
        if(master.aw_valid && master.aw_ready) begin
           aw_wp <= incr(aw_wp);
           aw_valid[aw_wp] <= 1'b1;
        end

        if(slave.aw_valid && slave.aw_ready) begin
           aw_rp <= incr(aw_rp);
           aw_valid[aw_rp] <= 1'b0;
        end
     end

   always_ff @(posedge clk)
     if(master.aw_valid && master.aw_ready) begin
        aw_q_id    [aw_wp] <= master.aw_id;
        aw_q_addr  [aw_wp] <= master.aw_addr;
        aw_q_len   [aw_wp] <= master.aw_len;
        aw_q_size  [aw_wp] <= master.aw_size;
        aw_q_burst [aw_wp] <= master.aw_burst;
        aw_q_lock  [aw_wp] <= master.aw_lock;
        aw_q_cache [aw_wp] <= master.aw_cache;
        aw_q_prot  [aw_wp] <= master.aw_prot;
        aw_q_qos   [aw_wp] <= master.aw_qos;
        aw_q_region[aw_wp] <= master.aw_region;
        aw_q_user  [aw_wp] <= master.aw_user;
     end // if (master.aw_valid && master.aw_ready)

   assign master.aw_ready  = BUF_REQ && DEPTH > 0 ? !aw_valid[aw_wp]   : slave.aw_ready;
   assign slave.aw_id      = BUF_REQ && DEPTH > 0 ? aw_q_id    [aw_rp] : master.aw_id;
   assign slave.aw_addr    = BUF_REQ && DEPTH > 0 ? aw_q_addr  [aw_rp] : master.aw_addr;
   assign slave.aw_len     = BUF_REQ && DEPTH > 0 ? aw_q_len   [aw_rp] : master.aw_len;
   assign slave.aw_size    = BUF_REQ && DEPTH > 0 ? aw_q_size  [aw_rp] : master.aw_size;
   assign slave.aw_burst   = BUF_REQ && DEPTH > 0 ? aw_q_burst [aw_rp] : master.aw_burst;
   assign slave.aw_lock    = BUF_REQ && DEPTH > 0 ? aw_q_lock  [aw_rp] : master.aw_lock;
   assign slave.aw_cache   = BUF_REQ && DEPTH > 0 ? aw_q_cache [aw_rp] : master.aw_cache;
   assign slave.aw_prot    = BUF_REQ && DEPTH > 0 ? aw_q_prot  [aw_rp] : master.aw_prot;
   assign slave.aw_qos     = BUF_REQ && DEPTH > 0 ? aw_q_qos   [aw_rp] : master.aw_qos;
   assign slave.aw_region  = BUF_REQ && DEPTH > 0 ? aw_q_region[aw_rp] : master.aw_region;
   assign slave.aw_user    = BUF_REQ && DEPTH > 0 ? aw_q_user  [aw_rp] : master.aw_user;
   assign slave.aw_valid   = BUF_REQ && DEPTH > 0 ? aw_valid[aw_rp]    : master.aw_valid;

   // AR
   logic [ID_WIDTH-1:0]           ar_q_id     [DEPTH_LOC-1:0];
   logic [ADDR_WIDTH-1:0]         ar_q_addr   [DEPTH_LOC-1:0];
   logic [7:0]                    ar_q_len    [DEPTH_LOC-1:0];
   logic [2:0]                    ar_q_size   [DEPTH_LOC-1:0];
   logic [1:0]                    ar_q_burst  [DEPTH_LOC-1:0];
   logic                          ar_q_lock   [DEPTH_LOC-1:0];
   logic [3:0]                    ar_q_cache  [DEPTH_LOC-1:0];
   logic [2:0]                    ar_q_prot   [DEPTH_LOC-1:0];
   logic [3:0]                    ar_q_qos    [DEPTH_LOC-1:0];
   logic [3:0]                    ar_q_region [DEPTH_LOC-1:0];
   logic [USER_WIDTH-1:0]         ar_q_user   [DEPTH_LOC-1:0];
   logic [DEPTH_LOC-1:0]          ar_valid;
   logic [$clog2(DEPTH_LOC)-1:0]  ar_wp, ar_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        ar_rp <= 0;
        ar_wp <= 0;
        ar_valid <= 0;
     end else begin
        if(master.ar_valid && master.ar_ready) begin
           ar_wp <= incr(ar_wp);
           ar_valid[ar_wp] <= 1'b1;
        end

        if(slave.ar_valid && slave.ar_ready) begin
           ar_rp <= incr(ar_rp);
           ar_valid[ar_rp] <= 1'b0;
        end
     end

   always_ff @(posedge clk)
     if(master.ar_valid && master.ar_ready) begin
        ar_q_id    [ar_wp] <= master.ar_id;
        ar_q_addr  [ar_wp] <= master.ar_addr;
        ar_q_len   [ar_wp] <= master.ar_len;
        ar_q_size  [ar_wp] <= master.ar_size;
        ar_q_burst [ar_wp] <= master.ar_burst;
        ar_q_lock  [ar_wp] <= master.ar_lock;
        ar_q_cache [ar_wp] <= master.ar_cache;
        ar_q_prot  [ar_wp] <= master.ar_prot;
        ar_q_qos   [ar_wp] <= master.ar_qos;
        ar_q_region[ar_wp] <= master.ar_region;
        ar_q_user  [ar_wp] <= master.ar_user;
     end // if (master.ar_valid && master.ar_ready)

   assign master.ar_ready  = BUF_REQ && DEPTH > 0 ? !ar_valid[ar_wp]   : slave.ar_ready;
   assign slave.ar_id      = BUF_REQ && DEPTH > 0 ? ar_q_id    [ar_rp] : master.ar_id;
   assign slave.ar_addr    = BUF_REQ && DEPTH > 0 ? ar_q_addr  [ar_rp] : master.ar_addr;
   assign slave.ar_len     = BUF_REQ && DEPTH > 0 ? ar_q_len   [ar_rp] : master.ar_len;
   assign slave.ar_size    = BUF_REQ && DEPTH > 0 ? ar_q_size  [ar_rp] : master.ar_size;
   assign slave.ar_burst   = BUF_REQ && DEPTH > 0 ? ar_q_burst [ar_rp] : master.ar_burst;
   assign slave.ar_lock    = BUF_REQ && DEPTH > 0 ? ar_q_lock  [ar_rp] : master.ar_lock;
   assign slave.ar_cache   = BUF_REQ && DEPTH > 0 ? ar_q_cache [ar_rp] : master.ar_cache;
   assign slave.ar_prot    = BUF_REQ && DEPTH > 0 ? ar_q_prot  [ar_rp] : master.ar_prot;
   assign slave.ar_qos     = BUF_REQ && DEPTH > 0 ? ar_q_qos   [ar_rp] : master.ar_qos;
   assign slave.ar_region  = BUF_REQ && DEPTH > 0 ? ar_q_region[ar_rp] : master.ar_region;
   assign slave.ar_user    = BUF_REQ && DEPTH > 0 ? ar_q_user  [ar_rp] : master.ar_user;
   assign slave.ar_valid   = BUF_REQ && DEPTH > 0 ? ar_valid[ar_rp]    : master.ar_valid;

   // W
   logic [DATA_WIDTH-1:0]   w_q_data  [DEPTH_LOC-1:0];
   logic [DATA_WIDTH/8-1:0] w_q_strb  [DEPTH_LOC-1:0];
   logic                    w_q_last  [DEPTH_LOC-1:0];
   logic [USER_WIDTH-1:0]   w_q_user  [DEPTH_LOC-1:0];
   logic [DEPTH_LOC-1:0]    w_valid;
   logic [$clog2(DEPTH_LOC)-1:0] w_wp, w_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        w_rp <= 0;
        w_wp <= 0;
        w_valid <= 0;
     end else begin
        if(master.w_valid && master.w_ready) begin
           w_wp <= incr(w_wp);
           w_valid[w_wp] <= 1'b1;
        end

        if(slave.w_valid && slave.w_ready) begin
           w_rp <= incr(w_rp);
           w_valid[w_rp] <= 1'b0;
        end
     end

   always_ff @(posedge clk)
     if(master.w_valid && master.w_ready) begin
        w_q_data[w_wp] <= master.w_data;
        w_q_strb[w_wp] <= master.w_strb;
        w_q_last[w_wp] <= master.w_last;
        w_q_user[w_wp] <= master.w_user;
     end

   assign master.w_ready = BUF_REQ && DEPTH > 0 ? !w_valid[w_wp] : slave.w_ready;
   assign slave.w_data   = BUF_REQ && DEPTH > 0 ? w_q_data[w_rp] : master.w_data;
   assign slave.w_strb   = BUF_REQ && DEPTH > 0 ? w_q_strb[w_rp] : master.w_strb;
   assign slave.w_last   = BUF_REQ && DEPTH > 0 ? w_q_last[w_rp] : master.w_last;
   assign slave.w_user   = BUF_REQ && DEPTH > 0 ? w_q_user[w_rp] : master.w_user;
   assign slave.w_valid  = BUF_REQ && DEPTH > 0 ? w_valid[w_rp]  : master.w_valid;

   // B
   logic [ID_WIDTH-1:0]   b_q_id    [DEPTH_LOC-1:0];
   logic [1:0]            b_q_resp  [DEPTH_LOC-1:0];
   logic [USER_WIDTH-1:0] b_q_user  [DEPTH_LOC-1:0];
   logic [DEPTH_LOC-1:0]  b_valid;
   logic [$clog2(DEPTH_LOC)-1:0] b_wp, b_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        b_rp <= 0;
        b_wp <= 0;
        b_valid <= 0;
     end else begin
        if(slave.b_valid && slave.b_ready) begin
           b_wp <= incr(b_wp);
           b_valid[b_wp] <= 1'b1;
        end

        if(master.b_valid && master.b_ready) begin
           b_rp <= incr(b_rp);
           b_valid[b_rp] <= 1'b0;
        end
     end

   always_ff @(posedge clk)
     if(slave.b_valid && slave.b_ready) begin
        b_q_id[b_wp]   <= slave.b_id;
        b_q_resp[b_wp] <= slave.b_resp;
        b_q_user[b_wp] <= slave.b_user;
     end

   assign slave.b_ready  = BUF_RESP && DEPTH > 0 ? !b_valid[b_wp] : master.b_ready;
   assign master.b_id    = BUF_RESP && DEPTH > 0 ? b_q_id[b_rp]   : slave.b_id;
   assign master.b_resp  = BUF_RESP && DEPTH > 0 ? b_q_resp[b_rp] : slave.b_resp;
   assign master.b_user  = BUF_RESP && DEPTH > 0 ? b_q_user[b_rp] : slave.b_user;
   assign master.b_valid = BUF_RESP && DEPTH > 0 ? b_valid[b_rp]  : slave.b_valid;

   // R
   logic [DATA_WIDTH-1:0]   r_q_data  [DEPTH_LOC-1:0];
   logic [DATA_WIDTH/8-1:0] r_q_strb  [DEPTH_LOC-1:0];
   logic                    r_q_last  [DEPTH_LOC-1:0];
   logic [ID_WIDTH-1:0]     r_q_id    [DEPTH_LOC-1:0];
   logic [1:0]              r_q_resp  [DEPTH_LOC-1:0];
   logic [USER_WIDTH-1:0]   r_q_user  [DEPTH_LOC-1:0];
   logic [DEPTH_LOC-1:0]    r_valid;
   logic [$clog2(DEPTH_LOC)-1:0] r_wp, r_rp;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        r_rp <= 0;
        r_wp <= 0;
        r_valid <= 0;
     end else begin
        if(slave.r_valid && slave.r_ready) begin
           r_wp <= incr(r_wp);
           r_valid[r_wp] <= 1'b1;
        end

        if(master.r_valid && master.r_ready) begin
           r_rp <= incr(r_rp);
           r_valid[r_rp] <= 1'b0;
        end
     end

   always_ff @(posedge clk)
     if(slave.r_valid && slave.r_ready) begin
        r_q_id[r_wp]   <= slave.r_id;
        r_q_data[r_wp] <= slave.r_data;
        r_q_resp[r_wp] <= slave.r_resp;
        r_q_last[r_wp] <= slave.r_last;
        r_q_user[r_wp] <= slave.r_user;
     end

   assign slave.r_ready  = BUF_RESP && DEPTH > 0 ? !r_valid[r_wp] : master.r_ready;
   assign master.r_id    = BUF_RESP && DEPTH > 0 ? r_q_id[r_rp]   : slave.r_id;
   assign master.r_data  = BUF_RESP && DEPTH > 0 ? r_q_data[r_rp] : slave.r_data;
   assign master.r_resp  = BUF_RESP && DEPTH > 0 ? r_q_resp[r_rp] : slave.r_resp;
   assign master.r_last  = BUF_RESP && DEPTH > 0 ? r_q_last[r_rp] : slave.r_last;
   assign master.r_user  = BUF_RESP && DEPTH > 0 ? r_q_user[r_rp] : slave.r_user;
   assign master.r_valid = BUF_RESP && DEPTH > 0 ? r_valid[r_rp]  : slave.r_valid;

endmodule // nasti_buf
