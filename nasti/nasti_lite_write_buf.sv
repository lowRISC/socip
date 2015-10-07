// See LICENSE for license details.

module nasti_lite_write_buf
  #(
    BUF_DEPTH = 2,              // depth of the buffer
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
    input                           nasti_aw_ready,
    input  [NASTI_DATA_WIDTH-1:0]   nasti_w_data,
    input  [NASTI_DATA_WIDTH/8-1:0] nasti_w_strb,
    input                           nasti_w_last,
    input  [USER_WIDTH-1:0]         nasti_w_user,
    input                           nasti_w_valid,
    output                          nasti_w_ready,
    output [ID_WIDTH-1:0]           lite_aw_id,
    output [ADDR_WIDTH-1:0]         lite_aw_addr,
    output [2:0]                    lite_aw_prot,
    output [3:0]                    lite_aw_qos,
    output [3:0]                    lite_aw_region,
    output [USER_WIDTH-1:0]         lite_aw_aw_user,
    output                          lite_aw_valid,
    output                          lite_w_ready,
    output [LITE_DATA_WIDTH-1:0]    lite_w_data,
    output [LITE_DATA_WIDTH/8-1:0]  lite_w_strb,
    output [USER_WIDTH-1:0]         lite_w_w_user,
    output                          lite_w_valid,
    input                           lite_w_ready
    );

   localparam BUF_DATA_WIDTH = NASTI_DATA_WIDTH < LITE_DATA_WIDTH ? NASTI_DATA_WIDTH : LITE_DATA_WIDTH;
   localparam MAX_BURST_SIZE = NASTI_DATA_WIDTH/BUF_DATA_WIDTH;

   genvar                           i;

   init begin
      assert(LITE_DATA_WIDTH == 32 || LITE_DATA_WIDTH == 64)
        else $fatal(1, "nasti-lite support only 32/64-bit channels!");

     assert(BUF_DEPTH >= (NASTI_DATA_WIDTH-1)/LITE_DATA_WIDTH + 1)
       else $fatal(1, "nasti_lite_write_buf buffer depth too short!");
   end

   // shared information
   logic [ID_WIDTH-1:0]             aw_id;
   logic [ADDR_WIDTH-1:0]           aw_addr;
   logic [2:0]                      aw_size;
   logic [2:0]                      aw_prot;
   logic [3:0]                      aw_qos;
   logic [3:0]                      aw_region;
   logic [USER_WIDTH-1:0]           aw_user, w_user;
   logic                            w_last;

   // packet information
   logic [BUF_DEPTH-1:0][ADDR_WIDTH-1:0]         addr_q;
   logic [BUF_DEPTH-1:0][BUF_DATA_WIDTH-1:0]     data_q;
   logic [BUF_DEPTH-1:0][BUF_DATA_WIDTH/8-1:0]   strb_q;

   // read/write pointer
   logic                                         lock;
   logic [$clog2(BUF_DEPTH)-1:0]                 wp, aw_rp, w_rp;
   logic [BUF_DEPTH-1:0]                         aw_q_valid, w_q_valid;
   logic                                         aw_empty, w_empty;

   logic [$clog2(BUF_DEPTH)-1:0]                 wp_step;                 
   logic [2*BUF_DEPTH-1:0]                       wp_start, wp_start_mask;
   logic [2*BUF_DEPTH-1:0]                       wp_end, wp_end_mask;
   logic [2*BUF_DEPTH-1:0]                       wp_update_ext;
   logic [BUF_DEPTH-1:0]                         wp_update;

   // help functions
   function logic [$clog2(BUF_DEPTH)-1:0] incr(logic [$clog2(BUF_DEPTH)-1:0] p, step);
      return p + step >= BUF_DEPTH ? p + step - BUF_DEPTH : p + step;
   endfunction // incr

   function logic [7:0] nasti_byte_size (logic [2:0] s);
      return 1 << s;
   endfunction // nasti_byte_size
   
   function logic [$clog2(BUF_DEPTH)-1:0] lite_packet_size (logic [2:0] s);
      return nasti_byte_size(s) / BUF_DATA_WIDTH;
   endfunction // lite_packet_size

   function logic [$clog2(MAX_BURST_SIZE)-1:0] busrt_index(logic [$clog2(BUF_DEPTH)-1:0] p, index);
      return index - wp;
   endfunction

   // burst size calculator
   assign wp_step = lite_packet_size(aw_size);
   assign wp_start = 1 << wp;                // [00010000]
   assign wp_end = 1 << wp + wp_step;        // [00000100]
   generate
      for(i=1; i<2*BUF_DEPTH; i++) assign wp_start_mask[i] = wp_start_mask[i-1] | wp_start[i];
      for(i=2*BUF_DEPTH-1; i!=0; i--) assign wp_end_mask[i-1] = wp_end_mask[i] | wp_end[i];
      assign wp_start_mask[0] = wp_start[i]; // [00011111]
      assign wp_end_mask[2*BUF_DEPTH-1] = 0; // [11111000]
   endgenerate
   assign wp_update_ext = wp_start_mask & wp_end_mask; // [00011000]
   assign wp_update = wp_update_ext[0 +: BUF_DEPTH] | wp_update_ext[BUF_DEPTH +: BUF_DEPTH]; // [1001]

   // valid/ready signals
   assign nasti_aw_ready = !lock;
   assign nasti_w_ready = lock && !(aw_q_valid & wp_update) && !(w_q_valid & wp_update);
   assign lite_aw_valid = aw_q_valid[aw_rp];
   assign lite_w_valid = w_q_valid[w_rp];
   assign aw_empty = wp == aw_rp && !aw_q_valid[aw_rp];
   assign w_empty = wp == w_rp && !w_q_valid[w_rp];

   always_ff @(posedge clk or negedge rstn)
     if(!rstn) begin
        lock <= 0;
        wp <= 0;
        aw_rp <= 0;
        w_rp <= 0;
        aw_q_valid <= 0;
        w_q_valid <= 0;
     end else begin
        if(nasti_aw_valid && nasti_aw_ready)
          lock <= 1'b1;
        else if(w_last && aw_empty && w_empty)
          lock <= 0;

        if(nasti_w_valid && nasti_w_ready) begin
           wp <= incr(wp, wp_step);
           aw_q_valid <= aw_q_valid | wp_update;
           w_q_valid <= w_q_valid | wp_update;
        end

        if(lite_aw_valid && lite_aw_ready) begin
           aw_rp <= incr(aw_rp, 1);
           aw_q_valid[aw_rp] <= 0;
        end

        if(lite_w_valid && lite_w_ready) begin
           w_rp <= incr(w_rp, 1);
           w_q_valid[w_rp] <= 0;
        end
     end // else: !if(!rstn)

   // buffer AW
   always_ff @(posedge clk)
     if(nasti_aw_valid && nasti_aw_ready) begin
        aw_id <= nasti_aw_id;
        aw_addr <= nasti_aw_addr;
        aw_size <= nasti_aw_size;
        aw_prot <= nasti_aw_prot;
        aw_qos <= nasti_aw_qos;
        aw_region <= nasti_aw_region;
        aw_user <= nasti_aw_user;
     end else if(nasti_w_valid && nasti_w_ready)
       aw_addr <= aw_addr + wp_step;

   // buffer data burst
   generate
      for(i=0; i<BUF_DEPTH; i++)
        always_ff @(posedge clk)
          if(nasti_w_valid && nasti_w_ready && wp_update[i]) begin
             addr_q[i] <= aw_addr + busrt_index(wp, i) * BUF_DATA_WIDTH / 8;
             data_q[i] <= nasti_w_data[busrt_index(wp, i) * BUF_DATA_WIDTH +: BUF_DATA_WIDTH];
             strb_q[i] <= nasti_w_strb[busrt_index(wp, i) * BUF_DATA_WIDTH/8 +: BUF_DATA_WIDTH/8];
          end
   endgenerate

   // drive lite
   assign lite_aw_id = aw_id;
   assign lite_aw_addr = addr_q[aw_rp];
   assign lite_aw_prot = aw_prot;
   assign lite_aw_qos = aw_qos;
   assign lite_aw_region = aw_region;
   assign lite_aw_aw_user = aw_user;
   assign lite_w_data = data_q[w_rp];
   assign lite_w_strb = strb_q[w_rp];
   assign lite_w_w_user = w_user;

endmodule // nasti_lite_write_buf


   
    
