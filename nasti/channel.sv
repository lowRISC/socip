// See LICENSE for license details.

// Define the SV interfaces for NASTI channels

interface nasti_channel
  #(
    N_PORT = 1,                 // number of nasti ports
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    );

   init assert(USER_WIDTH > 0) else $fatal(1, "[nasti interface] User field must have at least 1 bit!");

   // write/read address
   logic [N_PORT-1:0][ID_WIDTH-1:0]     aw_id,     ar_id;
   logic [N_PORT-1:0][ADDR_WIDTH-1:0]   aw_addr,   ar_addr;
   logic [N_PORT-1:0][7:0]              aw_len,    ar_len;
   logic [N_PORT-1:0][2:0]              aw_size,   ar_size;
   logic [N_PORT-1:0][1:0]              aw_burst,  ar_burst;
   logic [N_PORT-1:0]                   aw_lock,   ar_lock;
   logic [N_PORT-1:0][3:0]              aw_cache,  ar_cache;
   logic [N_PORT-1:0][2:0]              aw_prot,   ar_prot;
   logic [N_PORT-1:0][3:0]              aw_qos,    ar_qos;
   logic [N_PORT-1:0][3:0]              aw_region, ar_region;
   logic [N_PORT-1:0][USER_WIDTH-1:0]   aw_user,   ar_user;
   logic [N_PORT-1:0]                   aw_valid,  ar_valid;
   logic [N_PORT-1:0]                   aw_ready,  ar_ready;

   // write/read data
   logic [N_PORT-1:0][DATA_WIDTH-1:0]   w_data,    r_data;
   logic [N_PORT-1:0][DATA_WIDTH/8-1:0] w_strb;
   logic [N_PORT-1:0]                   w_last,    r_last;
   logic [N_PORT-1:0][USER_WIDTH-1:0]   w_user;
   logic [N_PORT-1:0]                   w_valid;
   logic [N_PORT-1:0]                   w_ready;

   // write/read response
   logic [N_PORT-1:0][ID_WIDTH-1:0]     b_id,      r_id;
   logic [N_PORT-1:0][1:0]              b_resp,    r_resp;
   logic [N_PORT-1:0][USER_WIDTH-1:0]   b_user,    r_user;
   logic [N_PORT-1:0]                   b_valid,   r_valid;
   logic [N_PORT-1:0]                   b_ready,   r_ready;


   modport master (
                   // write/read address
                   output aw_id,     ar_id,
                   output aw_addr,   ar_addr,
                   output aw_len,    ar_len,
                   output aw_size,   ar_size,
                   output aw_burst,  ar_burst,
                   output aw_lock,   ar_lock,
                   output aw_cache,  ar_cache,
                   output aw_prot,   ar_prot,
                   output aw_qos,    ar_qos,
                   output aw_region, ar_region,
                   output aw_user,   ar_user,
                   output aw_valid,  ar_valid,
                   input  aw_ready,  ar_ready,
                   // write data
                   output w_data,
                   output w_strb,
                   output w_last,
                   output w_user,
                   output w_valid,
                   input  w_ready,
                   // read data
                   input  r_data,
                   input  r_last,
                   // write/read response
                   input  b_id,    r_id,
                   input  b_resp,  r_resp,
                   input  b_user,  r_user,
                   input  b_valid, r_valid,
                   output b_ready, r_ready
                   );

   modport slave (
                  // write/read address
                  input  aw_id,     ar_id,
                  input  aw_addr,   ar_addr,
                  input  aw_len,    ar_len,
                  input  aw_size,   ar_size,
                  input  aw_burst,  ar_burst,
                  input  aw_lock,   ar_lock,
                  input  aw_cache,  ar_cache,
                  input  aw_prot,   ar_prot,
                  input  aw_qos,    ar_qos,
                  input  aw_region, ar_region,
                  input  aw_user,   ar_user,
                  input  aw_valid,  ar_valid,
                  output aw_ready,  ar_ready,
                   // write data
                  input  w_data,
                  input  w_strb,
                  input  w_last,
                  input  w_user,
                  input  w_valid,
                  output w_ready,
                   // read data
                  output r_data,
                  output r_last,
                   // write/read response
                  output b_id,    r_id,
                  output b_resp,  r_resp,
                  output b_user,  r_user,
                  output b_valid, r_valid,
                  input  b_ready, r_ready
                   );

endinterface // nasti_channel

