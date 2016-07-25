// See LICENSE for license details.

// up to 8 slave ports
module nasti_mux
  #(
    W_MAX = 2,                  // maximal parallel write transactions
    R_MAX = 2,                  // maximal parallel read transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not in use
    LITE_MODE = 0               // whether work in Lite mode
    )
   (
    input clk, rstn,
    nasti_channel.slave  master,
    nasti_channel.master slave
    );

   // dummy
   genvar i;

   // transaction records
   logic [W_MAX-1:0][ID_WIDTH-1:0]    write_vec_id;
   logic [W_MAX-1:0][2:0]             write_vec_port;
   logic [W_MAX-1:0]                  write_vec_valid;
   logic [R_MAX-1:0][ID_WIDTH-1:0]    read_vec_id;
   logic [R_MAX-1:0][2:0]             read_vec_port;
   logic [R_MAX-1:0]                  read_vec_valid;

   logic [$clog2(W_MAX)-1:0] write_wp;
   logic [$clog2(R_MAX)-1:0] read_wp;
   logic write_full, read_full;

   assign write_full = &write_vec_valid;
   assign read_full = &read_vec_valid;

   function logic[$clog2(W_MAX)-1:0] get_write_wp();
      automatic int i;
      for(i=0; i<W_MAX; i++)
        if(!write_vec_valid[i])
          return i;
      return 0;
   endfunction //
   assign write_wp = get_write_wp();

   function logic[$clog2(R_MAX)-1:0] get_read_wp();
      automatic int i;
      for(i=0; i<R_MAX; i++)
        if(!read_vec_valid[i])
          return i;
      return 0;
   endfunction //
   assign read_wp = get_read_wp();

   function logic [2:0] toInt (logic [7:0] dat);
      automatic int i;
      for(i=0; i<8; i++)
        if(dat[i]) return i;
      return 0;
   endfunction // toInt
      
   function logic [$clog2(W_MAX)-1:0] toInt_w (logic [W_MAX-1:0] dat);
      automatic int i;
      for(i=0; i<W_MAX; i++)
        if(dat[i]) return i;
      return 0;
   endfunction // toInt

   function logic [$clog2(R_MAX)-1:0] toInt_r (logic [R_MAX:0] dat);
      automatic int i;
      for(i=0; i<R_MAX; i++)
        if(dat[i]) return i;
      return 0;
   endfunction // toInt

   // AW/W/B channels
   logic       lock;
   logic [2:0] locked_port;
   logic [2:0] aw_port_sel;
   logic [7:0] aw_gnt;

   arbiter_rr #(8)
   aw_arb (
           .*,
           .req    ( master.aw_valid           ),
           .gnt    ( aw_gnt               ),
           .enable ( !lock && !write_full )
           );

   assign aw_port_sel = lock ? locked_port : toInt(aw_gnt);

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       lock <= 1'b0;
     else if(master.aw_valid[aw_port_sel] && master.aw_ready[aw_port_sel]) begin
        lock <= 1'b1;
        locked_port <= aw_port_sel;
     end else if((LITE_MODE || master.w_last[aw_port_sel]) && master.w_valid[aw_port_sel] && master.w_ready[aw_port_sel])
       lock <= 1'b0;

   assign slave.aw_id      = master.aw_id[aw_port_sel];
   assign slave.aw_addr    = master.aw_addr[aw_port_sel];
   assign slave.aw_len     = master.aw_len[aw_port_sel];
   assign slave.aw_size    = master.aw_size[aw_port_sel];
   assign slave.aw_burst   = master.aw_burst[aw_port_sel];
   assign slave.aw_lock    = master.aw_lock[aw_port_sel];
   assign slave.aw_cache   = master.aw_cache[aw_port_sel];
   assign slave.aw_prot    = master.aw_prot[aw_port_sel];
   assign slave.aw_qos     = master.aw_qos[aw_port_sel];
   assign slave.aw_region  = master.aw_region[aw_port_sel];
   assign slave.aw_user    = master.aw_user[aw_port_sel];
   assign slave.aw_valid   = !lock && master.aw_valid[aw_port_sel];
   assign slave.w_data     = master.w_data[aw_port_sel];
   assign slave.w_strb     = master.w_strb[aw_port_sel];
   assign slave.w_last     = master.w_last[aw_port_sel];
   assign slave.w_user     = master.w_user[aw_port_sel];
   assign slave.w_valid    = lock && master.w_valid[aw_port_sel];
   assign master.aw_ready  = slave.aw_ready ? (1 << aw_port_sel) : 0;
   assign master.w_ready   = slave.w_ready ? (1 << aw_port_sel) : 0;

   logic [W_MAX-1:0]          write_match;
   logic [$clog2(W_MAX)-1:0]  write_match_index;

   generate
      for(i=0; i<W_MAX; i++)
        assign write_match[i] = write_vec_valid[i] && slave.b_valid && slave.b_id === write_vec_id[i];
   endgenerate
   assign write_match_index = toInt_w(write_match);

   generate
      for(i=0; i<8; i++) begin
         assign master.b_id[i]    = slave.b_id;
         assign master.b_resp[i]  = slave.b_resp;
         assign master.b_user[i]  = slave.b_user;
         assign master.b_valid[i] = slave.b_valid && write_vec_port[write_match_index] == i;
      end
   endgenerate
   assign slave.b_ready = master.b_ready[write_vec_port[write_match_index]];

   // update write_vec
   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        write_vec_valid <= 0;
     end else begin
        if(slave.aw_valid && slave.aw_ready) begin
           write_vec_id[write_wp] <= slave.aw_id;
           write_vec_port[write_wp] <= aw_port_sel;
           write_vec_valid[write_wp] <= 1'b1;
        end

        if(slave.b_valid && slave.b_ready)
          write_vec_valid[write_match_index] <= 1'b0;
     end

   // AR and R
   logic [2:0] ar_port_sel;
   logic [7:0] ar_gnt;

   arbiter_rr #(8)
   ar_arb (
           .*,
           .req    ( master.ar_valid  ),
           .gnt    ( ar_gnt      ),
           .enable ( !read_full  )
           );
   assign ar_port_sel = toInt(ar_gnt);

   assign slave.ar_id      = master.ar_id[ar_port_sel];
   assign slave.ar_addr    = master.ar_addr[ar_port_sel];
   assign slave.ar_len     = master.ar_len[ar_port_sel];
   assign slave.ar_size    = master.ar_size[ar_port_sel];
   assign slave.ar_burst   = master.ar_burst[ar_port_sel];
   assign slave.ar_lock    = master.ar_lock[ar_port_sel];
   assign slave.ar_cache   = master.ar_cache[ar_port_sel];
   assign slave.ar_prot    = master.ar_prot[ar_port_sel];
   assign slave.ar_qos     = master.ar_qos[ar_port_sel];
   assign slave.ar_region  = master.ar_region[ar_port_sel];
   assign slave.ar_user    = master.ar_user[ar_port_sel];
   assign slave.ar_valid   = master.ar_valid[ar_port_sel];
   assign master.ar_ready  = slave.ar_ready ? (1 << ar_port_sel) : 0;

   logic [R_MAX-1:0]          read_match;
   logic [$clog2(R_MAX)-1:0]  read_match_index;

   generate
      for(i=0; i<R_MAX; i++)
        assign read_match[i] = read_vec_valid[i] && slave.r_valid && slave.r_id === read_vec_id[i];
   endgenerate
   assign read_match_index = toInt_r(read_match);

   generate
      for(i=0; i<8; i++) begin
         assign master.r_id[i]    = slave.r_id;
         assign master.r_data[i]  = slave.r_data;
         assign master.r_resp[i]  = slave.r_resp;
         assign master.r_last[i]  = slave.r_last;
         assign master.r_user[i]  = slave.r_user;
         assign master.r_valid[i] = slave.r_valid && read_vec_port[read_match_index] == i;
      end
   endgenerate
   assign slave.r_ready = master.r_ready[read_vec_port[read_match_index]];

   // update read_vec
   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        int n;
        for(n=0; n<R_MAX; n++)
          read_vec_valid[n] <= 1'b0;
     end else begin
        if(slave.ar_valid && slave.ar_ready) begin
           read_vec_id[read_wp] <= slave.ar_id;
           read_vec_port[read_wp] <= ar_port_sel;
           read_vec_valid[read_wp] <= 1'b1;
        end

        if(slave.r_valid && slave.r_ready)
          read_vec_valid[read_match_index] <= 1'b0;
     end

endmodule // nasti_mux
