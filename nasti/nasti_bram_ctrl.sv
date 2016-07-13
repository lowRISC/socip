module nasti_bram_ctrl # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 32,
   parameter BRAM_ADDR_WIDTH = 16,
   parameter ID_WIDTH = 1
) (
   input  s_nasti_aclk,
   input  s_nasti_aresetn,
   nasti_channel.slave s_nasti,

   output bram_clk,
   output bram_rst,
   output bram_en,
   output [DATA_WIDTH/8-1:0] bram_we,
   output [BRAM_ADDR_WIDTH-1:0] bram_addr,
   output [DATA_WIDTH-1:0] bram_wrdata,
   input  [DATA_WIDTH-1:0] bram_rddata
);

   /* AXI */

   // Whether the BRAM controller is ready for R/W transaction
   logic a_ready;

   assign s_nasti.ar_ready = a_ready;
   assign s_nasti.aw_ready = a_ready;

   // Always success
   assign s_nasti.r_resp = 0;
   assign s_nasti.b_resp = 0;

   /* Reading */

   logic [ADDR_WIDTH-1:0] read_burst_addr;
   logic [7:0] read_burst_remaining;

   // Whether there is an inbound read transaction
   logic inbound_read;
   assign inbound_read = s_nasti.ar_ready & s_nasti.ar_valid;

   // Whether next data in a read burst can be served
   logic read_can_serve_next;
   assign read_can_serve_next = s_nasti.r_ready & s_nasti.r_valid & !s_nasti.r_last;

   // Whether there is an pending read response
   // we can only guarantee that BRAM data is available for one cycle
   // So we need to cache the data
   logic pending_read;
   logic [DATA_WIDTH-1:0] pending_read_data;

   /* Writing */

   logic [ADDR_WIDTH-1:0] write_burst_addr;
   logic [7:0] write_burst_remaining;

   // Whether there is an inbound write transaction
   logic inbound_write;
   logic inbound_write_data;

   assign inbound_write = s_nasti.aw_ready & s_nasti.aw_valid;
   assign inbound_write_data = s_nasti.w_ready & s_nasti.w_valid;

   // Whether there is an pending write transaction
   // caused by simultaneous read & wrtie transaction
   logic pending_write;

   /* BRAM control */

   // Wire BRAM clk and rst directly
   assign bram_clk = s_nasti_aclk;
   assign bram_rst = !s_nasti_aresetn;

   // Activate bram_en when next state is read complete state or write complete state
   assign bram_en = inbound_read | read_can_serve_next | inbound_write_data;

   // Choose correct address depending on next state
   assign bram_addr = read_can_serve_next ? read_burst_addr :
                  inbound_read ? s_nasti.ar_addr :
                  inbound_write_data ? write_burst_addr : {BRAM_ADDR_WIDTH{1'bx}};

   // Wire BRAM's R/W ports directly to AXI
   assign s_nasti.r_data = pending_read ? pending_read_data : bram_rddata;
   assign bram_we = inbound_write_data ? s_nasti.w_strb : 0;
   assign bram_wrdata = inbound_write_data ? s_nasti.w_data : {DATA_WIDTH{1'bx}};

   always_ff @(posedge s_nasti_aclk or negedge s_nasti_aresetn)
   begin
      if (!s_nasti_aresetn) begin
         pending_read   <= 0;
         pending_write  <= 0;
         a_ready        <= 1;
         s_nasti.r_valid <= 0;
         s_nasti.w_ready <= 0;
         s_nasti.b_valid <= 0;
         s_nasti.r_last <= 0;
      end
      else if (a_ready) begin
         // Idle state

         if (inbound_read) begin
            assert ((s_nasti.ar_addr & (DATA_WIDTH/8-1)) == 0) else $error("Unaligned burst not supported: ar_addr = %x", s_nasti.ar_addr);
            assert ((8 << s_nasti.ar_size) == DATA_WIDTH) else $error("Narrow burst not supported");
            assert (s_nasti.ar_burst == 1) else $error("Only INCR burst mode is supported");

            a_ready <= 0;

            // BRAM should present valid data
            // in this time already, so set valid to high
            // Transition to reading state
            s_nasti.r_valid <= 1;

            // Advance address and decrease remaining length
            read_burst_addr <= s_nasti.ar_addr + DATA_WIDTH / 8;
            read_burst_remaining <= s_nasti.ar_len;

            s_nasti.r_id <= s_nasti.ar_id;

            // If the burst length is 1, then set r_last
            if (s_nasti.ar_len == 0)
               s_nasti.r_last = 1;
         end

         if (inbound_write) begin
            assert ((s_nasti.aw_addr & (DATA_WIDTH/8-1)) == 0) else $error("Unaligned burst not supported, aw_addr = %x", s_nasti.aw_addr);
            assert ((8 << s_nasti.aw_size) == DATA_WIDTH) else $error("Narrow burst not supported");
            assert (s_nasti.aw_burst == 1) else $error("Only INCR burst mode is supported");

            write_burst_addr <= s_nasti.aw_addr;
            write_burst_remaining <= s_nasti.aw_len + 1;

            s_nasti.b_id <= s_nasti.aw_id;

            if (inbound_read) begin
               // When read and write arrives together
               // We process read first and pend the write transaction
               pending_write  <= 1;
            end
            else begin
               a_ready <= 0;

               // Transition to write state
               s_nasti.w_ready <= 1;
            end
         end
      end
      else if (s_nasti.r_valid) begin
         // Reading state

         if (s_nasti.r_ready) begin
            pending_read <= 0;

            if (s_nasti.r_last) begin
               s_nasti.r_valid <= 0;
               s_nasti.r_last <= 0;

               if (pending_write) begin
                  s_nasti.w_ready <= 1;
                  pending_write  <= 0;
               end
               else begin
                   // Transition to idle state
                   a_ready <= 1;
               end
            end
            else begin
               // Advance address and decrease remaining length
               read_burst_addr <= read_burst_addr + DATA_WIDTH / 8;
               read_burst_remaining <= read_burst_remaining - 1;

               // If the data to be served is the last,
               // set r_last to high
               if (read_burst_remaining == 1) begin
                  s_nasti.r_last <= 1;
               end
            end
         end
         else if(!pending_read) begin
            pending_read <= 1;
            pending_read_data <= bram_rddata;
         end
      end
      else if (s_nasti.w_ready) begin
         // Write state

         if (s_nasti.w_valid) begin
            if (s_nasti.w_last) begin
               s_nasti.w_ready <= 0;

               // Transition to write complete state
               s_nasti.b_valid <= 1;
            end
            else begin
               // Advance address and decrease remaining length
               write_burst_addr <= write_burst_addr + DATA_WIDTH / 8;
               write_burst_remaining <= write_burst_remaining - 1;
            end
         end
      end
      else if (s_nasti.b_valid) begin
         // Write complete state

         if (s_nasti.b_ready) begin
            s_nasti.b_valid <= 0;

            // Transition to idle state
            a_ready <= 1;
         end
      end
      else begin
         // Transition to idle state otherwise
         a_ready <= 1;
      end
   end

endmodule
