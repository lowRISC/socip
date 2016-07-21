// See LICENSE for license details.

// shrink the width of data channel
// non-parallel

module nasti_narrower
  #(
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    MASTER_DATA_WIDTH = 64,     // width of data on the master side
    SLAVE_DATA_WIDTH = 64,      // width of data on the slave side
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input clk, rstn,
    nasti_channel nasti_m,
    nasti_channel nasti_s    
    );

   initial begin
      assert(MASTER_DATA_WIDTH >= SLAVE_DATA_WIDTH)
        else $fatal(1, "master bus cannot be narrower than the slave bus!");
   end

   nasti_narrower_writer
     #(
       .ID_WIDTH          ( ID_WIDTH           ),
       .ADDR_WIDTH        ( ADDR_WIDTH         ),
       .MASTER_DATA_WIDTH ( MASTER_DATA_WIDTH  ),
       .SLAVE_DATA_WIDTH  ( SLAVE_DATA_WIDTH   ),
       .USER_WIDTH        ( USER_WIDTH         )
       )
   writer
     (
      .*,
      .master_aw_id     ( nasti_m.aw_id     ),
      .master_aw_addr   ( nasti_m.aw_addr   ),
      .master_aw_len    ( nasti_m.aw_len    ),
      .master_aw_size   ( nasti_m.aw_size   ),
      .master_aw_burst  ( nasti_m.aw_burst  ),
      .master_aw_lock   ( nasti_m.aw_lock   ),
      .master_aw_cache  ( nasti_m.aw_cache  ),
      .master_aw_prot   ( nasti_m.aw_prot   ),
      .master_aw_qos    ( nasti_m.aw_qos    ),
      .master_aw_region ( nasti_m.aw_region ),
      .master_aw_user   ( nasti_m.aw_user   ),
      .master_aw_valid  ( nasti_m.aw_valid  ),
      .master_aw_ready  ( nasti_m.aw_ready  ),
      .master_w_data    ( nasti_m.w_data    ),
      .master_w_strb    ( nasti_m.w_strb    ),
      .master_w_last    ( nasti_m.w_last    ),
      .master_w_user    ( nasti_m.w_user    ),
      .master_w_valid   ( nasti_m.w_valid   ),
      .master_w_ready   ( nasti_m.w_ready   ),
      .master_b_id      ( nasti_m.b_id      ),
      .master_b_resp    ( nasti_m.b_resp    ),
      .master_b_user    ( nasti_m.b_user    ),
      .master_b_valid   ( nasti_m.b_valid   ),
      .master_b_ready   ( nasti_m.b_ready   ),
      .slave_aw_id      ( nasti_s.aw_id     ),
      .slave_aw_addr    ( nasti_s.aw_addr   ),
      .slave_aw_len     ( nasti_s.aw_len    ),
      .slave_aw_size    ( nasti_s.aw_size   ),
      .slave_aw_burst   ( nasti_s.aw_burst  ),
      .slave_aw_lock    ( nasti_s.aw_lock   ),
      .slave_aw_cache   ( nasti_s.aw_cache  ),
      .slave_aw_prot    ( nasti_s.aw_prot   ),
      .slave_aw_qos     ( nasti_s.aw_qos    ),
      .slave_aw_region  ( nasti_s.aw_region ),
      .slave_aw_user    ( nasti_s.aw_user   ),
      .slave_aw_valid   ( nasti_s.aw_valid  ),
      .slave_aw_ready   ( nasti_s.aw_ready  ),
      .slave_w_data     ( nasti_s.w_data    ),
      .slave_w_strb     ( nasti_s.w_strb    ),
      .slave_w_last     ( nasti_s.w_last    ),
      .slave_w_user     ( nasti_s.w_user    ),
      .slave_w_valid    ( nasti_s.w_valid   ),
      .slave_w_ready    ( nasti_s.w_ready   ),
      .slave_b_id       ( nasti_s.b_id      ),
      .slave_b_resp     ( nasti_s.b_resp    ),
      .slave_b_user     ( nasti_s.b_user    ),
      .slave_b_valid    ( nasti_s.b_valid   ),
      .slave_b_ready    ( nasti_s.b_ready   )
      );

   nasti_narrower_reader
     #(
       .ID_WIDTH          ( ID_WIDTH           ),
       .ADDR_WIDTH        ( ADDR_WIDTH         ),
       .MASTER_DATA_WIDTH ( MASTER_DATA_WIDTH  ),
       .SLAVE_DATA_WIDTH  ( SLAVE_DATA_WIDTH   ),
       .USER_WIDTH        ( USER_WIDTH         )
       )
   reader
     (
      .*,
      .master_ar_id     ( nasti_m.ar_id     ),
      .master_ar_addr   ( nasti_m.ar_addr   ),
      .master_ar_len    ( nasti_m.ar_len    ),
      .master_ar_size   ( nasti_m.ar_size   ),
      .master_ar_burst  ( nasti_m.ar_burst  ),
      .master_ar_lock   ( nasti_m.ar_lock   ),
      .master_ar_cache  ( nasti_m.ar_cache  ),
      .master_ar_prot   ( nasti_m.ar_prot   ),
      .master_ar_qos    ( nasti_m.ar_qos    ),
      .master_ar_region ( nasti_m.ar_region ),
      .master_ar_user   ( nasti_m.ar_user   ),
      .master_ar_valid  ( nasti_m.ar_valid  ),
      .master_ar_ready  ( nasti_m.ar_ready  ),
      .master_r_id      ( nasti_m.r_id      ),
      .master_r_data    ( nasti_m.r_data    ),
      .master_r_resp    ( nasti_m.r_resp    ),
      .master_r_last    ( nasti_m.r_last    ),
      .master_r_user    ( nasti_m.r_user    ),
      .master_r_valid   ( nasti_m.r_valid   ),
      .master_r_ready   ( nasti_m.r_ready   ),
      .slave_ar_id      ( nasti_s.ar_id     ),
      .slave_ar_addr    ( nasti_s.ar_addr   ),
      .slave_ar_len     ( nasti_s.ar_len    ),
      .slave_ar_size    ( nasti_s.ar_size   ),
      .slave_ar_burst   ( nasti_s.ar_burst  ),
      .slave_ar_lock    ( nasti_s.ar_lock   ),
      .slave_ar_cache   ( nasti_s.ar_cache  ),
      .slave_ar_prot    ( nasti_s.ar_prot   ),
      .slave_ar_qos     ( nasti_s.ar_qos    ),
      .slave_ar_region  ( nasti_s.ar_region ),
      .slave_ar_user    ( nasti_s.ar_user   ),
      .slave_ar_valid   ( nasti_s.ar_valid  ),
      .slave_ar_ready   ( nasti_s.ar_ready  ),
      .slave_r_id       ( nasti_s.r_id      ),
      .slave_r_data     ( nasti_s.r_data    ),
      .slave_r_resp     ( nasti_s.r_resp    ),
      .slave_r_last     ( nasti_s.r_last    ),
      .slave_r_user     ( nasti_s.r_user    ),
      .slave_r_valid    ( nasti_s.r_valid   ),
      .slave_r_ready    ( nasti_s.r_ready   )
      );

endmodule // nasti_narrower
