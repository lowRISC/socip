// See LICENSE for license details.

module nasti_demux
  #(
    N_PORT = 2,                 // number of demultiplexed ports, maximal 8
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not in use
    [ADDR_WIDTH-1:0] BASE0 = 0, // base address for port 0
    [ADDR_WIDTH-1:0] BASE1 = 0, // base address for port 1
    [ADDR_WIDTH-1:0] BASE2 = 0, // base address for port 2
    [ADDR_WIDTH-1:0] BASE3 = 0, // base address for port 3
    [ADDR_WIDTH-1:0] BASE4 = 0, // base address for port 4
    [ADDR_WIDTH-1:0] BASE5 = 0, // base address for port 5
    [ADDR_WIDTH-1:0] BASE6 = 0, // base address for port 6
    [ADDR_WIDTH-1:0] BASE7 = 0, // base address for port 7
    [ADDR_WIDTH-1:0] MASK0 = 0, // address mask for port 0
    [ADDR_WIDTH-1:0] MASK1 = 0, // address mask for port 1
    [ADDR_WIDTH-1:0] MASK2 = 0, // address mask for port 2
    [ADDR_WIDTH-1:0] MASK3 = 0, // address mask for port 3
    [ADDR_WIDTH-1:0] MASK4 = 0, // address mask for port 4
    [ADDR_WIDTH-1:0] MASK5 = 0, // address mask for port 5
    [ADDR_WIDTH-1:0] MASK6 = 0, // address mask for port 6
    [ADDR_WIDTH-1:0] MASK7 = 0  // address mask for port 7
    )
   (
    input clk, rstn,
    nasti_channel.slave  s,
    nasti_channel.master m,
    );

   genvar i;
   
   // AW and W channels
   logic       lock;
   logic [2:0] locked_port;
   logic [7:0] aw_port_match_oh;
   logic [2:0] aw_port_match_uint, aw_port_sel;

   assign aw_port_match_oh = {
                              MASK7 != 0 && (s.aw_addr & ~MASK7) == BASE7,
                              MASK6 != 0 && (s.aw_addr & ~MASK6) == BASE6,
                              MASK5 != 0 && (s.aw_addr & ~MASK5) == BASE5,
                              MASK4 != 0 && (s.aw_addr & ~MASK4) == BASE4,
                              MASK3 != 0 && (s.aw_addr & ~MASK3) == BASE3,
                              MASK2 != 0 && (s.aw_addr & ~MASK2) == BASE2,
                              MASK1 != 0 && (s.aw_addr & ~MASK1) == BASE1,
                              MASK0 != 0 && (s.aw_addr & ~MASK0) == BASE0,
                              };
   OHToUInt #(8) aw_conv(.oh(aw_port_match_oh), .d(aw_port_match_uint));
   
   assign aw_port_sel = lock ? locked_port : aw_port_match_uint;
   
   always_ff(posedge clk or nedgedge rstn)
     if(!rstn)
       lock <= 1'b0;
     else if(s.aw_valid && s.aw_ready) begin
        lock <= 1'b1;
        locked_port <= aw_port_sel;
     end else if(s.w_last && s.w_valid && s.w_ready)
       lock <= 1'b0;

   generate
      for(i=0; i<8; i++) begin
         assign m.aw_id[i]      = s.aw_id;
         assign m.aw_addr[i]    = s.aw_addr;
         assign m.aw_len[i]     = s.aw_len;
         assign m.aw_size[i]    = s.aw_size;
         assign m.aw_burst[i]   = s.aw_burst;
         assign m.aw_lock[i]    = s.aw_lock;
         assign m.aw_cache[i]   = s.aw_cache;
         assign m.aw_prot[i]    = s.aw_prot;
         assign m.aw_qos[i]     = s.aw_qos;
         assign m.aw_region[i]  = s.aw_region;
         assign m.aw_user[i]    = s.aw_user;
         assign m.aw_valid[i]   = !lock && aw_port_sel == i && s.aw_valid;
         assign m.w_data[i]     = s.w_data;
         assign m.w_strb[i]     = s.w_strb;
         assign m.w_last[i]     = s.w_last;
         assign m.w_user[i]     = s.w_user;
         assign m.w_valid[i]    = lock && aw_port_sel == i && s.w_valid;
      end // for (i=0; i<8; i++)
   endgenerate
   
   assign s.aw_ready = !lock && m.aw_ready[aw_port_sel];
   assign s.w_ready = lock && m.w_ready[aw_port_sel];
      
      
   


endmodule // nasti_demux

   