module nasti_channel_combiner
  #(
    N_PORT = 1                 // number of nasti ports to be combined, maximal 8
    )
   (
    nasti_channel.slave s0, s1, s2, s3, s4, s5, s6, s7,
    nasti_channel.master m
    );

   // much easier if Vivado support array of interfaces
   generate
      if(N_PORT > 0) begin
         assign m.aw_id[0]     = s0.aw_id;
         assign m.aw_addr[0]   = s0.aw_addr;
         assign m.aw_len[0]    = s0.aw_len;
         assign m.aw_size[0]   = s0.aw_size;
         assign m.aw_burst[0]  = s0.aw_burst;
         assign m.aw_lock[0]   = s0.aw_lock;
         assign m.aw_cache[0]  = s0.aw_cache;
         assign m.aw_prot[0]   = s0.aw_prot;
         assign m.aw_qos[0]    = s0.aw_qos;
         assign m.aw_region[0] = s0.aw_region;
         assign m.aw_user[0]   = s0.aw_user;
         assign m.aw_valid[0]  = s0.aw_valid;
         assign m.ar_id[0]     = s0.ar_id;
         assign m.ar_addr[0]   = s0.ar_addr;
         assign m.ar_len[0]    = s0.ar_len;
         assign m.ar_size[0]   = s0.ar_size;
         assign m.ar_burst[0]  = s0.ar_burst;
         assign m.ar_lock[0]   = s0.ar_lock;
         assign m.ar_cache[0]  = s0.ar_cache;
         assign m.ar_prot[0]   = s0.ar_prot;
         assign m.ar_qos[0]    = s0.ar_qos;
         assign m.ar_region[0] = s0.ar_region;
         assign m.ar_user[0]   = s0.ar_user;
         assign m.ar_valid[0]  = s0.ar_valid;
         assign m.w_data[0]    = s0.w_data;
         assign m.w_strb[0]    = s0.w_strb;
         assign m.w_last[0]    = s0.w_last;
         assign m.w_user[0]    = s0.w_user;
         assign m.w_valid[0]   = s0.w_valid;
         assign m.b_ready[0]   = s0.b_ready;
         assign m.r_ready[0]   = s0.r_ready;
         assign s0.aw_ready    = m.aw_ready[0];
         assign s0.ar_ready    = m.ar_ready[0];
         assign s0.w_ready     = m.w_ready[0];
         assign s0.b_id        = m.b_id[0];
         assign s0.b_resp      = m.b_resp[0];
         assign s0.b_user      = m.b_user[0];
         assign s0.b_valid     = m.b_valid[0];
         assign s0.r_data      = m.r_data[0];
         assign s0.r_last      = m.r_last[0];
         assign s0.r_id        = m.r_id[0];
         assign s0.r_resp      = m.r_resp[0];
         assign s0.r_user      = m.r_user[0];
         assign s0.r_valid     = m.r_valid[0];
      end

      if(N_PORT > 1) begin
         assign m.aw_id[1]     = s1.aw_id;
         assign m.aw_addr[1]   = s1.aw_addr;
         assign m.aw_len[1]    = s1.aw_len;
         assign m.aw_size[1]   = s1.aw_size;
         assign m.aw_burst[1]  = s1.aw_burst;
         assign m.aw_lock[1]   = s1.aw_lock;
         assign m.aw_cache[1]  = s1.aw_cache;
         assign m.aw_prot[1]   = s1.aw_prot;
         assign m.aw_qos[1]    = s1.aw_qos;
         assign m.aw_region[1] = s1.aw_region;
         assign m.aw_user[1]   = s1.aw_user;
         assign m.aw_valid[1]  = s1.aw_valid;
         assign m.ar_id[1]     = s1.ar_id;
         assign m.ar_addr[1]   = s1.ar_addr;
         assign m.ar_len[1]    = s1.ar_len;
         assign m.ar_size[1]   = s1.ar_size;
         assign m.ar_burst[1]  = s1.ar_burst;
         assign m.ar_lock[1]   = s1.ar_lock;
         assign m.ar_cache[1]  = s1.ar_cache;
         assign m.ar_prot[1]   = s1.ar_prot;
         assign m.ar_qos[1]    = s1.ar_qos;
         assign m.ar_region[1] = s1.ar_region;
         assign m.ar_user[1]   = s1.ar_user;
         assign m.ar_valid[1]  = s1.ar_valid;
         assign m.w_data[1]    = s1.w_data;
         assign m.w_strb[1]    = s1.w_strb;
         assign m.w_last[1]    = s1.w_last;
         assign m.w_user[1]    = s1.w_user;
         assign m.w_valid[1]   = s1.w_valid;
         assign m.b_ready[1]   = s1.b_ready;
         assign m.r_ready[1]   = s1.r_ready;
         assign s1.aw_ready    = m.aw_ready[1];
         assign s1.ar_ready    = m.ar_ready[1];
         assign s1.w_ready     = m.w_ready[1];
         assign s1.b_id        = m.b_id[1];
         assign s1.b_resp      = m.b_resp[1];
         assign s1.b_user      = m.b_user[1];
         assign s1.b_valid     = m.b_valid[1];
         assign s1.r_data      = m.r_data[1];
         assign s1.r_last      = m.r_last[1];
         assign s1.r_id        = m.r_id[1];
         assign s1.r_resp      = m.r_resp[1];
         assign s1.r_user      = m.r_user[1];
         assign s1.r_valid     = m.r_valid[1];
      end

      if(N_PORT > 2) begin
         assign m.aw_id[2]     = s2.aw_id;
         assign m.aw_addr[2]   = s2.aw_addr;
         assign m.aw_len[2]    = s2.aw_len;
         assign m.aw_size[2]   = s2.aw_size;
         assign m.aw_burst[2]  = s2.aw_burst;
         assign m.aw_lock[2]   = s2.aw_lock;
         assign m.aw_cache[2]  = s2.aw_cache;
         assign m.aw_prot[2]   = s2.aw_prot;
         assign m.aw_qos[2]    = s2.aw_qos;
         assign m.aw_region[2] = s2.aw_region;
         assign m.aw_user[2]   = s2.aw_user;
         assign m.aw_valid[2]  = s2.aw_valid;
         assign m.ar_id[2]     = s2.ar_id;
         assign m.ar_addr[2]   = s2.ar_addr;
         assign m.ar_len[2]    = s2.ar_len;
         assign m.ar_size[2]   = s2.ar_size;
         assign m.ar_burst[2]  = s2.ar_burst;
         assign m.ar_lock[2]   = s2.ar_lock;
         assign m.ar_cache[2]  = s2.ar_cache;
         assign m.ar_prot[2]   = s2.ar_prot;
         assign m.ar_qos[2]    = s2.ar_qos;
         assign m.ar_region[2] = s2.ar_region;
         assign m.ar_user[2]   = s2.ar_user;
         assign m.ar_valid[2]  = s2.ar_valid;
         assign m.w_data[2]    = s2.w_data;
         assign m.w_strb[2]    = s2.w_strb;
         assign m.w_last[2]    = s2.w_last;
         assign m.w_user[2]    = s2.w_user;
         assign m.w_valid[2]   = s2.w_valid;
         assign m.b_ready[2]   = s2.b_ready;
         assign m.r_ready[2]   = s2.r_ready;
         assign s2.aw_ready    = m.aw_ready[2];
         assign s2.ar_ready    = m.ar_ready[2];
         assign s2.w_ready     = m.w_ready[2];
         assign s2.b_id        = m.b_id[2];
         assign s2.b_resp      = m.b_resp[2];
         assign s2.b_user      = m.b_user[2];
         assign s2.b_valid     = m.b_valid[2];
         assign s2.r_data      = m.r_data[2];
         assign s2.r_last      = m.r_last[2];
         assign s2.r_id        = m.r_id[2];
         assign s2.r_resp      = m.r_resp[2];
         assign s2.r_user      = m.r_user[2];
         assign s2.r_valid     = m.r_valid[2];
      end

      if(N_PORT > 3) begin
         assign m.aw_id[3]     = s3.aw_id;
         assign m.aw_addr[3]   = s3.aw_addr;
         assign m.aw_len[3]    = s3.aw_len;
         assign m.aw_size[3]   = s3.aw_size;
         assign m.aw_burst[3]  = s3.aw_burst;
         assign m.aw_lock[3]   = s3.aw_lock;
         assign m.aw_cache[3]  = s3.aw_cache;
         assign m.aw_prot[3]   = s3.aw_prot;
         assign m.aw_qos[3]    = s3.aw_qos;
         assign m.aw_region[3] = s3.aw_region;
         assign m.aw_user[3]   = s3.aw_user;
         assign m.aw_valid[3]  = s3.aw_valid;
         assign m.ar_id[3]     = s3.ar_id;
         assign m.ar_addr[3]   = s3.ar_addr;
         assign m.ar_len[3]    = s3.ar_len;
         assign m.ar_size[3]   = s3.ar_size;
         assign m.ar_burst[3]  = s3.ar_burst;
         assign m.ar_lock[3]   = s3.ar_lock;
         assign m.ar_cache[3]  = s3.ar_cache;
         assign m.ar_prot[3]   = s3.ar_prot;
         assign m.ar_qos[3]    = s3.ar_qos;
         assign m.ar_region[3] = s3.ar_region;
         assign m.ar_user[3]   = s3.ar_user;
         assign m.ar_valid[3]  = s3.ar_valid;
         assign m.w_data[3]    = s3.w_data;
         assign m.w_strb[3]    = s3.w_strb;
         assign m.w_last[3]    = s3.w_last;
         assign m.w_user[3]    = s3.w_user;
         assign m.w_valid[3]   = s3.w_valid;
         assign m.b_ready[3]   = s3.b_ready;
         assign m.r_ready[3]   = s3.r_ready;
         assign s3.aw_ready    = m.aw_ready[3];
         assign s3.ar_ready    = m.ar_ready[3];
         assign s3.w_ready     = m.w_ready[3];
         assign s3.b_id        = m.b_id[3];
         assign s3.b_resp      = m.b_resp[3];
         assign s3.b_user      = m.b_user[3];
         assign s3.b_valid     = m.b_valid[3];
         assign s3.r_data      = m.r_data[3];
         assign s3.r_last      = m.r_last[3];
         assign s3.r_id        = m.r_id[3];
         assign s3.r_resp      = m.r_resp[3];
         assign s3.r_user      = m.r_user[3];
         assign s3.r_valid     = m.r_valid[3];
      end

      if(N_PORT > 4) begin
         assign m.aw_id[4]     = s4.aw_id;
         assign m.aw_addr[4]   = s4.aw_addr;
         assign m.aw_len[4]    = s4.aw_len;
         assign m.aw_size[4]   = s4.aw_size;
         assign m.aw_burst[4]  = s4.aw_burst;
         assign m.aw_lock[4]   = s4.aw_lock;
         assign m.aw_cache[4]  = s4.aw_cache;
         assign m.aw_prot[4]   = s4.aw_prot;
         assign m.aw_qos[4]    = s4.aw_qos;
         assign m.aw_region[4] = s4.aw_region;
         assign m.aw_user[4]   = s4.aw_user;
         assign m.aw_valid[4]  = s4.aw_valid;
         assign m.ar_id[4]     = s4.ar_id;
         assign m.ar_addr[4]   = s4.ar_addr;
         assign m.ar_len[4]    = s4.ar_len;
         assign m.ar_size[4]   = s4.ar_size;
         assign m.ar_burst[4]  = s4.ar_burst;
         assign m.ar_lock[4]   = s4.ar_lock;
         assign m.ar_cache[4]  = s4.ar_cache;
         assign m.ar_prot[4]   = s4.ar_prot;
         assign m.ar_qos[4]    = s4.ar_qos;
         assign m.ar_region[4] = s4.ar_region;
         assign m.ar_user[4]   = s4.ar_user;
         assign m.ar_valid[4]  = s4.ar_valid;
         assign m.w_data[4]    = s4.w_data;
         assign m.w_strb[4]    = s4.w_strb;
         assign m.w_last[4]    = s4.w_last;
         assign m.w_user[4]    = s4.w_user;
         assign m.w_valid[4]   = s4.w_valid;
         assign m.b_ready[4]   = s4.b_ready;
         assign m.r_ready[4]   = s4.r_ready;
         assign s4.aw_ready    = m.aw_ready[4];
         assign s4.ar_ready    = m.ar_ready[4];
         assign s4.w_ready     = m.w_ready[4];
         assign s4.b_id        = m.b_id[4];
         assign s4.b_resp      = m.b_resp[4];
         assign s4.b_user      = m.b_user[4];
         assign s4.b_valid     = m.b_valid[4];
         assign s4.r_data      = m.r_data[4];
         assign s4.r_last      = m.r_last[4];
         assign s4.r_id        = m.r_id[4];
         assign s4.r_resp      = m.r_resp[4];
         assign s4.r_user      = m.r_user[4];
         assign s4.r_valid     = m.r_valid[4];
      end

      if(N_PORT > 5) begin
         assign m.aw_id[5]     = s5.aw_id;
         assign m.aw_addr[5]   = s5.aw_addr;
         assign m.aw_len[5]    = s5.aw_len;
         assign m.aw_size[5]   = s5.aw_size;
         assign m.aw_burst[5]  = s5.aw_burst;
         assign m.aw_lock[5]   = s5.aw_lock;
         assign m.aw_cache[5]  = s5.aw_cache;
         assign m.aw_prot[5]   = s5.aw_prot;
         assign m.aw_qos[5]    = s5.aw_qos;
         assign m.aw_region[5] = s5.aw_region;
         assign m.aw_user[5]   = s5.aw_user;
         assign m.aw_valid[5]  = s5.aw_valid;
         assign m.ar_id[5]     = s5.ar_id;
         assign m.ar_addr[5]   = s5.ar_addr;
         assign m.ar_len[5]    = s5.ar_len;
         assign m.ar_size[5]   = s5.ar_size;
         assign m.ar_burst[5]  = s5.ar_burst;
         assign m.ar_lock[5]   = s5.ar_lock;
         assign m.ar_cache[5]  = s5.ar_cache;
         assign m.ar_prot[5]   = s5.ar_prot;
         assign m.ar_qos[5]    = s5.ar_qos;
         assign m.ar_region[5] = s5.ar_region;
         assign m.ar_user[5]   = s5.ar_user;
         assign m.ar_valid[5]  = s5.ar_valid;
         assign m.w_data[5]    = s5.w_data;
         assign m.w_strb[5]    = s5.w_strb;
         assign m.w_last[5]    = s5.w_last;
         assign m.w_user[5]    = s5.w_user;
         assign m.w_valid[5]   = s5.w_valid;
         assign m.b_ready[5]   = s5.b_ready;
         assign m.r_ready[5]   = s5.r_ready;
         assign s5.aw_ready    = m.aw_ready[5];
         assign s5.ar_ready    = m.ar_ready[5];
         assign s5.w_ready     = m.w_ready[5];
         assign s5.b_id        = m.b_id[5];
         assign s5.b_resp      = m.b_resp[5];
         assign s5.b_user      = m.b_user[5];
         assign s5.b_valid     = m.b_valid[5];
         assign s5.r_data      = m.r_data[5];
         assign s5.r_last      = m.r_last[5];
         assign s5.r_id        = m.r_id[5];
         assign s5.r_resp      = m.r_resp[5];
         assign s5.r_user      = m.r_user[5];
         assign s5.r_valid     = m.r_valid[5];
      end

      if(N_PORT > 6) begin
         assign m.aw_id[6]     = s6.aw_id;
         assign m.aw_addr[6]   = s6.aw_addr;
         assign m.aw_len[6]    = s6.aw_len;
         assign m.aw_size[6]   = s6.aw_size;
         assign m.aw_burst[6]  = s6.aw_burst;
         assign m.aw_lock[6]   = s6.aw_lock;
         assign m.aw_cache[6]  = s6.aw_cache;
         assign m.aw_prot[6]   = s6.aw_prot;
         assign m.aw_qos[6]    = s6.aw_qos;
         assign m.aw_region[6] = s6.aw_region;
         assign m.aw_user[6]   = s6.aw_user;
         assign m.aw_valid[6]  = s6.aw_valid;
         assign m.ar_id[6]     = s6.ar_id;
         assign m.ar_addr[6]   = s6.ar_addr;
         assign m.ar_len[6]    = s6.ar_len;
         assign m.ar_size[6]   = s6.ar_size;
         assign m.ar_burst[6]  = s6.ar_burst;
         assign m.ar_lock[6]   = s6.ar_lock;
         assign m.ar_cache[6]  = s6.ar_cache;
         assign m.ar_prot[6]   = s6.ar_prot;
         assign m.ar_qos[6]    = s6.ar_qos;
         assign m.ar_region[6] = s6.ar_region;
         assign m.ar_user[6]   = s6.ar_user;
         assign m.ar_valid[6]  = s6.ar_valid;
         assign m.w_data[6]    = s6.w_data;
         assign m.w_strb[6]    = s6.w_strb;
         assign m.w_last[6]    = s6.w_last;
         assign m.w_user[6]    = s6.w_user;
         assign m.w_valid[6]   = s6.w_valid;
         assign m.b_ready[6]   = s6.b_ready;
         assign m.r_ready[6]   = s6.r_ready;
         assign s6.aw_ready    = m.aw_ready[6];
         assign s6.ar_ready    = m.ar_ready[6];
         assign s6.w_ready     = m.w_ready[6];
         assign s6.b_id        = m.b_id[6];
         assign s6.b_resp      = m.b_resp[6];
         assign s6.b_user      = m.b_user[6];
         assign s6.b_valid     = m.b_valid[6];
         assign s6.r_data      = m.r_data[6];
         assign s6.r_last      = m.r_last[6];
         assign s6.r_id        = m.r_id[6];
         assign s6.r_resp      = m.r_resp[6];
         assign s6.r_user      = m.r_user[6];
         assign s6.r_valid     = m.r_valid[6];
      end

      if(N_PORT > 7) begin
         assign m.aw_id[7]     = s7.aw_id;
         assign m.aw_addr[7]   = s7.aw_addr;
         assign m.aw_len[7]    = s7.aw_len;
         assign m.aw_size[7]   = s7.aw_size;
         assign m.aw_burst[7]  = s7.aw_burst;
         assign m.aw_lock[7]   = s7.aw_lock;
         assign m.aw_cache[7]  = s7.aw_cache;
         assign m.aw_prot[7]   = s7.aw_prot;
         assign m.aw_qos[7]    = s7.aw_qos;
         assign m.aw_region[7] = s7.aw_region;
         assign m.aw_user[7]   = s7.aw_user;
         assign m.aw_valid[7]  = s7.aw_valid;
         assign m.ar_id[7]     = s7.ar_id;
         assign m.ar_addr[7]   = s7.ar_addr;
         assign m.ar_len[7]    = s7.ar_len;
         assign m.ar_size[7]   = s7.ar_size;
         assign m.ar_burst[7]  = s7.ar_burst;
         assign m.ar_lock[7]   = s7.ar_lock;
         assign m.ar_cache[7]  = s7.ar_cache;
         assign m.ar_prot[7]   = s7.ar_prot;
         assign m.ar_qos[7]    = s7.ar_qos;
         assign m.ar_region[7] = s7.ar_region;
         assign m.ar_user[7]   = s7.ar_user;
         assign m.ar_valid[7]  = s7.ar_valid;
         assign m.w_data[7]    = s7.w_data;
         assign m.w_strb[7]    = s7.w_strb;
         assign m.w_last[7]    = s7.w_last;
         assign m.w_user[7]    = s7.w_user;
         assign m.w_valid[7]   = s7.w_valid;
         assign m.b_ready[7]   = s7.b_ready;
         assign m.r_ready[7]   = s7.r_ready;
         assign s7.aw_ready    = m.aw_ready[7];
         assign s7.ar_ready    = m.ar_ready[7];
         assign s7.w_ready     = m.w_ready[7];
         assign s7.b_id        = m.b_id[7];
         assign s7.b_resp      = m.b_resp[7];
         assign s7.b_user      = m.b_user[7];
         assign s7.b_valid     = m.b_valid[7];
         assign s7.r_data      = m.r_data[7];
         assign s7.r_last      = m.r_last[7];
         assign s7.r_id        = m.r_id[7];
         assign s7.r_resp      = m.r_resp[7];
         assign s7.r_user      = m.r_user[7];
         assign s7.r_valid     = m.r_valid[7];
      end
   endgenerate

