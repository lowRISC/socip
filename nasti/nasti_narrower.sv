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
    nasti_channel master,
    nasti_channel slave
    );

   initial begin
      assert(MASTER_DATA_WIDTH >= SLAVE_DATA_WIDTH)
        else $fatal(1, "master bus cannot be narrower than the slave bus!");
   end

   nasti_narrower_writer
     #(
       .ID_WIDTH          ( ID_WIDTH          ),
       .ADDR_WIDTH        ( ADDR_WIDTH        ),
       .MASTER_DATA_WIDTH ( MASTER_DATA_WIDTH ),
       .SLAVE_DATA_WIDTH  ( SLAVE_DATA_WIDTH  ),
       .USER_WIDTH        ( USER_WIDTH        )
       )
   writer
     (
      .*,
      .master_aw_id     ( master.aw_id     ),
      .master_aw_addr   ( master.aw_addr   ),
      .master_aw_len    ( master.aw_len    ),
      .master_aw_size   ( master.aw_size   ),
      .master_aw_burst  ( master.aw_burst  ),
      .master_aw_lock   ( master.aw_lock   ),
      .master_aw_cache  ( master.aw_cache  ),
      .master_aw_prot   ( master.aw_prot   ),
      .master_aw_qos    ( master.aw_qos    ),
      .master_aw_region ( master.aw_region ),
      .master_aw_user   ( master.aw_user   ),
      .master_aw_valid  ( master.aw_valid  ),
      .master_aw_ready  ( master.aw_ready  ),
      .master_w_data    ( master.w_data    ),
      .master_w_strb    ( master.w_strb    ),
      .master_w_last    ( master.w_last    ),
      .master_w_user    ( master.w_user    ),
      .master_w_valid   ( master.w_valid   ),
      .master_w_ready   ( master.w_ready   ),
      .master_b_id      ( master.b_id      ),
      .master_b_resp    ( master.b_resp    ),
      .master_b_user    ( master.b_user    ),
      .master_b_valid   ( master.b_valid   ),
      .master_b_ready   ( master.b_ready   ),
      .slave_aw_id      ( slave.aw_id      ),
      .slave_aw_addr    ( slave.aw_addr    ),
      .slave_aw_len     ( slave.aw_len     ),
      .slave_aw_size    ( slave.aw_size    ),
      .slave_aw_burst   ( slave.aw_burst   ),
      .slave_aw_lock    ( slave.aw_lock    ),
      .slave_aw_cache   ( slave.aw_cache   ),
      .slave_aw_prot    ( slave.aw_prot    ),
      .slave_aw_qos     ( slave.aw_qos     ),
      .slave_aw_region  ( slave.aw_region  ),
      .slave_aw_user    ( slave.aw_user    ),
      .slave_aw_valid   ( slave.aw_valid   ),
      .slave_aw_ready   ( slave.aw_ready   ),
      .slave_w_data     ( slave.w_data     ),
      .slave_w_strb     ( slave.w_strb     ),
      .slave_w_last     ( slave.w_last     ),
      .slave_w_user     ( slave.w_user     ),
      .slave_w_valid    ( slave.w_valid    ),
      .slave_w_ready    ( slave.w_ready    ),
      .slave_b_id       ( slave.b_id       ),
      .slave_b_resp     ( slave.b_resp     ),
      .slave_b_user     ( slave.b_user     ),
      .slave_b_valid    ( slave.b_valid    ),
      .slave_b_ready    ( slave.b_ready    )
      );

   nasti_narrower_reader
     #(
       .ID_WIDTH          ( ID_WIDTH          ),
       .ADDR_WIDTH        ( ADDR_WIDTH        ),
       .MASTER_DATA_WIDTH ( MASTER_DATA_WIDTH ),
       .SLAVE_DATA_WIDTH  ( SLAVE_DATA_WIDTH  ),
       .USER_WIDTH        ( USER_WIDTH        )
       )
   reader
     (
      .*,
      .master_ar_id     ( master.ar_id     ),
      .master_ar_addr   ( master.ar_addr   ),
      .master_ar_len    ( master.ar_len    ),
      .master_ar_size   ( master.ar_size   ),
      .master_ar_burst  ( master.ar_burst  ),
      .master_ar_lock   ( master.ar_lock   ),
      .master_ar_cache  ( master.ar_cache  ),
      .master_ar_prot   ( master.ar_prot   ),
      .master_ar_qos    ( master.ar_qos    ),
      .master_ar_region ( master.ar_region ),
      .master_ar_user   ( master.ar_user   ),
      .master_ar_valid  ( master.ar_valid  ),
      .master_ar_ready  ( master.ar_ready  ),
      .master_r_id      ( master.r_id      ),
      .master_r_data    ( master.r_data    ),
      .master_r_resp    ( master.r_resp    ),
      .master_r_last    ( master.r_last    ),
      .master_r_user    ( master.r_user    ),
      .master_r_valid   ( master.r_valid   ),
      .master_r_ready   ( master.r_ready   ),
      .slave_ar_id      ( slave.ar_id      ),
      .slave_ar_addr    ( slave.ar_addr    ),
      .slave_ar_len     ( slave.ar_len     ),
      .slave_ar_size    ( slave.ar_size    ),
      .slave_ar_burst   ( slave.ar_burst   ),
      .slave_ar_lock    ( slave.ar_lock    ),
      .slave_ar_cache   ( slave.ar_cache   ),
      .slave_ar_prot    ( slave.ar_prot    ),
      .slave_ar_qos     ( slave.ar_qos     ),
      .slave_ar_region  ( slave.ar_region  ),
      .slave_ar_user    ( slave.ar_user    ),
      .slave_ar_valid   ( slave.ar_valid   ),
      .slave_ar_ready   ( slave.ar_ready   ),
      .slave_r_id       ( slave.r_id       ),
      .slave_r_data     ( slave.r_data     ),
      .slave_r_resp     ( slave.r_resp     ),
      .slave_r_last     ( slave.r_last     ),
      .slave_r_user     ( slave.r_user     ),
      .slave_r_valid    ( slave.r_valid    ),
      .slave_r_ready    ( slave.r_ready    )
      );

endmodule // nasti_narrower
