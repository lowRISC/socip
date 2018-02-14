module nasti_data_mover # (
   parameter ADDR_WIDTH = 64,
   parameter DATA_WIDTH = 64
) (
   input  aclk,
   input  aresetn,
   nasti_channel.master src,
   nasti_channel.master dest,
   input  [ADDR_WIDTH-1:0] src_addr,
   input  [ADDR_WIDTH-1:0] dest_addr,
   input  [ADDR_WIDTH-1:0] length,
   input  en,
   output bit done
);

   localparam ADDR_SHIFT = $clog2(DATA_WIDTH / 8);

   // Unused fields, connect to constants
   assign src.ar_id = 0;
   assign src.ar_size = 3'b011;
   assign src.ar_burst = 2'b01;
   assign src.ar_cache = 4'b0;
   assign src.ar_prot = 3'b0;
   assign src.ar_lock = 1'b0;

   assign dest.aw_id = 0;
   assign dest.aw_size = 3'b011;
   assign dest.aw_burst = 2'b01;
   assign dest.aw_cache = 4'b0;
   assign dest.aw_prot = 3'b0;
   assign dest.aw_lock = 1'b0;

   // Note: if data mover is only used in one direction
   // Use the following code to make sure the device
   // will not be affected by x's
   //
   // assign src.aw_valid = 0;
   // assign src.w_valid = 0;
   // assign src.b_ready = 0;
   //
   // assign dest.ar_valid = 0;
   // assign dest.r_ready = 0;
   // assign dest.b_ready = 0;

   // Connect dest.w to src.r directly
   // Note that a read error is not considered here
   assign dest.w_strb = 8'b11111111;
   assign dest.w_valid = src.r_valid;
   assign dest.w_data   = src.r_data;
   assign dest.w_last   = src.r_last;
   assign src.r_ready = dest.w_ready;

   // Once the task is started, these values shouldn't be changed from outside the module,
   // so latch it
   bit [63:0] src_addr_latch, dest_addr_latch, length_latch;
   bit en_latch;

   bit state_addr, state_wait, state_ready;
   bit src_ready, dest_ready;

   // Whether address will be ready for next cycle
   bit src_to_be_ready, dest_to_be_ready;
   always_comb src_to_be_ready = src.ar_ready & src.ar_valid;
   always_comb dest_to_be_ready = dest.aw_ready & dest.aw_valid;

   always_ff @(posedge aclk or negedge aresetn) begin
      if (!aresetn) begin
         en_latch <= 0;
         done <= 1;
      end
      else if (!en_latch) begin
         if (en) begin
            // Latch input
            state_addr     <= 1;
            en_latch    <= 1;
            src_addr_latch <= src_addr;
            dest_addr_latch <= dest_addr;
            length_latch   <= length;
            done        <= 0;
         end
      end
      else if (en_latch) begin
         case (1'b1)
            state_addr: begin
               src.ar_addr   <= {src_addr_latch[ADDR_WIDTH-1:ADDR_SHIFT], 3'b0};
               src.ar_valid  <= 1;
               dest.aw_addr  <= {dest_addr_latch[ADDR_WIDTH-1:ADDR_SHIFT], 3'b0};
               dest.aw_valid <= 1;

               if ((length >> ADDR_SHIFT) > 256) begin
                  // Max burst length is 256
                  src.ar_len     <= 255;
                  dest.aw_len    <= 255;
                  length_latch   <= length_latch - (256 << ADDR_SHIFT);
                  src_addr_latch <= src_addr_latch + (256 << ADDR_SHIFT);
                  dest_addr_latch <= dest_addr_latch + (256 << ADDR_SHIFT);
               end
               else begin
                  src.ar_len   <= (length >> ADDR_SHIFT) -1;
                  dest.aw_len  <= (length >> ADDR_SHIFT) -1;
                  length_latch <= 0;
               end

               src_ready <= 0;
               dest_ready <= 0;

               // Transition to wait state
               state_addr <= 0;
               state_wait <= 1;
            end
            state_wait: begin
               if (src_to_be_ready) begin
                  src.ar_valid <= 0;
                  src_ready    <= 1;
               end
               if (dest_to_be_ready) begin
                  dest.aw_valid <= 0;
                  dest_ready    <= 1;
               end
               if ((src_ready || src_to_be_ready) && (dest_ready || dest_to_be_ready)) begin
                  state_wait   <= 0;
                  state_ready  <= 1;
                  dest.b_ready <= 1;
               end
            end
            state_ready: begin
               if (dest.b_valid) begin
                  dest.b_ready <= 0;
                  if (length_latch == 0) begin
                     en_latch <= 0;
                     done   <= 1;
                  end
                  else begin
                     state_ready <= 0;
                     state_addr  <= 1;
                  end
               end
            end
         endcase
      end
   end

endmodule