endmodule

module nasti_channel_slicer
  #(
    N_PORT = 1                 // number of nasti ports to be sliced, maximal 8
    )
   (
    nasti_channel.slave s,
    nasti_channel.master m0, m1, m2, m3, m4, m5, m6, m7
    );

   // much easier if Vivado support array of interfaces
   generate
      if(N_PORT > 0) begin
         assign m0.aw_id      = s.aw_id[0];
         assign m0.aw_addr    = s.aw_addr[0];
         assign m0.aw_len     = s.aw_len[0];
         assign m0.aw_size    = s.aw_size[0];
         assign m0.aw_burst   = s.aw_burst[0];
         assign m0.aw_lock    = s.aw_lock[0];
         assign m0.aw_cache   = s.aw_cache[0];
         assign m0.aw_prot    = s.aw_prot[0];
         assign m0.aw_qos     = s.aw_qos[0];
         assign m0.aw_region  = s.aw_region[0];
         assign m0.aw_user    = s.aw_user[0];
         assign m0.aw_valid   = s.aw_valid[0];
         assign m0.ar_id      = s.ar_id[0];
         assign m0.ar_addr    = s.ar_addr[0];
         assign m0.ar_len     = s.ar_len[0];
         assign m0.ar_size    = s.ar_size[0];
         assign m0.ar_burst   = s.ar_burst[0];
         assign m0.ar_lock    = s.ar_lock[0];
         assign m0.ar_cache   = s.ar_cache[0];
         assign m0.ar_prot    = s.ar_prot[0];
         assign m0.ar_qos     = s.ar_qos[0];
         assign m0.ar_region  = s.ar_region[0];
         assign m0.ar_user    = s.ar_user[0];
         assign m0.ar_valid   = s.ar_valid[0];
         assign m0.w_data     = s.w_data[0];
         assign m0.w_strb     = s.w_strb[0];
         assign m0.w_last     = s.w_last[0];
         assign m0.w_user     = s.w_user[0];
         assign m0.w_valid    = s.w_valid[0];
         assign m0.b_ready    = s.b_ready[0];
         assign m0.r_ready    = s.r_ready[0];
         assign s.aw_ready[0] = m0.aw_ready;
         assign s.ar_ready[0] = m0.ar_ready;
         assign s.w_ready[0]  = m0.w_ready;
         assign s.b_id[0]     = m0.b_id;
         assign s.b_resp[0]   = m0.b_resp;
         assign s.b_user[0]   = m0.b_user;
         assign s.b_valid[0]  = m0.b_valid;
         assign s.r_data[0]   = m0.r_data;
         assign s.r_last[0]   = m0.r_last;
         assign s.r_id[0]     = m0.r_id;
         assign s.r_resp[0]   = m0.r_resp;
         assign s.r_user[0]   = m0.r_user;
         assign s.r_valid[0]  = m0.r_valid;
      end

      if(N_PORT > 1) begin
         assign m1.aw_id      = s.aw_id[1];
         assign m1.aw_addr    = s.aw_addr[1];
         assign m1.aw_len     = s.aw_len[1];
         assign m1.aw_size    = s.aw_size[1];
         assign m1.aw_burst   = s.aw_burst[1];
         assign m1.aw_lock    = s.aw_lock[1];
         assign m1.aw_cache   = s.aw_cache[1];
         assign m1.aw_prot    = s.aw_prot[1];
         assign m1.aw_qos     = s.aw_qos[1];
         assign m1.aw_region  = s.aw_region[1];
         assign m1.aw_user    = s.aw_user[1];
         assign m1.aw_valid   = s.aw_valid[1];
         assign m1.ar_id      = s.ar_id[1];
         assign m1.ar_addr    = s.ar_addr[1];
         assign m1.ar_len     = s.ar_len[1];
         assign m1.ar_size    = s.ar_size[1];
         assign m1.ar_burst   = s.ar_burst[1];
         assign m1.ar_lock    = s.ar_lock[1];
         assign m1.ar_cache   = s.ar_cache[1];
         assign m1.ar_prot    = s.ar_prot[1];
         assign m1.ar_qos     = s.ar_qos[1];
         assign m1.ar_region  = s.ar_region[1];
         assign m1.ar_user    = s.ar_user[1];
         assign m1.ar_valid   = s.ar_valid[1];
         assign m1.w_data     = s.w_data[1];
         assign m1.w_strb     = s.w_strb[1];
         assign m1.w_last     = s.w_last[1];
         assign m1.w_user     = s.w_user[1];
         assign m1.w_valid    = s.w_valid[1];
         assign m1.b_ready    = s.b_ready[1];
         assign m1.r_ready    = s.r_ready[1];
         assign s.aw_ready[1] = m1.aw_ready;
         assign s.ar_ready[1] = m1.ar_ready;
         assign s.w_ready[1]  = m1.w_ready;
         assign s.b_id[1]     = m1.b_id;
         assign s.b_resp[1]   = m1.b_resp;
         assign s.b_user[1]   = m1.b_user;
         assign s.b_valid[1]  = m1.b_valid;
         assign s.r_data[1]   = m1.r_data;
         assign s.r_last[1]   = m1.r_last;
         assign s.r_id[1]     = m1.r_id;
         assign s.r_resp[1]   = m1.r_resp;
         assign s.r_user[1]   = m1.r_user;
         assign s.r_valid[1]  = m1.r_valid;
      end

      if(N_PORT > 2) begin
         assign m2.aw_id      = s.aw_id[2];
         assign m2.aw_addr    = s.aw_addr[2];
         assign m2.aw_len     = s.aw_len[2];
         assign m2.aw_size    = s.aw_size[2];
         assign m2.aw_burst   = s.aw_burst[2];
         assign m2.aw_lock    = s.aw_lock[2];
         assign m2.aw_cache   = s.aw_cache[2];
         assign m2.aw_prot    = s.aw_prot[2];
         assign m2.aw_qos     = s.aw_qos[2];
         assign m2.aw_region  = s.aw_region[2];
         assign m2.aw_user    = s.aw_user[2];
         assign m2.aw_valid   = s.aw_valid[2];
         assign m2.ar_id      = s.ar_id[2];
         assign m2.ar_addr    = s.ar_addr[2];
         assign m2.ar_len     = s.ar_len[2];
         assign m2.ar_size    = s.ar_size[2];
         assign m2.ar_burst   = s.ar_burst[2];
         assign m2.ar_lock    = s.ar_lock[2];
         assign m2.ar_cache   = s.ar_cache[2];
         assign m2.ar_prot    = s.ar_prot[2];
         assign m2.ar_qos     = s.ar_qos[2];
         assign m2.ar_region  = s.ar_region[2];
         assign m2.ar_user    = s.ar_user[2];
         assign m2.ar_valid   = s.ar_valid[2];
         assign m2.w_data     = s.w_data[2];
         assign m2.w_strb     = s.w_strb[2];
         assign m2.w_last     = s.w_last[2];
         assign m2.w_user     = s.w_user[2];
         assign m2.w_valid    = s.w_valid[2];
         assign m2.b_ready    = s.b_ready[2];
         assign m2.r_ready    = s.r_ready[2];
         assign s.aw_ready[2] = m2.aw_ready;
         assign s.ar_ready[2] = m2.ar_ready;
         assign s.w_ready[2]  = m2.w_ready;
         assign s.b_id[2]     = m2.b_id;
         assign s.b_resp[2]   = m2.b_resp;
         assign s.b_user[2]   = m2.b_user;
         assign s.b_valid[2]  = m2.b_valid;
         assign s.r_data[2]   = m2.r_data;
         assign s.r_last[2]   = m2.r_last;
         assign s.r_id[2]     = m2.r_id;
         assign s.r_resp[2]   = m2.r_resp;
         assign s.r_user[2]   = m2.r_user;
         assign s.r_valid[2]  = m2.r_valid;
      end

      if(N_PORT > 3) begin
         assign m3.aw_id      = s.aw_id[3];
         assign m3.aw_addr    = s.aw_addr[3];
         assign m3.aw_len     = s.aw_len[3];
         assign m3.aw_size    = s.aw_size[3];
         assign m3.aw_burst   = s.aw_burst[3];
         assign m3.aw_lock    = s.aw_lock[3];
         assign m3.aw_cache   = s.aw_cache[3];
         assign m3.aw_prot    = s.aw_prot[3];
         assign m3.aw_qos     = s.aw_qos[3];
         assign m3.aw_region  = s.aw_region[3]
         assign m3.aw_user    = s.aw_user[3];
         assign m3.aw_valid   = s.aw_valid[3];
         assign m3.ar_id      = s.ar_id[3];
         assign m3.ar_addr    = s.ar_addr[3];
         assign m3.ar_len     = s.ar_len[3];
         assign m3.ar_size    = s.ar_size[3];
         assign m3.ar_burst   = s.ar_burst[3];
         assign m3.ar_lock    = s.ar_lock[3];
         assign m3.ar_cache   = s.ar_cache[3];
         assign m3.ar_prot    = s.ar_prot[3];
         assign m3.ar_qos     = s.ar_qos[3];
         assign m3.ar_region  = s.ar_region[3]
         assign m3.ar_user    = s.ar_user[3];
         assign m3.ar_valid   = s.ar_valid[3];
         assign m3.w_data     = s.w_data[3];
         assign m3.w_strb     = s.w_strb[3];
         assign m3.w_last     = s.w_last[3];
         assign m3.w_user     = s.w_user[3];
         assign m3.w_valid    = s.w_valid[3];
         assign m3.b_ready    = s.b_ready[3];
         assign m3.r_ready    = s.r_ready[3];
         assign s.aw_ready[3] = m3.aw_ready;
         assign s.ar_ready[3] = m3.ar_ready;
         assign s.w_ready[3]  = m3.w_ready;
         assign s.b_id[3]     = m3.b_id;
         assign s.b_resp[3]   = m3.b_resp;
         assign s.b_user[3]   = m3.b_user;
         assign s.b_valid[3]  = m3.b_valid;
         assign s.r_data[3]   = m3.r_data;
         assign s.r_last[3]   = m3.r_last;
         assign s.r_id[3]     = m3.r_id;
         assign s.r_resp[3]   = m3.r_resp;
         assign s.r_user[3]   = m3.r_user;
         assign s.r_valid[3]  = m3.r_valid;
      end

      if(N_PORT > 4) begin
         assign m4.aw_id      = s.aw_id[4];
         assign m4.aw_addr    = s.aw_addr[4];
         assign m4.aw_len     = s.aw_len[4];
         assign m4.aw_size    = s.aw_size[4];
         assign m4.aw_burst   = s.aw_burst[4];
         assign m4.aw_lock    = s.aw_lock[4];
         assign m4.aw_cache   = s.aw_cache[4];
         assign m4.aw_prot    = s.aw_prot[4];
         assign m4.aw_qos     = s.aw_qos[4];
         assign m4.aw_region  = s.aw_region[4]
         assign m4.aw_user    = s.aw_user[4];
         assign m4.aw_valid   = s.aw_valid[4];
         assign m4.ar_id      = s.ar_id[4];
         assign m4.ar_addr    = s.ar_addr[4];
         assign m4.ar_len     = s.ar_len[4];
         assign m4.ar_size    = s.ar_size[4];
         assign m4.ar_burst   = s.ar_burst[4];
         assign m4.ar_lock    = s.ar_lock[4];
         assign m4.ar_cache   = s.ar_cache[4];
         assign m4.ar_prot    = s.ar_prot[4];
         assign m4.ar_qos     = s.ar_qos[4];
         assign m4.ar_region  = s.ar_region[4]
         assign m4.ar_user    = s.ar_user[4];
         assign m4.ar_valid   = s.ar_valid[4];
         assign m4.w_data     = s.w_data[4];
         assign m4.w_strb     = s.w_strb[4];
         assign m4.w_last     = s.w_last[4];
         assign m4.w_user     = s.w_user[4];
         assign m4.w_valid    = s.w_valid[4];
         assign m4.b_ready    = s.b_ready[4];
         assign m4.r_ready    = s.r_ready[4];
         assign s.aw_ready[4] = m4.aw_ready;
         assign s.ar_ready[4] = m4.ar_ready;
         assign s.w_ready[4]  = m4.w_ready;
         assign s.b_id[4]     = m4.b_id;
         assign s.b_resp[4]   = m4.b_resp;
         assign s.b_user[4]   = m4.b_user;
         assign s.b_valid[4]  = m4.b_valid;
         assign s.r_data[4]   = m4.r_data;
         assign s.r_last[4]   = m4.r_last;
         assign s.r_id[4]     = m4.r_id;
         assign s.r_resp[4]   = m4.r_resp;
         assign s.r_user[4]   = m4.r_user;
         assign s.r_valid[4]  = m4.r_valid;
      end

      if(N_PORT > 5) begin
         assign m5.aw_id      = s.aw_id[5];
         assign m5.aw_addr    = s.aw_addr[5];
         assign m5.aw_len     = s.aw_len[5];
         assign m5.aw_size    = s.aw_size[5];
         assign m5.aw_burst   = s.aw_burst[5];
         assign m5.aw_lock    = s.aw_lock[5];
         assign m5.aw_cache   = s.aw_cache[5];
         assign m5.aw_prot    = s.aw_prot[5];
         assign m5.aw_qos     = s.aw_qos[5];
         assign m5.aw_region  = s.aw_region[5]
         assign m5.aw_user    = s.aw_user[5];
         assign m5.aw_valid   = s.aw_valid[5];
         assign m5.ar_id      = s.ar_id[5];
         assign m5.ar_addr    = s.ar_addr[5];
         assign m5.ar_len     = s.ar_len[5];
         assign m5.ar_size    = s.ar_size[5];
         assign m5.ar_burst   = s.ar_burst[5];
         assign m5.ar_lock    = s.ar_lock[5];
         assign m5.ar_cache   = s.ar_cache[5];
         assign m5.ar_prot    = s.ar_prot[5];
         assign m5.ar_qos     = s.ar_qos[5];
         assign m5.ar_region  = s.ar_region[5]
         assign m5.ar_user    = s.ar_user[5];
         assign m5.ar_valid   = s.ar_valid[5];
         assign m5.w_data     = s.w_data[5];
         assign m5.w_strb     = s.w_strb[5];
         assign m5.w_last     = s.w_last[5];
         assign m5.w_user     = s.w_user[5];
         assign m5.w_valid    = s.w_valid[5];
         assign m5.b_ready    = s.b_ready[5];
         assign m5.r_ready    = s.r_ready[5];
         assign s.aw_ready[5] = m5.aw_ready;
         assign s.ar_ready[5] = m5.ar_ready;
         assign s.w_ready[5]  = m5.w_ready;
         assign s.b_id[5]     = m5.b_id;
         assign s.b_resp[5]   = m5.b_resp;
         assign s.b_user[5]   = m5.b_user;
         assign s.b_valid[5]  = m5.b_valid;
         assign s.r_data[5]   = m5.r_data;
         assign s.r_last[5]   = m5.r_last;
         assign s.r_id[5]     = m5.r_id;
         assign s.r_resp[5]   = m5.r_resp;
         assign s.r_user[5]   = m5.r_user;
         assign s.r_valid[5]  = m5.r_valid;
      end

      if(N_PORT > 6) begin
         assign m6.aw_id      = s.aw_id[6];
         assign m6.aw_addr    = s.aw_addr[6];
         assign m6.aw_len     = s.aw_len[6];
         assign m6.aw_size    = s.aw_size[6];
         assign m6.aw_burst   = s.aw_burst[6];
         assign m6.aw_lock    = s.aw_lock[6];
         assign m6.aw_cache   = s.aw_cache[6];
         assign m6.aw_prot    = s.aw_prot[6];
         assign m6.aw_qos     = s.aw_qos[6];
         assign m6.aw_region  = s.aw_region[6]
         assign m6.aw_user    = s.aw_user[6];
         assign m6.aw_valid   = s.aw_valid[6];
         assign m6.ar_id      = s.ar_id[6];
         assign m6.ar_addr    = s.ar_addr[6];
         assign m6.ar_len     = s.ar_len[6];
         assign m6.ar_size    = s.ar_size[6];
         assign m6.ar_burst   = s.ar_burst[6];
         assign m6.ar_lock    = s.ar_lock[6];
         assign m6.ar_cache   = s.ar_cache[6];
         assign m6.ar_prot    = s.ar_prot[6];
         assign m6.ar_qos     = s.ar_qos[6];
         assign m6.ar_region  = s.ar_region[6]
         assign m6.ar_user    = s.ar_user[6];
         assign m6.ar_valid   = s.ar_valid[6];
         assign m6.w_data     = s.w_data[6];
         assign m6.w_strb     = s.w_strb[6];
         assign m6.w_last     = s.w_last[6];
         assign m6.w_user     = s.w_user[6];
         assign m6.w_valid    = s.w_valid[6];
         assign m6.b_ready    = s.b_ready[6];
         assign m6.r_ready    = s.r_ready[6];
         assign s.aw_ready[6] = m6.aw_ready;
         assign s.ar_ready[6] = m6.ar_ready;
         assign s.w_ready[6]  = m6.w_ready;
         assign s.b_id[6]     = m6.b_id;
         assign s.b_resp[6]   = m6.b_resp;
         assign s.b_user[6]   = m6.b_user;
         assign s.b_valid[6]  = m6.b_valid;
         assign s.r_data[6]   = m6.r_data;
         assign s.r_last[6]   = m6.r_last;
         assign s.r_id[6]     = m6.r_id;
         assign s.r_resp[6]   = m6.r_resp;
         assign s.r_user[6]   = m6.r_user;
         assign s.r_valid[6]  = m6.r_valid;
      end

      if(N_PORT > 7) begin
         assign m7.aw_id      = s.aw_id[7];
         assign m7.aw_addr    = s.aw_addr[7];
         assign m7.aw_len     = s.aw_len[7];
         assign m7.aw_size    = s.aw_size[7];
         assign m7.aw_burst   = s.aw_burst[7];
         assign m7.aw_lock    = s.aw_lock[7];
         assign m7.aw_cache   = s.aw_cache[7];
         assign m7.aw_prot    = s.aw_prot[7];
         assign m7.aw_qos     = s.aw_qos[7];
         assign m7.aw_region  = s.aw_region[7]
         assign m7.aw_user    = s.aw_user[7];
         assign m7.aw_valid   = s.aw_valid[7];
         assign m7.ar_id      = s.ar_id[7];
         assign m7.ar_addr    = s.ar_addr[7];
         assign m7.ar_len     = s.ar_len[7];
         assign m7.ar_size    = s.ar_size[7];
         assign m7.ar_burst   = s.ar_burst[7];
         assign m7.ar_lock    = s.ar_lock[7];
         assign m7.ar_cache   = s.ar_cache[7];
         assign m7.ar_prot    = s.ar_prot[7];
         assign m7.ar_qos     = s.ar_qos[7];
         assign m7.ar_region  = s.ar_region[7]
         assign m7.ar_user    = s.ar_user[7];
         assign m7.ar_valid   = s.ar_valid[7];
         assign m7.w_data     = s.w_data[7];
         assign m7.w_strb     = s.w_strb[7];
         assign m7.w_last     = s.w_last[7];
         assign m7.w_user     = s.w_user[7];
         assign m7.w_valid    = s.w_valid[7];
         assign m7.b_ready    = s.b_ready[7];
         assign m7.r_ready    = s.r_ready[7];
         assign s.aw_ready[7] = m7.aw_ready;
         assign s.ar_ready[7] = m7.ar_ready;
         assign s.w_ready[7]  = m7.w_ready;
         assign s.b_id[7]     = m7.b_id;
         assign s.b_resp[7]   = m7.b_resp;
         assign s.b_user[7]   = m7.b_user;
         assign s.b_valid[7]  = m7.b_valid;
         assign s.r_data[7]   = m7.r_data;
         assign s.r_last[7]   = m7.r_last;
         assign s.r_id[7]     = m7.r_id;
         assign s.r_resp[7]   = m7.r_resp;
         assign s.r_user[7]   = m7.r_user;
         assign s.r_valid[7]  = m7.r_valid;
      end
   endgenerate

endmodule



