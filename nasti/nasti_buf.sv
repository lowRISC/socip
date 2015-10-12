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
    nasti_channel.slave  s,
    nasti_channel.master m
    );

   int    i;

   generate
      if(DEPTH > 0) begin

         typedef struct packed unsigned {
            logic [ID_WIDTH-1:0] id;
            logic [ADDR_WIDTH-1:0] addr;
            logic [7:0]            len;
            logic [2:0]            size;
            logic [1:0]            burst;
            logic                  lock;
            logic [3:0]            cache;
            logic [2:0]            prot;
            logic [3:0]            qos;
            logic [3:0]            region;
            logic [USER_WIDTH-1:0] user;
         } pkt_addr_t;

         typedef struct packed unsigned {
            logic [ID_WIDTH-1:0]   id;
            logic [1:0]            resp;
            logic [USER_WIDTH-1:0] user;
         } pkt_resp_t;

         typedef struct packed unsigned {
            logic [DATA_WIDTH-1:0] data;
            logic [DATA_WIDTH/8-1:0] strb;
            logic                    last;
            logic [USER_WIDTH-1:0]   user;
         } pkt_data_t;

         function logic [$clog2(DEPTH)-1:0] incr(logic [$clog2(DEPTH)-1:0] p);
            logic [$clog2(DEPTH):0]  p_incr;
            p_incr = p + 1;
            return p_incr >= DEPTH ? p_incr - DEPTH : p_incr;
         endfunction // incr

         // AW
         if(BUF_REQ) begin
            pkt_addr_t                  aw_q [DEPTH-1:0];
            logic [DEPTH-1:0]           aw_valid;
            logic [$clog2(DEPTH)-1:0]   aw_wp, aw_rp;

            always_ff @(posedge clk or negedge rstn)
              if(!rstn) begin
                 aw_rp <= 0;
                 aw_wp <= 0;
                 aw_valid <= 0;
              end else begin
                 if(s.aw_valid && s.aw_ready) begin
                    aw_wp <= incr(aw_wp);
                    aw_valid[aw_wp] <= 1'b1;
                 end

                 if(m.aw_valid && m.aw_ready) begin
                    aw_rp <= incr(aw_rp);
                    aw_valid[aw_rp] <= 1'b0;
                 end
              end

            always_ff @(posedge clk)
              if(s.aw_valid && s.aw_ready) begin
                 aw_q[aw_wp].id     <= s.aw_id;
                 aw_q[aw_wp].addr   <= s.aw_addr;
                 aw_q[aw_wp].len    <= s.aw_len;
                 aw_q[aw_wp].size   <= s.aw_size;
                 aw_q[aw_wp].burst  <= s.aw_burst;
                 aw_q[aw_wp].lock   <= s.aw_lock;
                 aw_q[aw_wp].cache  <= s.aw_cache;
                 aw_q[aw_wp].prot   <= s.aw_prot;
                 aw_q[aw_wp].qos    <= s.aw_qos;
                 aw_q[aw_wp].region <= s.aw_region;
                 aw_q[aw_wp].user   <= s.aw_user;
              end // if (s.aw_valid && s.aw_ready)

            assign s.aw_ready  = !aw_valid[aw_wp];
            assign m.aw_id     = aw_q[aw_rp].id;
            assign m.aw_addr   = aw_q[aw_rp].addr;
            assign m.aw_len    = aw_q[aw_rp].len;
            assign m.aw_size   = aw_q[aw_rp].size;
            assign m.aw_burst  = aw_q[aw_rp].burst;
            assign m.aw_lock   = aw_q[aw_rp].lock;
            assign m.aw_cache  = aw_q[aw_rp].cache;
            assign m.aw_prot   = aw_q[aw_rp].prot;
            assign m.aw_qos    = aw_q[aw_rp].qos;
            assign m.aw_region = aw_q[aw_rp].region;
            assign m.aw_user   = aw_q[aw_rp].user;
            assign m.aw_valid  = aw_valid[aw_rp];
         end else begin // if (BUF_REQ)
            assign s.aw_ready  = m.aw_ready;
            assign m.aw_id     = s.aw_id;
            assign m.aw_addr   = s.aw_addr;
            assign m.aw_len    = s.aw_len;
            assign m.aw_size   = s.aw_size;
            assign m.aw_burst  = s.aw_burst;
            assign m.aw_lock   = s.aw_lock;
            assign m.aw_cache  = s.aw_cache;
            assign m.aw_prot   = s.aw_prot;
            assign m.aw_qos    = s.aw_qos;
            assign m.aw_region = s.aw_region;
            assign m.aw_user   = s.aw_user;
            assign m.aw_valid  = s.aw_valid;
         end

         // AR
         if(BUF_REQ) begin
            pkt_addr_t                  ar_q [DEPTH-1:0];
            logic [DEPTH-1:0]           ar_valid;
            logic [$clog2(DEPTH)-1:0]   ar_wp, ar_rp;

            always_ff @(posedge clk or negedge rstn)
              if(!rstn) begin
                 ar_rp <= 0;
                 ar_wp <= 0;
                 ar_valid <= 0;
              end else begin
                 if(s.ar_valid && s.ar_ready) begin
                    ar_wp <= incr(ar_wp);
                    ar_valid[ar_wp] <= 1'b1;
                 end

                 if(m.ar_valid && m.ar_ready) begin
                    ar_rp <= incr(ar_rp);
                    ar_valid[ar_rp] <= 1'b0;
                 end
              end

            always_ff @(posedge clk)
              if(s.ar_valid && s.ar_ready) begin
                 ar_q[ar_wp].id     <= s.ar_id;
                 ar_q[ar_wp].addr   <= s.ar_addr;
                 ar_q[ar_wp].len    <= s.ar_len;
                 ar_q[ar_wp].size   <= s.ar_size;
                 ar_q[ar_wp].burst  <= s.ar_burst;
                 ar_q[ar_wp].lock   <= s.ar_lock;
                 ar_q[ar_wp].cache  <= s.ar_cache;
                 ar_q[ar_wp].prot   <= s.ar_prot;
                 ar_q[ar_wp].qos    <= s.ar_qos;
                 ar_q[ar_wp].region <= s.ar_region;
                 ar_q[ar_wp].user   <= s.ar_user;
              end // if (s.ar_valid && s.ar_ready)

            assign s.ar_ready  = !ar_valid[ar_wp];
            assign m.ar_id     = ar_q[ar_rp].id;
            assign m.ar_addr   = ar_q[ar_rp].addr;
            assign m.ar_len    = ar_q[ar_rp].len;
            assign m.ar_size   = ar_q[ar_rp].size;
            assign m.ar_burst  = ar_q[ar_rp].burst;
            assign m.ar_lock   = ar_q[ar_rp].lock;
            assign m.ar_cache  = ar_q[ar_rp].cache;
            assign m.ar_prot   = ar_q[ar_rp].prot;
            assign m.ar_qos    = ar_q[ar_rp].qos;
            assign m.ar_region = ar_q[ar_rp].region;
            assign m.ar_user   = ar_q[ar_rp].user;
            assign m.ar_valid  = ar_valid[ar_rp];
         end else begin // if (BUF_REQ)
            assign s.ar_ready  = m.ar_ready;
            assign m.ar_id     = s.ar_id;
            assign m.ar_addr   = s.ar_addr;
            assign m.ar_len    = s.ar_len;
            assign m.ar_size   = s.ar_size;
            assign m.ar_burst  = s.ar_burst;
            assign m.ar_lock   = s.ar_lock;
            assign m.ar_cache  = s.ar_cache;
            assign m.ar_prot   = s.ar_prot;
            assign m.ar_qos    = s.ar_qos;
            assign m.ar_region = s.ar_region;
            assign m.ar_user   = s.ar_user;
            assign m.ar_valid  = s.ar_valid;
         end

         // W
         if(BUF_REQ) begin
            pkt_data_t                  w_q  [DEPTH-1:0];
            logic [DEPTH-1:0]           w_valid;
            logic [$clog2(DEPTH)-1:0]   w_wp, w_rp;

            always_ff @(posedge clk or negedge rstn)
              if(!rstn) begin
                 w_rp <= 0;
                 w_wp <= 0;
                 w_valid <= 0;
              end else begin
                 if(s.w_valid && s.w_ready) begin
                    w_wp <= incr(w_wp);
                    w_valid[w_wp] <= 1'b1;
                 end

                 if(m.w_valid && m.w_ready) begin
                    w_rp <= incr(w_rp);
                    w_valid[w_rp] <= 1'b0;
                 end
              end

            always_ff @(posedge clk)
              if(s.w_valid && s.w_ready) begin
                 w_q[w_wp].data <= s.w_data;
                 w_q[w_wp].strb <= s.w_strb;
                 w_q[w_wp].last <= s.w_last;
                 w_q[w_wp].user <= s.w_user;
              end

            assign s.w_ready = !w_valid[w_wp];
            assign m.w_data  = w_q[w_rp].data;
            assign m.w_strb  = w_q[w_rp].strb;
            assign m.w_last  = w_q[w_rp].last;
            assign m.w_user  = w_q[w_rp].user;
            assign m.w_valid = w_valid[w_rp];
         end else begin
            assign s.w_ready = m.w_ready;
            assign m.w_data  = s.w_data;
            assign m.w_strb  = s.w_strb;
            assign m.w_last  = s.w_last;
            assign m.w_user  = s.w_user;
            assign m.w_valid = s.w_valid;
         end // else: !if(BUF_REQ)

         // B
         if(BUF_RESP) begin
            pkt_resp_t b_q  [DEPTH-1:0];
            logic [DEPTH-1:0]           b_valid;
            logic [$clog2(DEPTH)-1:0]   b_wp, b_rp;

            always_ff @(posedge clk or negedge rstn)
              if(!rstn) begin
                 b_rp <= 0;
                 b_wp <= 0;
                 b_valid <= 0;
              end else begin
                 if(m.b_valid && m.b_ready) begin
                    b_wp <= incr(b_wp);
                    b_valid[b_wp] <= 1'b1;
                 end

                 if(s.b_valid && s.b_ready) begin
                    b_rp <= incr(b_rp);
                    b_valid[b_rp] <= 1'b0;
                 end
              end

            always_ff @(posedge clk)
              if(m.b_valid && m.b_ready) begin
                 b_q[b_wp].id   <= m.b_id;
                 b_q[b_wp].resp <= m.b_resp;
                 b_q[b_wp].user <= m.b_user;
              end

            assign m.b_ready = !b_valid[b_wp];
            assign s.b_id    = b_q[b_rp].id;
            assign s.b_resp  = b_q[b_rp].resp;
            assign s.b_user  = b_q[b_rp].user;
            assign s.b_valid = b_valid[b_rp];
         end else begin
            assign m.b_ready = s.b_ready;
            assign s.b_id    = m.b_id;
            assign s.b_resp  = m.b_resp;
            assign s.b_user  = m.b_user;
            assign s.b_valid = m.b_valid;
         end

         // R
         if(BUF_RESP) begin
            pkt_data_t                  r_data_q [DEPTH-1:0];
            pkt_resp_t                  r_resp_q [DEPTH-1:0];
            logic [DEPTH-1:0]           r_valid;
            logic [$clog2(DEPTH)-1:0]   r_wp, r_rp;

            always_ff @(posedge clk or negedge rstn)
              if(!rstn) begin
                 r_rp <= 0;
                 r_wp <= 0;
                 r_valid <= 0;
              end else begin
                 if(m.r_valid && m.r_ready) begin
                    r_wp <= incr(r_wp);
                    r_valid[r_wp] <= 1'b1;
                 end

                 if(s.r_valid && s.r_ready) begin
                    r_rp <= incr(r_rp);
                    r_valid[r_rp] <= 1'b0;
                 end
              end

            always_ff @(posedge clk)
              if(m.r_valid && m.r_ready) begin
                 r_resp_q[r_wp].id   <= m.r_id;
                 r_data_q[r_wp].data <= m.r_data;
                 r_resp_q[r_wp].resp <= m.r_resp;
                 r_data_q[r_wp].last <= m.r_last;
                 r_resp_q[r_wp].user <= m.r_user;
              end

            assign m.r_ready = !r_valid[r_wp];
            assign s.r_id    = r_resp_q[r_rp].id;
            assign s.r_data  = r_data_q[r_rp].data;
            assign s.r_resp  = r_resp_q[r_rp].resp;
            assign s.r_last  = r_data_q[r_rp].last;
            assign s.r_user  = r_resp_q[r_rp].user;
            assign s.r_valid = r_valid[r_rp];
         end else begin
            assign m.r_ready = s.r_valid;
            assign s.r_id    = m.r_id;
            assign s.r_data  = m.r_data;
            assign s.r_resp  = m.r_resp;
            assign s.r_last  = m.r_last;
            assign s.r_user  = m.r_user;
            assign s.r_valid = m.r_valid;
         end
      end else begin // if (DEPTH > 0)
         assign s.aw_ready  = m.aw_ready;
         assign m.aw_id     = s.aw_id;
         assign m.aw_addr   = s.aw_addr;
         assign m.aw_len    = s.aw_len;
         assign m.aw_size   = s.aw_size;
         assign m.aw_burst  = s.aw_burst;
         assign m.aw_lock   = s.aw_lock;
         assign m.aw_cache  = s.aw_cache;
         assign m.aw_prot   = s.aw_prot;
         assign m.aw_qos    = s.aw_qos;
         assign m.aw_region = s.aw_region;
         assign m.aw_user   = s.aw_user;
         assign m.aw_valid  = s.aw_valid;

         assign s.ar_ready  = m.ar_ready;
         assign m.ar_id     = s.ar_id;
         assign m.ar_addr   = s.ar_addr;
         assign m.ar_len    = s.ar_len;
         assign m.ar_size   = s.ar_size;
         assign m.ar_burst  = s.ar_burst;
         assign m.ar_lock   = s.ar_lock;
         assign m.ar_cache  = s.ar_cache;
         assign m.ar_prot   = s.ar_prot;
         assign m.ar_qos    = s.ar_qos;
         assign m.ar_region = s.ar_region;
         assign m.ar_user   = s.ar_user;
         assign m.ar_valid  = s.ar_valid;

         assign s.w_ready = m.w_ready;
         assign m.w_data  = s.w_data;
         assign m.w_strb  = s.w_strb;
         assign m.w_last  = s.w_last;
         assign m.w_user  = s.w_user;
         assign m.w_valid = s.w_valid;

         assign m.b_ready = s.b_ready;
         assign s.b_id    = m.b_id;
         assign s.b_resp  = m.b_resp;
         assign s.b_user  = m.b_user;
         assign s.b_valid = m.b_valid;

         assign m.r_ready = s.r_valid;
         assign s.r_id    = m.r_id;
         assign s.r_data  = m.r_data;
         assign s.r_resp  = m.r_resp;
         assign s.r_last  = m.r_last;
         assign s.r_user  = m.r_user;
         assign s.r_valid = m.r_valid;
      end // else: !if(DEPTH > 0)
   endgenerate

endmodule // nasti_buf
