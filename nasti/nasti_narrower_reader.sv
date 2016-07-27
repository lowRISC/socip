// See LICENSE for license details.

module nasti_narrower_reader
  #(
    ID_WIDTH          = 2,      // NASTI ID size
    ADDR_WIDTH        = 32,     // NASTI address width
    MASTER_DATA_WIDTH = 64,     // data width on the master side
    SLAVE_DATA_WIDTH  = 32,     // data width on the slave side
    USER_WIDTH        = 1       // size of USER field
    )
   (
    input                              clk, rstn,

    input [ID_WIDTH-1:0]               master_ar_id,
    input [ADDR_WIDTH-1:0]             master_ar_addr,
    input [7:0]                        master_ar_len,
    input [2:0]                        master_ar_size,
    input [1:0]                        master_ar_burst,
    input                              master_ar_lock,
    input [3:0]                        master_ar_cache,
    input [2:0]                        master_ar_prot,
    input [3:0]                        master_ar_qos,
    input [3:0]                        master_ar_region,
    input [USER_WIDTH-1:0]             master_ar_user,
    input                              master_ar_valid,
    output                             master_ar_ready,

    output [ID_WIDTH-1:0]              master_r_id,
    output reg [MASTER_DATA_WIDTH-1:0] master_r_data,
    output reg [1:0]                   master_r_resp,
    output reg                         master_r_last,
    output reg [USER_WIDTH-1:0]        master_r_user,
    output reg                         master_r_valid,
    input                              master_r_ready,

    output [ID_WIDTH-1:0]              slave_ar_id,
    output [ADDR_WIDTH-1:0]            slave_ar_addr,
    output [7:0]                       slave_ar_len,
    output [2:0]                       slave_ar_size,
    output [1:0]                       slave_ar_burst,
    output                             slave_ar_lock,
    output [3:0]                       slave_ar_cache,
    output [2:0]                       slave_ar_prot,
    output [3:0]                       slave_ar_qos,
    output [3:0]                       slave_ar_region,
    output [USER_WIDTH-1:0]            slave_ar_user,
    output                             slave_ar_valid,
    input                              slave_ar_ready,

    input [ID_WIDTH-1:0]               slave_r_id,
    input [SLAVE_DATA_WIDTH-1:0]       slave_r_data,
    input [1:0]                        slave_r_resp,
    input                              slave_r_last,
    input [USER_WIDTH-1:0]             slave_r_user,
    input                              slave_r_valid,
    output                             slave_r_ready
    );

   localparam MASTER_CHANNEL_SIZE = $clog2(MASTER_DATA_WIDTH/8);
   localparam SLAVE_CHANNEL_SIZE = $clog2(SLAVE_DATA_WIDTH/8);
   
   `include "nasti_request.vh"

   NastiReq                         request;
   logic [7:0]                      r_cnt;
   logic [ADDR_WIDTH-1:0]           r_addr;

   enum {S_IDLE, S_AR, S_R}         state;

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
           if(master_ar_valid && master_ar_ready)
             state <= S_AR;
         S_AR:
           if(slave_ar_valid && slave_ar_ready)
             state <= S_R;
         S_R:
           if(master_r_valid && master_r_ready && master_r_last)
             state <= S_IDLE;
       endcase // case (state)

   always_ff @(posedge clk)
     if(master_ar_valid && master_ar_ready) begin
        request <= NastiReq'{master_ar_id, master_ar_addr, master_ar_len,
                             master_ar_size, master_ar_burst, master_ar_lock,
                             master_ar_cache, master_ar_prot, master_ar_qos,
                             master_ar_region, master_ar_user};

        assert(master_ar_burst == 2'b01)
          else $fatal(1, "nasti narrower support only INCR burst!");
        assert(total_size(master_ar_size, master_ar_len) <= 32 * SLAVE_DATA_WIDTH)
          else $fatal(1, "nasti narrower does not support burst larger than slave's maximal burst size!");
     end

   assign master_ar_ready = state == S_IDLE;

   assign slave_ar_valid = state == S_AR;
   assign slave_ar_id = request.id;
   assign slave_ar_addr = request.addr;
   assign slave_ar_len = slave_len(request);
   assign slave_ar_size = slave_size(request);
   assign slave_ar_burst = request.burst;
   assign slave_ar_lock = request.lock;
   assign slave_ar_cache = request.cache;
   assign slave_ar_prot = request.prot;
   assign slave_ar_qos = request.qos;
   assign slave_ar_region = request.region;
   assign slave_ar_user = request.user;

   always_ff @(posedge clk)
     if(slave_r_valid && slave_r_ready) begin // special treatment for unalign addr
        r_addr <= ((r_addr >> ratio_offset(request)) << ratio_offset(request))
          + slave_step(request);
     end else if(master_ar_valid && master_ar_ready)
       r_addr <= master_ar_addr;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       r_cnt <= 0;
     else if(master_r_valid && master_r_ready)
       r_cnt <= r_cnt + 1;
     else if(master_ar_valid && master_ar_ready)
       r_cnt <= 0;

   always_ff @(posedge clk)
     if(slave_r_valid && slave_r_ready) begin
        master_r_data[r_addr[MASTER_CHANNEL_SIZE-1:SLAVE_CHANNEL_SIZE]*SLAVE_DATA_WIDTH +: SLAVE_DATA_WIDTH] <= slave_r_data;
        master_r_last <= r_cnt == request.len;
        master_r_resp <= slave_r_resp;
        master_r_user <= slave_r_user;
        assert(slave_r_resp == 0)
          else $fatal(1, "AXI interface response error!");
     end else if(slave_ar_valid && slave_ar_ready)
       master_r_data <= 0;

   always_ff @(posedge clk or negedge rstn)
     if(!rstn)
       master_r_valid <= 1'b0;
     else if(slave_r_valid && slave_r_ready)
       master_r_valid <= (r_addr & ( (1 << request.size) - 1)) + slave_step(request) >= (1 << request.size);
     else if(master_r_valid && master_r_ready)
       master_r_valid <= 1'b0;

   assign master_r_id = request.id;

   assign slave_r_ready = state == S_R && (!master_r_valid || master_r_ready);

endmodule // nasti_narrower_reader
