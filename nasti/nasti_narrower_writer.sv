// See LICENSE for license details.
module nasti_narrower_writer
  #(
    ID_WIDTH          = 2,      // NASTI ID size
    ADDR_WIDTH        = 32,     // NASTI address width
    MASTER_DATA_WIDTH = 64,     // data width on the master side
    SLAVE_DATA_WIDTH  = 32,     // data width on the slave side
    USER_WIDTH        = 1       // size of USER field
    )
   (
    input                           clk, rstn,

    input [ID_WIDTH-1:0]            master_aw_id,
    input [ADDR_WIDTH-1:0]          master_aw_addr,
    input [7:0]                     master_aw_len,
    input [2:0]                     master_aw_size,
    input [1:0]                     master_aw_burst,
    input                           master_aw_lock,
    input [3:0]                     master_aw_cache,
    input [2:0]                     master_aw_prot,
    input [3:0]                     master_aw_qos,
    input [3:0]                     master_aw_region,
    input [USER_WIDTH-1:0]          master_aw_user,
    input                           master_aw_valid,
    output                          master_aw_ready,

    input [MASTER_DATA_WIDTH-1:0]   master_w_data,
    input [MASTER_DATA_WIDTH/8-1:0] master_w_strb,
    input                           master_w_last,
    input [USER_WIDTH-1:0]          master_w_user,
    input                           master_w_valid,
    output                          master_w_ready,

    output [ID_WIDTH-1:0]           master_b_id,
    output [1:0]                    master_b_resp,
    output [USER_WIDTH-1:0]         master_b_user,
    output                          master_b_valid,
    input                           master_b_ready,

    output [ID_WIDTH-1:0]           slave_aw_id,
    output [ADDR_WIDTH-1:0]         slave_aw_addr,
    output [7:0]                    slave_aw_len,
    output [2:0]                    slave_aw_size,
    output [1:0]                    slave_aw_burst,
    output                          slave_aw_lock,
    output [3:0]                    slave_aw_cache,
    output [2:0]                    slave_aw_prot,
    output [3:0]                    slave_aw_qos,
    output [3:0]                    slave_aw_region,
    output [USER_WIDTH-1:0]         slave_aw_user,
    output                          slave_aw_valid,
    input                           slave_aw_ready,

    output [SLAVE_DATA_WIDTH-1:0]   slave_w_data,
    output [SLAVE_DATA_WIDTH/8-1:0] slave_w_strb,
    output                          slave_w_last,
    output [USER_WIDTH-1:0]         slave_w_user,
    output                          slave_w_valid,
    input                           slave_w_ready,

    input  [ID_WIDTH-1:0]           slave_b_id,
    input  [1:0]                    slave_b_resp,
    input  [USER_WIDTH-1:0]         slave_b_user,
    input                           slave_b_valid,
    output                          slave_b_ready
    );

   localparam MASTER_CHANNEL_SIZE = $clog2(MASTER_DATA_WIDTH/8);
   localparam SLAVE_CHANNEL_SIZE = $clog2(SLAVE_DATA_WIDTH/8);
   
   `include "nasti_request.vh"

   NastiReq                         request;
   logic [7:0]                      w_cnt;
   logic [ADDR_WIDTH-1:0]           w_addr;

   enum {S_IDLE, S_AW, S_W, S_B}    state;

   function int unsigned ratio (input NastiReq req);
      return req.size > SLAVE_CHANNEL_SIZE ? 1 << (req.size - SLAVE_CHANNEL_SIZE) : 1;
   endfunction // ratio
   
   function int unsigned ratio_offset (input NastiReq req);
      return req.size > SLAVE_CHANNEL_SIZE ? (req.size - SLAVE_CHANNEL_SIZE) : 0;
   endfunction // ratio

   function int unsigned slave_step (input NastiReq req);
      return req.size > SLAVE_CHANNEL_SIZE ? SLAVE_DATA_WIDTH / 8 : 1 << req.size;
   endfunction // slave_len

   function int unsigned burst_index(input NastiReq req, int unsigned addr);
      return (addr >> SLAVE_CHANNEL_SIZE) & ((1 << (req.size - SLAVE_CHANNEL_SIZE)) - 1);
   endfunction // burst_index

   function int unsigned slave_len (input NastiReq req);
      if(ratio(req) > 1)        // special treatment for unaligned addr
        return (req.len << ratio_offset(req)) + ratio(req) - burst_index(req, req.addr) - 1;
      else
        return req.len;
   endfunction // slave_len

   function int unsigned slave_size (input NastiReq req);
      return req.size > SLAVE_CHANNEL_SIZE ? SLAVE_CHANNEL_SIZE : req.size;
   endfunction // slave_size

   function int unsigned total_size (input int unsigned r_size, r_len);
      return (1 << r_size) * (r_len + 1);
   endfunction // total_size
   
   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       state <= S_IDLE;
     else
       case (state)
         S_IDLE:
           if(master_aw_valid && master_aw_ready)
             state <= S_AW;
         S_AW:
           if(slave_aw_valid && slave_aw_ready)
             state <= S_W;
         S_W:
           if(slave_w_valid && slave_w_ready && slave_w_last)
             state <= S_B;
         S_B:
           if(master_b_valid && master_b_ready)
             state <= S_IDLE;
       endcase // case (state)

   always_ff @(posedge clk)
     if(master_aw_valid && master_aw_ready) begin
        request <= NastiReq'{master_aw_id, master_aw_addr, master_aw_len,
                             master_aw_size, master_aw_burst, master_aw_lock,
                             master_aw_cache, master_aw_prot, master_aw_qos,
                             master_aw_region, master_aw_user};

        assert(master_aw_burst == 2'b01)
          else $fatal(1, "nasti narrower support only INCR burst!");
        assert(total_size(master_aw_size, master_aw_len) <= 32 * SLAVE_DATA_WIDTH)
          else $fatal(1, "nasti narrower does not support burst larger than slave's maximal burst size!");
     end

   assign master_aw_ready = state == S_IDLE;

   assign slave_aw_valid = state == S_AW;
   assign slave_aw_id = request.id;
   assign slave_aw_addr = request.addr;
   assign slave_aw_len = slave_len(request);
   assign slave_aw_size = slave_size(request);
   assign slave_aw_burst = request.burst;
   assign slave_aw_lock = request.lock;
   assign slave_aw_cache = request.cache;
   assign slave_aw_prot = request.prot;
   assign slave_aw_qos = request.qos;
   assign slave_aw_region = request.region;
   assign slave_aw_user = request.user;

   always_ff @(posedge clk)
     if(slave_w_valid && slave_w_ready) begin // special treatment for unalign addr
        w_addr <= ((w_addr >> ratio_offset(request)) << ratio_offset(request))
          + slave_step(request);
     end else if(master_aw_valid && master_aw_ready)
       w_addr <= master_aw_addr;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       w_cnt <= 0;
     else if(slave_w_valid && slave_w_ready)
       w_cnt <= w_cnt + 1;
     else if(master_aw_valid && master_aw_ready)
       w_cnt <= 0;

   assign slave_w_data = master_w_data >> (w_addr[MASTER_CHANNEL_SIZE-1:SLAVE_CHANNEL_SIZE]*SLAVE_DATA_WIDTH);
   assign slave_w_strb = master_w_strb >> (w_addr[MASTER_CHANNEL_SIZE-1:SLAVE_CHANNEL_SIZE]*SLAVE_DATA_WIDTH/8);
   assign slave_w_user = master_w_user;
   assign slave_w_last = w_cnt == slave_len(request);
   assign slave_w_valid = master_w_valid && state == S_W;
   assign master_w_ready
     = (w_addr & ( (1 << request.size) - 1)) + slave_step(request) >= (1 << request.size)
       && slave_w_ready && state == S_W;

   assign master_b_id = slave_b_id;
   assign master_b_resp = slave_b_resp;
   assign master_b_user = slave_b_user;
   assign master_b_valid = slave_b_valid && state == S_B;
   assign slave_b_ready = master_b_ready && state == S_B;

endmodule // nasti_narrower_writer
