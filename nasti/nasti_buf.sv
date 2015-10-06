// See LICENSE for license details.

module nasti_buf
  #(
    DEPTH = 1,                  // buffer depth
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input clk, rstn,
    nasti_channel.slave  s,
    nasti_channel.master m,    
    );

   int    i;

   typedef struct {
      logic [ID_WIDTH-1:0]   id;
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

   typedef struct {
      logic [ID_WIDTH-1:0]   id;
      logic [1:0]            resp;
      logic [USER_WIDTH-1:0] user;
   } pkt_resp_t;

   typedef struct {
      logic [DATA_WIDTH-1:0]   data;
      logic [DATA_WIDTH/8-1:0] strb;
      logic                    last;
      logic [USER_WIDTH-1:0]   user;
   } pkt_data_t;

   pkt_addr_t aw_q [DEPTH-1:0];
   pkt_addr_t ar_q [DEPTH-1:0];
   pkt_data_t w_q  [DEPTH-1:0];
   pkt_resp_t b_q  [DEPTH-1:0];
   pkt_data_t r_data_q [DEPTH-1:0];
   pkt_resp_t r_resp_q [DEPTH-1:0];

   logic [DEPTH-1:0]           aw_valid;
   logic [$clog2(DEPTH)-1:0]   aw_wp, aw_rp;
   logic [DEPTH-1:0]           ar_valid;
   logic [$clog2(DEPTH)-1:0]   ar_wp, ar_rp;
   logic [DEPTH-1:0]           w_valid;
   logic [$clog2(DEPTH)-1:0]   w_wp, w_rp;
   logic [DEPTH-1:0]           b_valid;
   logic [$clog2(DEPTH)-1:0]   b_wp, b_rp;
   logic [DEPTH-1:0]           r_valid;
   logic [$clog2(DEPTH)-1:0]   r_wp, r_rp;
   

   function logic [$clog2(DEPTH)-1:0] incr(logic [$clog2(DEPTH)-1:0] p);
      logic [$clog2(DEPTH):0]  p_incr = p + 1;
      return p_incr >= DEPTH ? p_incr - DEPTH : p_incr;
   endfunction //

   // AW
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

   assign s.aw_ready = !aw_valid[aw_wp];

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

   // AR
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

   assign s.ar_ready = !ar_valid[ar_wp];

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

   // W
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

   assign m.w_data = w_q[w_rp].data;
   assign m.w_strb = w_q[w_rp].strb;
   assign m.w_last = w_q[w_rp].last;
   assign m.w_user = w_q[w_rp].user;
   assign m.w_valid = w_valid[w_rp];

   // B
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
   m.b_ready = !b_valid[b_wp];

   assign s.b_id   <= b_q[b_rp].id;
   assign s.b_resp <= b_q[b_rp].resp;
   assign s.b_user <= b_q[b_rp].user;
   assign s.b_valid <= b_valid[b_rp];
   
   // R
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
        r_q[r_wp].id   <= m.r_id;
        r_q[r_wp].data <= m.r_data;
        r_q[r_wp].resp <= m.r_resp;
        r_q[r_wp].last <= m.r_last;
        r_q[r_wp].user <= m.r_user;
     end
   m.r_ready = !r_valid[r_wp];

   assign s.r_id   <= r_q[r_rp].id;
   assign s.r_data <= r_q[r_rp].data;
   assign s.r_resp <= r_q[r_rp].resp;
   assign s.r_last <= r_q[r_rp].last;
   assign s.r_user <= r_q[r_rp].user;
   assign s.r_valid <= r_valid[r_rp];

endmodule // nasti_buf

