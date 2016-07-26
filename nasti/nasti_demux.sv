// See LICENSE for license details.

// up to 8 master ports
module nasti_demux
  #(
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not in use
    LITE_MODE = 0,              // whether work in Lite mode
    ESCAPE_ENABLE = 0,          // whether treat output port 0 as an escaping port
    logic [ADDR_WIDTH-1:0] BASE0 = 0, // base address for port 0
    logic [ADDR_WIDTH-1:0] BASE1 = 0, // base address for port 1
    logic [ADDR_WIDTH-1:0] BASE2 = 0, // base address for port 2
    logic [ADDR_WIDTH-1:0] BASE3 = 0, // base address for port 3
    logic [ADDR_WIDTH-1:0] BASE4 = 0, // base address for port 4
    logic [ADDR_WIDTH-1:0] BASE5 = 0, // base address for port 5
    logic [ADDR_WIDTH-1:0] BASE6 = 0, // base address for port 6
    logic [ADDR_WIDTH-1:0] BASE7 = 0, // base address for port 7
    logic [ADDR_WIDTH-1:0] MASK0 = 0, // address mask for port 0
    logic [ADDR_WIDTH-1:0] MASK1 = 0, // address mask for port 1
    logic [ADDR_WIDTH-1:0] MASK2 = 0, // address mask for port 2
    logic [ADDR_WIDTH-1:0] MASK3 = 0, // address mask for port 3
    logic [ADDR_WIDTH-1:0] MASK4 = 0, // address mask for port 4
    logic [ADDR_WIDTH-1:0] MASK5 = 0, // address mask for port 5
    logic [ADDR_WIDTH-1:0] MASK6 = 0, // address mask for port 6
    logic [ADDR_WIDTH-1:0] MASK7 = 0  // address mask for port 7
    )
   (
    input clk, rstn,
    nasti_channel.slave  master,
    nasti_channel.master slave
    );

   genvar i;

   // function to find active channel
   function logic [2:0] sel_active (logic [7:0] rdy);
      // assume rdy arbitrated and one-hot
      int i;
      for(i=0; i<8; i++)
        if(rdy[i]) return i;
      return 0;
   endfunction // sel_active

   // port matcher
   function logic [2:0] port_match(logic [ADDR_WIDTH-1:0] addr);
      if(MASK0 != 0 && (addr & ~MASK0) == BASE0) return 0;
      if(MASK1 != 0 && (addr & ~MASK1) == BASE1) return 1;
      if(MASK2 != 0 && (addr & ~MASK2) == BASE2) return 2;
      if(MASK3 != 0 && (addr & ~MASK3) == BASE3) return 3;
      if(MASK4 != 0 && (addr & ~MASK4) == BASE4) return 4;
      if(MASK5 != 0 && (addr & ~MASK5) == BASE5) return 5;
      if(MASK6 != 0 && (addr & ~MASK6) == BASE6) return 6;
      if(MASK7 != 0 && (addr & ~MASK7) == BASE7) return 7;
      return 0;
   endfunction // port_match

   // port enable
   logic [7:0] port_enable;
   assign port_enable[0] = MASK0 != 0 || ESCAPE_ENABLE;
   assign port_enable[1] = MASK1 != 0;
   assign port_enable[2] = MASK2 != 0;
   assign port_enable[3] = MASK3 != 0;
   assign port_enable[4] = MASK4 != 0;
   assign port_enable[5] = MASK5 != 0;
   assign port_enable[6] = MASK6 != 0;
   assign port_enable[7] = MASK7 != 0;

   // AW and W channels
   logic       lock;
   logic [2:0] locked_port;
   logic [2:0] aw_port_sel;

   assign aw_port_sel = lock ? locked_port : port_match(master.aw_addr);

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       lock <= 1'b0;
     else if(master.aw_valid && master.aw_ready) begin
        lock <= 1'b1;
        locked_port <= aw_port_sel;
     end else if((LITE_MODE || master.w_last) && master.w_valid && master.w_ready)
       lock <= 1'b0;

   generate
      for(i=0; i<8; i++) begin
         assign slave.aw_id[i]      = master.aw_id;
         assign slave.aw_addr[i]    = master.aw_addr;
         assign slave.aw_len[i]     = master.aw_len;
         assign slave.aw_size[i]    = master.aw_size;
         assign slave.aw_burst[i]   = master.aw_burst;
         assign slave.aw_lock[i]    = master.aw_lock;
         assign slave.aw_cache[i]   = master.aw_cache;
         assign slave.aw_prot[i]    = master.aw_prot;
         assign slave.aw_qos[i]     = master.aw_qos;
         assign slave.aw_region[i]  = master.aw_region;
         assign slave.aw_user[i]    = master.aw_user;
         assign slave.aw_valid[i]   = port_enable[i] && !lock && aw_port_sel == i && master.aw_valid;
         assign slave.w_data[i]     = master.w_data;
         assign slave.w_strb[i]     = master.w_strb;
         assign slave.w_last[i]     = master.w_last;
         assign slave.w_user[i]     = master.w_user;
         assign slave.w_valid[i]    = port_enable[i] && lock && aw_port_sel == i && master.w_valid;
      end // for (i=0; i<8; i++)
   endgenerate

   assign master.aw_ready = !lock && slave.aw_ready[aw_port_sel];
   assign master.w_ready = lock && slave.w_ready[aw_port_sel];

   // AR channel
   logic [2:0] ar_port_sel;
   assign ar_port_sel = port_match(master.ar_addr);

   generate
      for(i=0; i<8; i++) begin
         assign slave.ar_id[i]      = master.ar_id;
         assign slave.ar_addr[i]    = master.ar_addr;
         assign slave.ar_len[i]     = master.ar_len;
         assign slave.ar_size[i]    = master.ar_size;
         assign slave.ar_burst[i]   = master.ar_burst;
         assign slave.ar_lock[i]    = master.ar_lock;
         assign slave.ar_cache[i]   = master.ar_cache;
         assign slave.ar_prot[i]    = master.ar_prot;
         assign slave.ar_qos[i]     = master.ar_qos;
         assign slave.ar_region[i]  = master.ar_region;
         assign slave.ar_user[i]    = master.ar_user;
         assign slave.ar_valid[i]   = port_enable[i] && ar_port_sel == i && master.ar_valid;
      end // for (i=0; i<8; i++)
   endgenerate

   assign master.ar_ready = slave.ar_ready[ar_port_sel];
   
   // B channel
   logic [7:0] b_valid, b_gnt;
   logic [2:0] b_port_sel;

   assign b_valid = port_enable & slave.b_valid;

   arbiter_rr #(8)
   b_arb (
          .*,
          .req     ( b_valid ),
          .gnt     ( b_gnt   ),
          .enable  ( 1'b1    )
          );
   assign b_port_sel = sel_active(b_gnt);

   assign master.b_id    = slave.b_id[b_port_sel];
   assign master.b_resp  = slave.b_resp[b_port_sel];
   assign master.b_user  = slave.b_user[b_port_sel];
   assign master.b_valid = slave.b_valid[b_port_sel];
   assign slave.b_ready  = master.b_ready ? b_gnt : 0;

   // R channel
   logic [7:0] r_valid, r_gnt;
   logic [2:0] r_port_sel;

   assign r_valid = port_enable & slave.r_valid;

   arbiter_rr #(8)
   r_arb (
          .*,
          .req     ( r_valid ),
          .gnt     ( r_gnt   ),
          .enable  ( 1'b1    )
          );
   assign r_port_sel = sel_active(r_gnt);

   assign master.r_id    = slave.r_id[r_port_sel];
   assign master.r_data  = slave.r_data[r_port_sel];
   assign master.r_resp  = slave.r_resp[r_port_sel];
   assign master.r_last  = slave.r_last[r_port_sel];
   assign master.r_user  = slave.r_user[r_port_sel];
   assign master.r_valid = slave.r_valid[r_port_sel];
   assign slave.r_ready  = master.r_ready ? r_gnt : 0;

endmodule // nasti_demux
