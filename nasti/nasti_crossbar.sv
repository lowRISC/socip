// See LICENSE for license details.

// up to 8x8 slave ports
module nasti_crossbar
  #(
    N_INPUT = 1,                // number of input ports
    N_OUTPUT = 1,               // number of output ports
    IB_DEPTH = 0,               // input buffer depth
    OB_DEPTH = 0,               // output buffer depth
    W_MAX = 2,                  // maximal parallel write transactions
    R_MAX = 2,                  // maximal parallel read transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not
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
    nasti_channel.master m
    );

   genvar i, j;

   // painful, why vivado does not support array of interfaces
   nasti_channel ib_i0, ib_i1, ib_i2, ib_i3, ib_i4, ib_i5, ib_i6, ib_i7;
   nasti_channel ib_o0, ib_o1, ib_o2, ib_o3, ib_o4, ib_o5, ib_o6, ib_o7;
   nasti_channel dm_o0, dm_o1, dm_o2, dm_o3, dm_o4, dm_o5, dm_o6, dm_o7;
   nasti_channel mx_i0, mx_i1, mx_i2, mx_i3, mx_i4, mx_i5, mx_i6, mx_i7;
   nasti_channel ob_i0, ob_i1, ob_i2, ob_i3, ob_i4, ob_i5, ob_i6, ob_i7;
   nasti_channel ob_o0, ob_o1, ob_o2, ob_o3, ob_o4, ob_o5, ob_o6, ob_o7;
   defparam dm_i0.N_PORT = 8;
   defparam dm_i1.N_PORT = 8;
   defparam dm_i2.N_PORT = 8;
   defparam dm_i3.N_PORT = 8;
   defparam dm_i4.N_PORT = 8;
   defparam dm_i5.N_PORT = 8;
   defparam dm_i6.N_PORT = 8;
   defparam dm_i7.N_PORT = 8;
   defparam mx_i0.N_PORT = 8;
   defparam mx_i1.N_PORT = 8;
   defparam mx_i2.N_PORT = 8;
   defparam mx_i3.N_PORT = 8;
   defparam mx_i4.N_PORT = 8;
   defparam mx_i5.N_PORT = 8;
   defparam mx_i6.N_PORT = 8;
   defparam mx_i7.N_PORT = 8;

   // slicing input channels and possibly insert input buffers   
   generate
      if(IB_DEPTH == 0) begin   // No input buffer
         nasti_channel_slicer #(N_INPUT)
         input_slicer (
                       .s  ( s      ),
                       .m0 ( ib_o0  ), .m1 ( ib_o1  ), .m2 ( ib_o2  ), .m3 ( ib_o3  ),
                       .m4 ( ib_o4  ), .m5 ( ib_o5  ), .m6 ( ib_o6  ), .m7 ( ib_o7  ));
      end else begin            // Has input buffer
         nasti_channel_slicer #(N_INPUT)
         input_slicer (
                       .s  ( s      ),
                       .m0 ( ib_i0  ), .m1 ( ib_i1  ), .m2 ( ib_i2  ), .m3 ( ib_i3  ),
                       .m4 ( ib_i4  ), .m5 ( ib_i5  ), .m6 ( ib_i6  ), .m7 ( ib_i7  ));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf0 (.s(ib_i0), .m(ib_o0));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf1 (.s(ib_i1), .m(ib_o1));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf2 (.s(ib_i2), .m(ib_o2));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf3 (.s(ib_i3), .m(ib_o3));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf4 (.s(ib_i4), .m(ib_o4));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf5 (.s(ib_i5), .m(ib_o5));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf6 (.s(ib_i6), .m(ib_o6));

         nasti_buf #(.DEPTH(IB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         ibuf7 (.s(ib_i7), .m(ib_o7));
      end // else: !if(IB_DEPTH == 0)
   endgenerate

   // demux according to addresses
   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux0 (.*, .s(ib_o0), .m(dm_o0));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux1 (.*, .s(ib_o1), .m(dm_o1));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux2 (.*, .s(ib_o2), .m(dm_o2));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux3 (.*, .s(ib_o3), .m(dm_o3));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux4 (.*, .s(ib_o4), .m(dm_o4));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux5 (.*, .s(ib_o5), .m(dm_o5));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux6 (.*, .s(ib_o6), .m(dm_o6));

   nasti_demux #(.ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                 .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH),
                 .BASE0(BASE0), .BASE1(BASE1), .BASE2(BASE2), .BASE3(BASE3),
                 .BASE4(BASE4), .BASE5(BASE5), .BASE6(BASE6), .BASE7(BASE7),
                 .MASK0(MASK0), .MASK1(MASK1), .MASK2(MASK3), .MASK3(MASK3),
                 .MASK4(MASK4), .MASK5(MASK5), .MASK6(MASK6), .MASK7(MASK7))
   demux7 (.*, .s(ib_o7), .m(dm_o7));

   // internal wire connection
   logic [1:0][7:0][7:0][ID_WIDTH-1:0]     aw_id,     ar_id;
   logic [1:0][7:0][7:0][ADDR_WIDTH-1:0]   aw_addr,   ar_addr;
   logic [1:0][7:0][7:0][7:0]              aw_len,    ar_len;
   logic [1:0][7:0][7:0][2:0]              aw_size,   ar_size;
   logic [1:0][7:0][7:0][1:0]              aw_burst,  ar_burst;
   logic [1:0][7:0][7:0]                   aw_lock,   ar_lock;
   logic [1:0][7:0][7:0][3:0]              aw_cache,  ar_cache;
   logic [1:0][7:0][7:0][2:0]              aw_prot,   ar_prot;
   logic [1:0][7:0][7:0][3:0]              aw_qos,    ar_qos;
   logic [1:0][7:0][7:0][3:0]              aw_region, ar_region;
   logic [1:0][7:0][7:0][USER_WIDTH-1:0]   aw_user,   ar_user;
   logic [1:0][7:0][7:0]                   aw_valid,  ar_valid;
   logic [1:0][7:0][7:0]                   aw_ready,  ar_ready;

   // write/read data
   logic [1:0][7:0][7:0][DATA_WIDTH-1:0]   w_data,    r_data;
   logic [1:0][7:0][7:0][DATA_WIDTH/8-1:0] w_strb;
   logic [1:0][7:0][7:0]                   w_last,    r_last;
   logic [1:0][7:0][7:0][USER_WIDTH-1:0]   w_user;
   logic [1:0][7:0][7:0]                   w_valid;
   logic [1:0][7:0][7:0]                   w_ready;

   // write/read response
   logic [1:0][7:0][7:0][ID_WIDTH-1:0]     b_id,      r_id;
   logic [1:0][7:0][7:0][1:0]              b_resp,    r_resp;
   logic [1:0][7:0][7:0][USER_WIDTH-1:0]   b_user,    r_user;
   logic [1:0][7:0][7:0]                   b_valid,   r_valid;
   logic [1:0][7:0][7:0]                   b_ready,   r_ready;

   // painfully manuall connect them all to interfaces
   assign aw_id[0][0]      = dm_o0.aw_id;
   assign aw_addr[0][0]    = dm_o0.aw_addr;
   assign aw_len[0][0]     = dm_o0.aw_len;
   assign aw_size[0][0]    = dm_o0.aw_size;
   assign aw_burst[0][0]   = dm_o0.aw_burst;
   assign aw_lock[0][0]    = dm_o0.aw_lock;
   assign aw_cache[0][0]   = dm_o0.aw_cache;
   assign aw_prot[0][0]    = dm_o0.aw_prot;
   assign aw_qos[0][0]     = dm_o0.aw_qos;
   assign aw_region[0][0]  = dm_o0.aw_region;
   assign aw_user[0][0]    = dm_o0.aw_user;
   assign aw_valid[0][0]   = dm_o0.aw_valid;
   assign dm_o0.aw_ready   = aw_ready[0][0];
   assign ar_id[0][0]      = dm_o0.ar_id;
   assign ar_addr[0][0]    = dm_o0.ar_addr;
   assign ar_len[0][0]     = dm_o0.ar_len;
   assign ar_size[0][0]    = dm_o0.ar_size;
   assign ar_burst[0][0]   = dm_o0.ar_burst;
   assign ar_lock[0][0]    = dm_o0.ar_lock;
   assign ar_cache[0][0]   = dm_o0.ar_cache;
   assign ar_prot[0][0]    = dm_o0.ar_prot;
   assign ar_qos[0][0]     = dm_o0.ar_qos;
   assign ar_region[0][0]  = dm_o0.ar_region;
   assign ar_user[0][0]    = dm_o0.ar_user;
   assign ar_valid[0][0]   = dm_o0.ar_valid;
   assign dm_o0.ar_ready   = ar_ready[0][0];
   assign w_data[0][0]     = dm_o0.w_data;
   assign w_strb[0][0]     = dm_o0.w_strb;
   assign w_last[0][0]     = dm_o0.w_last;
   assign w_user[0][0]     = dm_o0.w_user;
   assign w_valid[0][0]    = dm_o0.w_valid;
   assign dm_o0.w_ready    = w_ready[0][0];
   assign dm_o0.b_id       = b_id[0][0];
   assign dm_o0.b_resp     = b_resp[0][0];
   assign dm_o0.b_user     = b_user[0][0];
   assign dm_o0.b_valid    = b_valid[0][0];
   assign b_ready[0][0]    = dm_o0.b_ready;
   assign dm_o0.r_id       = r_id[0][0];
   assign dm_o0.r_data     = r_data[0][0];
   assign dm_o0.r_resp     = r_resp[0][0];
   assign dm_o0.r_last     = r_last[0][0];
   assign dm_o0.r_user     = r_user[0][0];
   assign dm_o0.r_valid    = r_valid[0][0];
   assign r_ready[0][0]    = dm_o0.r_ready;

   assign aw_id[0][1]      = dm_o1.aw_id;
   assign aw_addr[0][1]    = dm_o1.aw_addr;
   assign aw_len[0][1]     = dm_o1.aw_len;
   assign aw_size[0][1]    = dm_o1.aw_size;
   assign aw_burst[0][1]   = dm_o1.aw_burst;
   assign aw_lock[0][1]    = dm_o1.aw_lock;
   assign aw_cache[0][1]   = dm_o1.aw_cache;
   assign aw_prot[0][1]    = dm_o1.aw_prot;
   assign aw_qos[0][1]     = dm_o1.aw_qos;
   assign aw_region[0][1]  = dm_o1.aw_region;
   assign aw_user[0][1]    = dm_o1.aw_user;
   assign aw_valid[0][1]   = dm_o1.aw_valid;
   assign dm_o1.aw_ready   = aw_ready[0][1];
   assign ar_id[0][1]      = dm_o1.ar_id;
   assign ar_addr[0][1]    = dm_o1.ar_addr;
   assign ar_len[0][1]     = dm_o1.ar_len;
   assign ar_size[0][1]    = dm_o1.ar_size;
   assign ar_burst[0][1]   = dm_o1.ar_burst;
   assign ar_lock[0][1]    = dm_o1.ar_lock;
   assign ar_cache[0][1]   = dm_o1.ar_cache;
   assign ar_prot[0][1]    = dm_o1.ar_prot;
   assign ar_qos[0][1]     = dm_o1.ar_qos;
   assign ar_region[0][1]  = dm_o1.ar_region;
   assign ar_user[0][1]    = dm_o1.ar_user;
   assign ar_valid[0][1]   = dm_o1.ar_valid;
   assign dm_o1.ar_ready   = ar_ready[0][1];
   assign w_data[0][1]     = dm_o1.w_data;
   assign w_strb[0][1]     = dm_o1.w_strb;
   assign w_last[0][1]     = dm_o1.w_last;
   assign w_user[0][1]     = dm_o1.w_user;
   assign w_valid[0][1]    = dm_o1.w_valid;
   assign dm_o1.w_ready    = w_ready[0][1];
   assign dm_o1.b_id       = b_id[0][1];
   assign dm_o1.b_resp     = b_resp[0][1];
   assign dm_o1.b_user     = b_user[0][1];
   assign dm_o1.b_valid    = b_valid[0][1];
   assign b_ready[0][1]    = dm_o1.b_ready;
   assign dm_o1.r_id       = r_id[0][1];
   assign dm_o1.r_data     = r_data[0][1];
   assign dm_o1.r_resp     = r_resp[0][1];
   assign dm_o1.r_last     = r_last[0][1];
   assign dm_o1.r_user     = r_user[0][1];
   assign dm_o1.r_valid    = r_valid[0][1];
   assign r_ready[0][1]    = dm_o1.r_ready;

   assign aw_id[0][2]      = dm_o2.aw_id;
   assign aw_addr[0][2]    = dm_o2.aw_addr;
   assign aw_len[0][2]     = dm_o2.aw_len;
   assign aw_size[0][2]    = dm_o2.aw_size;
   assign aw_burst[0][2]   = dm_o2.aw_burst;
   assign aw_lock[0][2]    = dm_o2.aw_lock;
   assign aw_cache[0][2]   = dm_o2.aw_cache;
   assign aw_prot[0][2]    = dm_o2.aw_prot;
   assign aw_qos[0][2]     = dm_o2.aw_qos;
   assign aw_region[0][2]  = dm_o2.aw_region;
   assign aw_user[0][2]    = dm_o2.aw_user;
   assign aw_valid[0][2]   = dm_o2.aw_valid;
   assign dm_o2.aw_ready   = aw_ready[0][2];
   assign ar_id[0][2]      = dm_o2.ar_id;
   assign ar_addr[0][2]    = dm_o2.ar_addr;
   assign ar_len[0][2]     = dm_o2.ar_len;
   assign ar_size[0][2]    = dm_o2.ar_size;
   assign ar_burst[0][2]   = dm_o2.ar_burst;
   assign ar_lock[0][2]    = dm_o2.ar_lock;
   assign ar_cache[0][2]   = dm_o2.ar_cache;
   assign ar_prot[0][2]    = dm_o2.ar_prot;
   assign ar_qos[0][2]     = dm_o2.ar_qos;
   assign ar_region[0][2]  = dm_o2.ar_region;
   assign ar_user[0][2]    = dm_o2.ar_user;
   assign ar_valid[0][2]   = dm_o2.ar_valid;
   assign dm_o2.ar_ready   = ar_ready[0][2];
   assign w_data[0][2]     = dm_o2.w_data;
   assign w_strb[0][2]     = dm_o2.w_strb;
   assign w_last[0][2]     = dm_o2.w_last;
   assign w_user[0][2]     = dm_o2.w_user;
   assign w_valid[0][2]    = dm_o2.w_valid;
   assign dm_o2.w_ready    = w_ready[0][2];
   assign dm_o2.b_id       = b_id[0][2];
   assign dm_o2.b_resp     = b_resp[0][2];
   assign dm_o2.b_user     = b_user[0][2];
   assign dm_o2.b_valid    = b_valid[0][2];
   assign b_ready[0][2]    = dm_o2.b_ready;
   assign dm_o2.r_id       = r_id[0][2];
   assign dm_o2.r_data     = r_data[0][2];
   assign dm_o2.r_resp     = r_resp[0][2];
   assign dm_o2.r_last     = r_last[0][2];
   assign dm_o2.r_user     = r_user[0][2];
   assign dm_o2.r_valid    = r_valid[0][2];
   assign r_ready[0][2]    = dm_o2.r_ready;

   assign aw_id[0][3]      = dm_o3.aw_id;
   assign aw_addr[0][3]    = dm_o3.aw_addr;
   assign aw_len[0][3]     = dm_o3.aw_len;
   assign aw_size[0][3]    = dm_o3.aw_size;
   assign aw_burst[0][3]   = dm_o3.aw_burst;
   assign aw_lock[0][3]    = dm_o3.aw_lock;
   assign aw_cache[0][3]   = dm_o3.aw_cache;
   assign aw_prot[0][3]    = dm_o3.aw_prot;
   assign aw_qos[0][3]     = dm_o3.aw_qos;
   assign aw_region[0][3]  = dm_o3.aw_region;
   assign aw_user[0][3]    = dm_o3.aw_user;
   assign aw_valid[0][3]   = dm_o3.aw_valid;
   assign dm_o3.aw_ready   = aw_ready[0][3];
   assign ar_id[0][3]      = dm_o3.ar_id;
   assign ar_addr[0][3]    = dm_o3.ar_addr;
   assign ar_len[0][3]     = dm_o3.ar_len;
   assign ar_size[0][3]    = dm_o3.ar_size;
   assign ar_burst[0][3]   = dm_o3.ar_burst;
   assign ar_lock[0][3]    = dm_o3.ar_lock;
   assign ar_cache[0][3]   = dm_o3.ar_cache;
   assign ar_prot[0][3]    = dm_o3.ar_prot;
   assign ar_qos[0][3]     = dm_o3.ar_qos;
   assign ar_region[0][3]  = dm_o3.ar_region;
   assign ar_user[0][3]    = dm_o3.ar_user;
   assign ar_valid[0][3]   = dm_o3.ar_valid;
   assign dm_o3.ar_ready   = ar_ready[0][3];
   assign w_data[0][3]     = dm_o3.w_data;
   assign w_strb[0][3]     = dm_o3.w_strb;
   assign w_last[0][3]     = dm_o3.w_last;
   assign w_user[0][3]     = dm_o3.w_user;
   assign w_valid[0][3]    = dm_o3.w_valid;
   assign dm_o3.w_ready    = w_ready[0][3];
   assign dm_o3.b_id       = b_id[0][3];
   assign dm_o3.b_resp     = b_resp[0][3];
   assign dm_o3.b_user     = b_user[0][3];
   assign dm_o3.b_valid    = b_valid[0][3];
   assign b_ready[0][3]    = dm_o3.b_ready;
   assign dm_o3.r_id       = r_id[0][3];
   assign dm_o3.r_data     = r_data[0][3];
   assign dm_o3.r_resp     = r_resp[0][3];
   assign dm_o3.r_last     = r_last[0][3];
   assign dm_o3.r_user     = r_user[0][3];
   assign dm_o3.r_valid    = r_valid[0][3];
   assign r_ready[0][3]    = dm_o3.r_ready;

   assign aw_id[0][4]      = dm_o4.aw_id;
   assign aw_addr[0][4]    = dm_o4.aw_addr;
   assign aw_len[0][4]     = dm_o4.aw_len;
   assign aw_size[0][4]    = dm_o4.aw_size;
   assign aw_burst[0][4]   = dm_o4.aw_burst;
   assign aw_lock[0][4]    = dm_o4.aw_lock;
   assign aw_cache[0][4]   = dm_o4.aw_cache;
   assign aw_prot[0][4]    = dm_o4.aw_prot;
   assign aw_qos[0][4]     = dm_o4.aw_qos;
   assign aw_region[0][4]  = dm_o4.aw_region;
   assign aw_user[0][4]    = dm_o4.aw_user;
   assign aw_valid[0][4]   = dm_o4.aw_valid;
   assign dm_o4.aw_ready   = aw_ready[0][4];
   assign ar_id[0][4]      = dm_o4.ar_id;
   assign ar_addr[0][4]    = dm_o4.ar_addr;
   assign ar_len[0][4]     = dm_o4.ar_len;
   assign ar_size[0][4]    = dm_o4.ar_size;
   assign ar_burst[0][4]   = dm_o4.ar_burst;
   assign ar_lock[0][4]    = dm_o4.ar_lock;
   assign ar_cache[0][4]   = dm_o4.ar_cache;
   assign ar_prot[0][4]    = dm_o4.ar_prot;
   assign ar_qos[0][4]     = dm_o4.ar_qos;
   assign ar_region[0][4]  = dm_o4.ar_region;
   assign ar_user[0][4]    = dm_o4.ar_user;
   assign ar_valid[0][4]   = dm_o4.ar_valid;
   assign dm_o4.ar_ready   = ar_ready[0][4];
   assign w_data[0][4]     = dm_o4.w_data;
   assign w_strb[0][4]     = dm_o4.w_strb;
   assign w_last[0][4]     = dm_o4.w_last;
   assign w_user[0][4]     = dm_o4.w_user;
   assign w_valid[0][4]    = dm_o4.w_valid;
   assign dm_o4.w_ready    = w_ready[0][4];
   assign dm_o4.b_id       = b_id[0][4];
   assign dm_o4.b_resp     = b_resp[0][4];
   assign dm_o4.b_user     = b_user[0][4];
   assign dm_o4.b_valid    = b_valid[0][4];
   assign b_ready[0][4]    = dm_o4.b_ready;
   assign dm_o4.r_id       = r_id[0][4];
   assign dm_o4.r_data     = r_data[0][4];
   assign dm_o4.r_resp     = r_resp[0][4];
   assign dm_o4.r_last     = r_last[0][4];
   assign dm_o4.r_user     = r_user[0][4];
   assign dm_o4.r_valid    = r_valid[0][4];
   assign r_ready[0][4]    = dm_o4.r_ready;

   assign aw_id[0][5]      = dm_o5.aw_id;
   assign aw_addr[0][5]    = dm_o5.aw_addr;
   assign aw_len[0][5]     = dm_o5.aw_len;
   assign aw_size[0][5]    = dm_o5.aw_size;
   assign aw_burst[0][5]   = dm_o5.aw_burst;
   assign aw_lock[0][5]    = dm_o5.aw_lock;
   assign aw_cache[0][5]   = dm_o5.aw_cache;
   assign aw_prot[0][5]    = dm_o5.aw_prot;
   assign aw_qos[0][5]     = dm_o5.aw_qos;
   assign aw_region[0][5]  = dm_o5.aw_region;
   assign aw_user[0][5]    = dm_o5.aw_user;
   assign aw_valid[0][5]   = dm_o5.aw_valid;
   assign dm_o5.aw_ready   = aw_ready[0][5];
   assign ar_id[0][5]      = dm_o5.ar_id;
   assign ar_addr[0][5]    = dm_o5.ar_addr;
   assign ar_len[0][5]     = dm_o5.ar_len;
   assign ar_size[0][5]    = dm_o5.ar_size;
   assign ar_burst[0][5]   = dm_o5.ar_burst;
   assign ar_lock[0][5]    = dm_o5.ar_lock;
   assign ar_cache[0][5]   = dm_o5.ar_cache;
   assign ar_prot[0][5]    = dm_o5.ar_prot;
   assign ar_qos[0][5]     = dm_o5.ar_qos;
   assign ar_region[0][5]  = dm_o5.ar_region;
   assign ar_user[0][5]    = dm_o5.ar_user;
   assign ar_valid[0][5]   = dm_o5.ar_valid;
   assign dm_o5.ar_ready   = ar_ready[0][5];
   assign w_data[0][5]     = dm_o5.w_data;
   assign w_strb[0][5]     = dm_o5.w_strb;
   assign w_last[0][5]     = dm_o5.w_last;
   assign w_user[0][5]     = dm_o5.w_user;
   assign w_valid[0][5]    = dm_o5.w_valid;
   assign dm_o5.w_ready    = w_ready[0][5];
   assign dm_o5.b_id       = b_id[0][5];
   assign dm_o5.b_resp     = b_resp[0][5];
   assign dm_o5.b_user     = b_user[0][5];
   assign dm_o5.b_valid    = b_valid[0][5];
   assign b_ready[0][5]    = dm_o5.b_ready;
   assign dm_o5.r_id       = r_id[0][5];
   assign dm_o5.r_data     = r_data[0][5];
   assign dm_o5.r_resp     = r_resp[0][5];
   assign dm_o5.r_last     = r_last[0][5];
   assign dm_o5.r_user     = r_user[0][5];
   assign dm_o5.r_valid    = r_valid[0][5];
   assign r_ready[0][5]    = dm_o5.r_ready;

   assign aw_id[0][6]      = dm_o6.aw_id;
   assign aw_addr[0][6]    = dm_o6.aw_addr;
   assign aw_len[0][6]     = dm_o6.aw_len;
   assign aw_size[0][6]    = dm_o6.aw_size;
   assign aw_burst[0][6]   = dm_o6.aw_burst;
   assign aw_lock[0][6]    = dm_o6.aw_lock;
   assign aw_cache[0][6]   = dm_o6.aw_cache;
   assign aw_prot[0][6]    = dm_o6.aw_prot;
   assign aw_qos[0][6]     = dm_o6.aw_qos;
   assign aw_region[0][6]  = dm_o6.aw_region;
   assign aw_user[0][6]    = dm_o6.aw_user;
   assign aw_valid[0][6]   = dm_o6.aw_valid;
   assign dm_o6.aw_ready   = aw_ready[0][6];
   assign ar_id[0][6]      = dm_o6.ar_id;
   assign ar_addr[0][6]    = dm_o6.ar_addr;
   assign ar_len[0][6]     = dm_o6.ar_len;
   assign ar_size[0][6]    = dm_o6.ar_size;
   assign ar_burst[0][6]   = dm_o6.ar_burst;
   assign ar_lock[0][6]    = dm_o6.ar_lock;
   assign ar_cache[0][6]   = dm_o6.ar_cache;
   assign ar_prot[0][6]    = dm_o6.ar_prot;
   assign ar_qos[0][6]     = dm_o6.ar_qos;
   assign ar_region[0][6]  = dm_o6.ar_region;
   assign ar_user[0][6]    = dm_o6.ar_user;
   assign ar_valid[0][6]   = dm_o6.ar_valid;
   assign dm_o6.ar_ready   = ar_ready[0][6];
   assign w_data[0][6]     = dm_o6.w_data;
   assign w_strb[0][6]     = dm_o6.w_strb;
   assign w_last[0][6]     = dm_o6.w_last;
   assign w_user[0][6]     = dm_o6.w_user;
   assign w_valid[0][6]    = dm_o6.w_valid;
   assign dm_o6.w_ready    = w_ready[0][6];
   assign dm_o6.b_id       = b_id[0][6];
   assign dm_o6.b_resp     = b_resp[0][6];
   assign dm_o6.b_user     = b_user[0][6];
   assign dm_o6.b_valid    = b_valid[0][6];
   assign b_ready[0][6]    = dm_o6.b_ready;
   assign dm_o6.r_id       = r_id[0][6];
   assign dm_o6.r_data     = r_data[0][6];
   assign dm_o6.r_resp     = r_resp[0][6];
   assign dm_o6.r_last     = r_last[0][6];
   assign dm_o6.r_user     = r_user[0][6];
   assign dm_o6.r_valid    = r_valid[0][6];
   assign r_ready[0][6]    = dm_o6.r_ready;

   assign aw_id[0][7]      = dm_o7.aw_id;
   assign aw_addr[0][7]    = dm_o7.aw_addr;
   assign aw_len[0][7]     = dm_o7.aw_len;
   assign aw_size[0][7]    = dm_o7.aw_size;
   assign aw_burst[0][7]   = dm_o7.aw_burst;
   assign aw_lock[0][7]    = dm_o7.aw_lock;
   assign aw_cache[0][7]   = dm_o7.aw_cache;
   assign aw_prot[0][7]    = dm_o7.aw_prot;
   assign aw_qos[0][7]     = dm_o7.aw_qos;
   assign aw_region[0][7]  = dm_o7.aw_region;
   assign aw_user[0][7]    = dm_o7.aw_user;
   assign aw_valid[0][7]   = dm_o7.aw_valid;
   assign dm_o7.aw_ready   = aw_ready[0][7];
   assign ar_id[0][7]      = dm_o7.ar_id;
   assign ar_addr[0][7]    = dm_o7.ar_addr;
   assign ar_len[0][7]     = dm_o7.ar_len;
   assign ar_size[0][7]    = dm_o7.ar_size;
   assign ar_burst[0][7]   = dm_o7.ar_burst;
   assign ar_lock[0][7]    = dm_o7.ar_lock;
   assign ar_cache[0][7]   = dm_o7.ar_cache;
   assign ar_prot[0][7]    = dm_o7.ar_prot;
   assign ar_qos[0][7]     = dm_o7.ar_qos;
   assign ar_region[0][7]  = dm_o7.ar_region;
   assign ar_user[0][7]    = dm_o7.ar_user;
   assign ar_valid[0][7]   = dm_o7.ar_valid;
   assign dm_o7.ar_ready   = ar_ready[0][7];
   assign w_data[0][7]     = dm_o7.w_data;
   assign w_strb[0][7]     = dm_o7.w_strb;
   assign w_last[0][7]     = dm_o7.w_last;
   assign w_user[0][7]     = dm_o7.w_user;
   assign w_valid[0][7]    = dm_o7.w_valid;
   assign dm_o7.w_ready    = w_ready[0][7];
   assign dm_o7.b_id       = b_id[0][7];
   assign dm_o7.b_resp     = b_resp[0][7];
   assign dm_o7.b_user     = b_user[0][7];
   assign dm_o7.b_valid    = b_valid[0][7];
   assign b_ready[0][7]    = dm_o7.b_ready;
   assign dm_o7.r_id       = r_id[0][7];
   assign dm_o7.r_data     = r_data[0][7];
   assign dm_o7.r_resp     = r_resp[0][7];
   assign dm_o7.r_last     = r_last[0][7];
   assign dm_o7.r_user     = r_user[0][7];
   assign dm_o7.r_valid    = r_valid[0][7];
   assign r_ready[0][7]    = dm_o7.r_ready;

   assign mx_i0.aw_id     = aw_id[1][0];
   assign mx_i0.aw_addr   = aw_addr[1][0];
   assign mx_i0.aw_len    = aw_len[1][0];
   assign mx_i0.aw_size   = aw_size[1][0];
   assign mx_i0.aw_burst  = aw_burst[1][0];
   assign mx_i0.aw_lock   = aw_lock[1][0];
   assign mx_i0.aw_cache  = aw_cache[1][0];
   assign mx_i0.aw_prot   = aw_prot[1][0];
   assign mx_i0.aw_qos    = aw_qos[1][0];
   assign mx_i0.aw_region = aw_region[1][0];
   assign mx_i0.aw_user   = aw_user[1][0];
   assign mx_i0.aw_valid  = aw_valid[1][0];
   assign aw_ready[1][0]  = mx_i0.aw_ready;
   assign mx_i0.ar_id     = ar_id[1][0];
   assign mx_i0.ar_addr   = ar_addr[1][0];
   assign mx_i0.ar_len    = ar_len[1][0];
   assign mx_i0.ar_size   = ar_size[1][0];
   assign mx_i0.ar_burst  = ar_burst[1][0];
   assign mx_i0.ar_lock   = ar_lock[1][0];
   assign mx_i0.ar_cache  = ar_cache[1][0];
   assign mx_i0.ar_prot   = ar_prot[1][0];
   assign mx_i0.ar_qos    = ar_qos[1][0];
   assign mx_i0.ar_region = ar_region[1][0];
   assign mx_i0.ar_user   = ar_user[1][0];
   assign mx_i0.ar_valid  = ar_valid[1][0];
   assign ar_ready[1][0]  = mx_i0.ar_ready;
   assign mx_i0.w_data    = w_data[1][0];
   assign mx_i0.w_strb    = w_strb[1][0];
   assign mx_i0.w_last    = w_last[1][0];
   assign mx_i0.w_user    = w_user[1][0];
   assign mx_i0.w_valid   = w_valid[1][0];
   assign w_ready[1][0]   = mx_i0.w_ready;
   assign b_id[1][0]      = mx_i0.b_id;
   assign b_resp[1][0]    = mx_i0.b_resp;
   assign b_user[1][0]    = mx_i0.b_user;
   assign b_valid[1][0]   = mx_i0.b_valid;
   assign mx_i0.b_ready   = b_ready[1][0];
   assign r_id[1][0]      = mx_i0.r_id;
   assign r_data[1][0]    = mx_i0.r_data;
   assign r_resp[1][0]    = mx_i0.r_resp;
   assign r_last[1][0]    = mx_i0.r_last;
   assign r_user[1][0]    = mx_i0.r_user;
   assign r_valid[1][0]   = mx_i0.r_valid;
   assign mx_i0.r_ready   = r_ready[1][0];

   assign mx_i1.aw_id     = aw_id[1][1];
   assign mx_i1.aw_addr   = aw_addr[1][1];
   assign mx_i1.aw_len    = aw_len[1][1];
   assign mx_i1.aw_size   = aw_size[1][1];
   assign mx_i1.aw_burst  = aw_burst[1][1];
   assign mx_i1.aw_lock   = aw_lock[1][1];
   assign mx_i1.aw_cache  = aw_cache[1][1];
   assign mx_i1.aw_prot   = aw_prot[1][1];
   assign mx_i1.aw_qos    = aw_qos[1][1];
   assign mx_i1.aw_region = aw_region[1][1];
   assign mx_i1.aw_user   = aw_user[1][1];
   assign mx_i1.aw_valid  = aw_valid[1][1];
   assign aw_ready[1][1]  = mx_i1.aw_ready;
   assign mx_i1.ar_id     = ar_id[1][1];
   assign mx_i1.ar_addr   = ar_addr[1][1];
   assign mx_i1.ar_len    = ar_len[1][1];
   assign mx_i1.ar_size   = ar_size[1][1];
   assign mx_i1.ar_burst  = ar_burst[1][1];
   assign mx_i1.ar_lock   = ar_lock[1][1];
   assign mx_i1.ar_cache  = ar_cache[1][1];
   assign mx_i1.ar_prot   = ar_prot[1][1];
   assign mx_i1.ar_qos    = ar_qos[1][1];
   assign mx_i1.ar_region = ar_region[1][1];
   assign mx_i1.ar_user   = ar_user[1][1];
   assign mx_i1.ar_valid  = ar_valid[1][1];
   assign ar_ready[1][1]  = mx_i1.ar_ready;
   assign mx_i1.w_data    = w_data[1][1];
   assign mx_i1.w_strb    = w_strb[1][1];
   assign mx_i1.w_last    = w_last[1][1];
   assign mx_i1.w_user    = w_user[1][1];
   assign mx_i1.w_valid   = w_valid[1][1];
   assign w_ready[1][1]   = mx_i1.w_ready;
   assign b_id[1][1]      = mx_i1.b_id;
   assign b_resp[1][1]    = mx_i1.b_resp;
   assign b_user[1][1]    = mx_i1.b_user;
   assign b_valid[1][1]   = mx_i1.b_valid;
   assign mx_i1.b_ready   = b_ready[1][1];
   assign r_id[1][1]      = mx_i1.r_id;
   assign r_data[1][1]    = mx_i1.r_data;
   assign r_resp[1][1]    = mx_i1.r_resp;
   assign r_last[1][1]    = mx_i1.r_last;
   assign r_user[1][1]    = mx_i1.r_user;
   assign r_valid[1][1]   = mx_i1.r_valid;
   assign mx_i1.r_ready   = r_ready[1][1];

   assign mx_i2.aw_id     = aw_id[1][2];
   assign mx_i2.aw_addr   = aw_addr[1][2];
   assign mx_i2.aw_len    = aw_len[1][2];
   assign mx_i2.aw_size   = aw_size[1][2];
   assign mx_i2.aw_burst  = aw_burst[1][2];
   assign mx_i2.aw_lock   = aw_lock[1][2];
   assign mx_i2.aw_cache  = aw_cache[1][2];
   assign mx_i2.aw_prot   = aw_prot[1][2];
   assign mx_i2.aw_qos    = aw_qos[1][2];
   assign mx_i2.aw_region = aw_region[1][2];
   assign mx_i2.aw_user   = aw_user[1][2];
   assign mx_i2.aw_valid  = aw_valid[1][2];
   assign aw_ready[1][2]  = mx_i2.aw_ready;
   assign mx_i2.ar_id     = ar_id[1][2];
   assign mx_i2.ar_addr   = ar_addr[1][2];
   assign mx_i2.ar_len    = ar_len[1][2];
   assign mx_i2.ar_size   = ar_size[1][2];
   assign mx_i2.ar_burst  = ar_burst[1][2];
   assign mx_i2.ar_lock   = ar_lock[1][2];
   assign mx_i2.ar_cache  = ar_cache[1][2];
   assign mx_i2.ar_prot   = ar_prot[1][2];
   assign mx_i2.ar_qos    = ar_qos[1][2];
   assign mx_i2.ar_region = ar_region[1][2];
   assign mx_i2.ar_user   = ar_user[1][2];
   assign mx_i2.ar_valid  = ar_valid[1][2];
   assign ar_ready[1][2]  = mx_i2.ar_ready;
   assign mx_i2.w_data    = w_data[1][2];
   assign mx_i2.w_strb    = w_strb[1][2];
   assign mx_i2.w_last    = w_last[1][2];
   assign mx_i2.w_user    = w_user[1][2];
   assign mx_i2.w_valid   = w_valid[1][2];
   assign w_ready[1][2]   = mx_i2.w_ready;
   assign b_id[1][2]      = mx_i2.b_id;
   assign b_resp[1][2]    = mx_i2.b_resp;
   assign b_user[1][2]    = mx_i2.b_user;
   assign b_valid[1][2]   = mx_i2.b_valid;
   assign mx_i2.b_ready   = b_ready[1][2];
   assign r_id[1][2]      = mx_i2.r_id;
   assign r_data[1][2]    = mx_i2.r_data;
   assign r_resp[1][2]    = mx_i2.r_resp;
   assign r_last[1][2]    = mx_i2.r_last;
   assign r_user[1][2]    = mx_i2.r_user;
   assign r_valid[1][2]   = mx_i2.r_valid;
   assign mx_i2.r_ready   = r_ready[1][2];

   assign mx_i3.aw_id     = aw_id[1][3];
   assign mx_i3.aw_addr   = aw_addr[1][3];
   assign mx_i3.aw_len    = aw_len[1][3];
   assign mx_i3.aw_size   = aw_size[1][3];
   assign mx_i3.aw_burst  = aw_burst[1][3];
   assign mx_i3.aw_lock   = aw_lock[1][3];
   assign mx_i3.aw_cache  = aw_cache[1][3];
   assign mx_i3.aw_prot   = aw_prot[1][3];
   assign mx_i3.aw_qos    = aw_qos[1][3];
   assign mx_i3.aw_region = aw_region[1][3];
   assign mx_i3.aw_user   = aw_user[1][3];
   assign mx_i3.aw_valid  = aw_valid[1][3];
   assign aw_ready[1][3]  = mx_i3.aw_ready;
   assign mx_i3.ar_id     = ar_id[1][3];
   assign mx_i3.ar_addr   = ar_addr[1][3];
   assign mx_i3.ar_len    = ar_len[1][3];
   assign mx_i3.ar_size   = ar_size[1][3];
   assign mx_i3.ar_burst  = ar_burst[1][3];
   assign mx_i3.ar_lock   = ar_lock[1][3];
   assign mx_i3.ar_cache  = ar_cache[1][3];
   assign mx_i3.ar_prot   = ar_prot[1][3];
   assign mx_i3.ar_qos    = ar_qos[1][3];
   assign mx_i3.ar_region = ar_region[1][3];
   assign mx_i3.ar_user   = ar_user[1][3];
   assign mx_i3.ar_valid  = ar_valid[1][3];
   assign ar_ready[1][3]  = mx_i3.ar_ready;
   assign mx_i3.w_data    = w_data[1][3];
   assign mx_i3.w_strb    = w_strb[1][3];
   assign mx_i3.w_last    = w_last[1][3];
   assign mx_i3.w_user    = w_user[1][3];
   assign mx_i3.w_valid   = w_valid[1][3];
   assign w_ready[1][3]   = mx_i3.w_ready;
   assign b_id[1][3]      = mx_i3.b_id;
   assign b_resp[1][3]    = mx_i3.b_resp;
   assign b_user[1][3]    = mx_i3.b_user;
   assign b_valid[1][3]   = mx_i3.b_valid;
   assign mx_i3.b_ready   = b_ready[1][3];
   assign r_id[1][3]      = mx_i3.r_id;
   assign r_data[1][3]    = mx_i3.r_data;
   assign r_resp[1][3]    = mx_i3.r_resp;
   assign r_last[1][3]    = mx_i3.r_last;
   assign r_user[1][3]    = mx_i3.r_user;
   assign r_valid[1][3]   = mx_i3.r_valid;
   assign mx_i3.r_ready   = r_ready[1][3];

   assign mx_i4.aw_id     = aw_id[1][4];
   assign mx_i4.aw_addr   = aw_addr[1][4];
   assign mx_i4.aw_len    = aw_len[1][4];
   assign mx_i4.aw_size   = aw_size[1][4];
   assign mx_i4.aw_burst  = aw_burst[1][4];
   assign mx_i4.aw_lock   = aw_lock[1][4];
   assign mx_i4.aw_cache  = aw_cache[1][4];
   assign mx_i4.aw_prot   = aw_prot[1][4];
   assign mx_i4.aw_qos    = aw_qos[1][4];
   assign mx_i4.aw_region = aw_region[1][4];
   assign mx_i4.aw_user   = aw_user[1][4];
   assign mx_i4.aw_valid  = aw_valid[1][4];
   assign aw_ready[1][4]  = mx_i4.aw_ready;
   assign mx_i4.ar_id     = ar_id[1][4];
   assign mx_i4.ar_addr   = ar_addr[1][4];
   assign mx_i4.ar_len    = ar_len[1][4];
   assign mx_i4.ar_size   = ar_size[1][4];
   assign mx_i4.ar_burst  = ar_burst[1][4];
   assign mx_i4.ar_lock   = ar_lock[1][4];
   assign mx_i4.ar_cache  = ar_cache[1][4];
   assign mx_i4.ar_prot   = ar_prot[1][4];
   assign mx_i4.ar_qos    = ar_qos[1][4];
   assign mx_i4.ar_region = ar_region[1][4];
   assign mx_i4.ar_user   = ar_user[1][4];
   assign mx_i4.ar_valid  = ar_valid[1][4];
   assign ar_ready[1][4]  = mx_i4.ar_ready;
   assign mx_i4.w_data    = w_data[1][4];
   assign mx_i4.w_strb    = w_strb[1][4];
   assign mx_i4.w_last    = w_last[1][4];
   assign mx_i4.w_user    = w_user[1][4];
   assign mx_i4.w_valid   = w_valid[1][4];
   assign w_ready[1][4]   = mx_i4.w_ready;
   assign b_id[1][4]      = mx_i4.b_id;
   assign b_resp[1][4]    = mx_i4.b_resp;
   assign b_user[1][4]    = mx_i4.b_user;
   assign b_valid[1][4]   = mx_i4.b_valid;
   assign mx_i4.b_ready   = b_ready[1][4];
   assign r_id[1][4]      = mx_i4.r_id;
   assign r_data[1][4]    = mx_i4.r_data;
   assign r_resp[1][4]    = mx_i4.r_resp;
   assign r_last[1][4]    = mx_i4.r_last;
   assign r_user[1][4]    = mx_i4.r_user;
   assign r_valid[1][4]   = mx_i4.r_valid;
   assign mx_i4.r_ready   = r_ready[1][4];

   assign mx_i5.aw_id     = aw_id[1][5];
   assign mx_i5.aw_addr   = aw_addr[1][5];
   assign mx_i5.aw_len    = aw_len[1][5];
   assign mx_i5.aw_size   = aw_size[1][5];
   assign mx_i5.aw_burst  = aw_burst[1][5];
   assign mx_i5.aw_lock   = aw_lock[1][5];
   assign mx_i5.aw_cache  = aw_cache[1][5];
   assign mx_i5.aw_prot   = aw_prot[1][5];
   assign mx_i5.aw_qos    = aw_qos[1][5];
   assign mx_i5.aw_region = aw_region[1][5];
   assign mx_i5.aw_user   = aw_user[1][5];
   assign mx_i5.aw_valid  = aw_valid[1][5];
   assign aw_ready[1][5]  = mx_i5.aw_ready;
   assign mx_i5.ar_id     = ar_id[1][5];
   assign mx_i5.ar_addr   = ar_addr[1][5];
   assign mx_i5.ar_len    = ar_len[1][5];
   assign mx_i5.ar_size   = ar_size[1][5];
   assign mx_i5.ar_burst  = ar_burst[1][5];
   assign mx_i5.ar_lock   = ar_lock[1][5];
   assign mx_i5.ar_cache  = ar_cache[1][5];
   assign mx_i5.ar_prot   = ar_prot[1][5];
   assign mx_i5.ar_qos    = ar_qos[1][5];
   assign mx_i5.ar_region = ar_region[1][5];
   assign mx_i5.ar_user   = ar_user[1][5];
   assign mx_i5.ar_valid  = ar_valid[1][5];
   assign ar_ready[1][5]  = mx_i5.ar_ready;
   assign mx_i5.w_data    = w_data[1][5];
   assign mx_i5.w_strb    = w_strb[1][5];
   assign mx_i5.w_last    = w_last[1][5];
   assign mx_i5.w_user    = w_user[1][5];
   assign mx_i5.w_valid   = w_valid[1][5];
   assign w_ready[1][5]   = mx_i5.w_ready;
   assign b_id[1][5]      = mx_i5.b_id;
   assign b_resp[1][5]    = mx_i5.b_resp;
   assign b_user[1][5]    = mx_i5.b_user;
   assign b_valid[1][5]   = mx_i5.b_valid;
   assign mx_i5.b_ready   = b_ready[1][5];
   assign r_id[1][5]      = mx_i5.r_id;
   assign r_data[1][5]    = mx_i5.r_data;
   assign r_resp[1][5]    = mx_i5.r_resp;
   assign r_last[1][5]    = mx_i5.r_last;
   assign r_user[1][5]    = mx_i5.r_user;
   assign r_valid[1][5]   = mx_i5.r_valid;
   assign mx_i5.r_ready   = r_ready[1][5];

   assign mx_i6.aw_id     = aw_id[1][6];
   assign mx_i6.aw_addr   = aw_addr[1][6];
   assign mx_i6.aw_len    = aw_len[1][6];
   assign mx_i6.aw_size   = aw_size[1][6];
   assign mx_i6.aw_burst  = aw_burst[1][6];
   assign mx_i6.aw_lock   = aw_lock[1][6];
   assign mx_i6.aw_cache  = aw_cache[1][6];
   assign mx_i6.aw_prot   = aw_prot[1][6];
   assign mx_i6.aw_qos    = aw_qos[1][6];
   assign mx_i6.aw_region = aw_region[1][6];
   assign mx_i6.aw_user   = aw_user[1][6];
   assign mx_i6.aw_valid  = aw_valid[1][6];
   assign aw_ready[1][6]  = mx_i6.aw_ready;
   assign mx_i6.ar_id     = ar_id[1][6];
   assign mx_i6.ar_addr   = ar_addr[1][6];
   assign mx_i6.ar_len    = ar_len[1][6];
   assign mx_i6.ar_size   = ar_size[1][6];
   assign mx_i6.ar_burst  = ar_burst[1][6];
   assign mx_i6.ar_lock   = ar_lock[1][6];
   assign mx_i6.ar_cache  = ar_cache[1][6];
   assign mx_i6.ar_prot   = ar_prot[1][6];
   assign mx_i6.ar_qos    = ar_qos[1][6];
   assign mx_i6.ar_region = ar_region[1][6];
   assign mx_i6.ar_user   = ar_user[1][6];
   assign mx_i6.ar_valid  = ar_valid[1][6];
   assign ar_ready[1][6]  = mx_i6.ar_ready;
   assign mx_i6.w_data    = w_data[1][6];
   assign mx_i6.w_strb    = w_strb[1][6];
   assign mx_i6.w_last    = w_last[1][6];
   assign mx_i6.w_user    = w_user[1][6];
   assign mx_i6.w_valid   = w_valid[1][6];
   assign w_ready[1][6]   = mx_i6.w_ready;
   assign b_id[1][6]      = mx_i6.b_id;
   assign b_resp[1][6]    = mx_i6.b_resp;
   assign b_user[1][6]    = mx_i6.b_user;
   assign b_valid[1][6]   = mx_i6.b_valid;
   assign mx_i6.b_ready   = b_ready[1][6];
   assign r_id[1][6]      = mx_i6.r_id;
   assign r_data[1][6]    = mx_i6.r_data;
   assign r_resp[1][6]    = mx_i6.r_resp;
   assign r_last[1][6]    = mx_i6.r_last;
   assign r_user[1][6]    = mx_i6.r_user;
   assign r_valid[1][6]   = mx_i6.r_valid;
   assign mx_i6.r_ready   = r_ready[1][6];

   assign mx_i7.aw_id     = aw_id[1][7];
   assign mx_i7.aw_addr   = aw_addr[1][7];
   assign mx_i7.aw_len    = aw_len[1][7];
   assign mx_i7.aw_size   = aw_size[1][7];
   assign mx_i7.aw_burst  = aw_burst[1][7];
   assign mx_i7.aw_lock   = aw_lock[1][7];
   assign mx_i7.aw_cache  = aw_cache[1][7];
   assign mx_i7.aw_prot   = aw_prot[1][7];
   assign mx_i7.aw_qos    = aw_qos[1][7];
   assign mx_i7.aw_region = aw_region[1][7];
   assign mx_i7.aw_user   = aw_user[1][7];
   assign mx_i7.aw_valid  = aw_valid[1][7];
   assign aw_ready[1][7]  = mx_i7.aw_ready;
   assign mx_i7.ar_id     = ar_id[1][7];
   assign mx_i7.ar_addr   = ar_addr[1][7];
   assign mx_i7.ar_len    = ar_len[1][7];
   assign mx_i7.ar_size   = ar_size[1][7];
   assign mx_i7.ar_burst  = ar_burst[1][7];
   assign mx_i7.ar_lock   = ar_lock[1][7];
   assign mx_i7.ar_cache  = ar_cache[1][7];
   assign mx_i7.ar_prot   = ar_prot[1][7];
   assign mx_i7.ar_qos    = ar_qos[1][7];
   assign mx_i7.ar_region = ar_region[1][7];
   assign mx_i7.ar_user   = ar_user[1][7];
   assign mx_i7.ar_valid  = ar_valid[1][7];
   assign ar_ready[1][7]  = mx_i7.ar_ready;
   assign mx_i7.w_data    = w_data[1][7];
   assign mx_i7.w_strb    = w_strb[1][7];
   assign mx_i7.w_last    = w_last[1][7];
   assign mx_i7.w_user    = w_user[1][7];
   assign mx_i7.w_valid   = w_valid[1][7];
   assign w_ready[1][7]   = mx_i7.w_ready;
   assign b_id[1][7]      = mx_i7.b_id;
   assign b_resp[1][7]    = mx_i7.b_resp;
   assign b_user[1][7]    = mx_i7.b_user;
   assign b_valid[1][7]   = mx_i7.b_valid;
   assign mx_i7.b_ready   = b_ready[1][7];
   assign r_id[1][7]      = mx_i7.r_id;
   assign r_data[1][7]    = mx_i7.r_data;
   assign r_resp[1][7]    = mx_i7.r_resp;
   assign r_last[1][7]    = mx_i7.r_last;
   assign r_user[1][7]    = mx_i7.r_user;
   assign r_valid[1][7]   = mx_i7.r_valid;
   assign mx_i7.r_ready   = r_ready[1][7];

   // do the matrix connection
   generate
      for(i=0; i<8; i++)
        for(j=0; j<8; j++) begin
           assign aw_id[1][i][j]      = aw_id[0][j][i];
           assign aw_addr[1][i][j]    = aw_addr[0][j][i];
           assign aw_len[1][i][j]     = aw_len[0][j][i];
           assign aw_size[1][i][j]    = aw_size[0][j][i];
           assign aw_burst[1][i][j]   = aw_burst[0][j][i];
           assign aw_lock[1][i][j]    = aw_lock[0][j][i];
           assign aw_cache[1][i][j]   = aw_cache[0][j][i];
           assign aw_prot[1][i][j]    = aw_prot[0][j][i];
           assign aw_qos[1][i][j]     = aw_qos[0][j][i];
           assign aw_region[1][i][j]  = aw_region[0][j][i];
           assign aw_user[1][i][j]    = aw_user[0][j][i];
           assign aw_valid[1][i][j]   = aw_valid[0][j][i];
           assign aw_ready[0][j][i]   = aw_ready[1][i][j];
           assign ar_id[1][i][j]      = ar_id[0][j][i];
           assign ar_addr[1][i][j]    = ar_addr[0][j][i];
           assign ar_len[1][i][j]     = ar_len[0][j][i];
           assign ar_size[1][i][j]    = ar_size[0][j][i];
           assign ar_burst[1][i][j]   = ar_burst[0][j][i];
           assign ar_lock[1][i][j]    = ar_lock[0][j][i];
           assign ar_cache[1][i][j]   = ar_cache[0][j][i];
           assign ar_prot[1][i][j]    = ar_prot[0][j][i];
           assign ar_qos[1][i][j]     = ar_qos[0][j][i];
           assign ar_region[1][i][j]  = ar_region[0][j][i];
           assign ar_user[1][i][j]    = ar_user[0][j][i];
           assign ar_valid[1][i][j]   = ar_valid[0][j][i];
           assign ar_ready[0][j][i]   = ar_ready[1][i][j];
           assign w_data[1][i][j]     = w_data[0][j][i];
           assign w_strb[1][i][j]     = w_strb[0][j][i];
           assign w_last[1][i][j]     = w_last[0][j][i];
           assign w_user[1][i][j]     = w_user[0][j][i];
           assign w_valid[1][i][j]    = w_valid[0][j][i]; 
           assign w_ready[0][j][i]    = w_ready[1][i][j];
           assign b_id[0][j][i]       = b_id[1][i][j];
           assign b_resp[0][j][i]     = b_resp[1][i][j];
           assign b_user[0][j][i]     = b_user[1][i][j];
           assign b_valid[0][j][i]    = b_valid[1][i][j];
           assign b_ready[1][i][j]    = b_ready[0][j][i];
           assign r_id[0][j][i]       = r_id[1][i][j];
           assign r_data[0][j][i]     = r_data[1][i][j];
           assign r_resp[0][j][i]     = r_resp[1][i][j];
           assign r_last[0][j][i]     = r_last[1][i][j];
           assign r_user[0][j][i]     = r_user[1][i][j];
           assign r_valid[0][j][i]    = r_valid[1][i][j];
           assign r_ready[1][i][j]    = r_ready[0][j][i];
        end // for (j=0; j<8; j++)
   endgenerate

   // multiplexers
   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux0 (.*, .s(mx_i0), .m(ob_i0));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux1 (.*, .s(mx_i1), .m(ob_i1));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux2 (.*, .s(mx_i2), .m(ob_i2));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux3 (.*, .s(mx_i3), .m(ob_i3));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux4 (.*, .s(mx_i4), .m(ob_i4));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux5 (.*, .s(mx_i5), .m(ob_i5));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux6 (.*, .s(mx_i6), .m(ob_i6));

   nasti_mux #(.W_MAX(W_MAX), .R_MAX(R_MAX),
               .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
               .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
   mux7 (.*, .s(mx_i7), .m(ob_i7));

   // combine channel and possibly insert output buffers
   generate
      if(OB_DEPTH == 0) begin   // No input buffer
         nasti_channel_combiner #(N_OUTPUT)
         output_combiner (
                          .s0 ( ob_i0  ), .s1 ( ob_i1  ), .s2 ( ob_i2  ), .s3 ( ob_i3  ),
                          .s4 ( ob_i4  ), .s5 ( ob_i5  ), .s6 ( ob_i6  ), .s7 ( ob_i7  ),
                          .m  ( m      ));
      end else begin            // Has input buffer
         nasti_channel_combiner #(N_OUTPUT)
         output_combiner (
                          .s0 ( ob_o0  ), .s1 ( ob_o1  ), .s2 ( ob_o2  ), .s3 ( ob_o3  ),
                          .s4 ( ob_o4  ), .s5 ( ob_o5  ), .s6 ( ob_o6  ), .s7 ( ob_o7  ),
                          .m  ( m      ));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf0 (.s(ob_i0), .m(ob_o0));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf1 (.s(ob_i1), .m(ob_o1));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf2 (.s(ob_i2), .m(ob_o2));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf3 (.s(ob_i3), .m(ob_o3));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf4 (.s(ob_i4), .m(ob_o4));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf5 (.s(ob_i5), .m(ob_o5));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf6 (.s(ob_i6), .m(ob_o6));

         nasti_buf #(.DEPTH(OB_DEPTH), .ID_WIDTH(ID_WIDTH), .ADDR_WIDTH(ADDR_WIDTH),
                     .DATA_WIDTH(DATA_WIDTH), .USER_WIDTH(USER_WIDTH))
         obuf7 (.s(ob_i7), .m(ob_o7));
      end // else: !if(OB_DEPTH == 0)
   endgenerate

endmodule // nasti_crossbar
