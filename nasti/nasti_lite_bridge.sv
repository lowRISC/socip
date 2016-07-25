// See LICENSE for license details.

// bridge for NASTI/NASTI-Lite conversion

module nasti_lite_bridge
  #(
    WRITE_TRANSACTION = 2,      // maximal number of parallel write transactions
    READ_TRANSACTION = 2,       // maximal number of parallel read transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    NASTI_DATA_WIDTH = 64,      // width of data on the nasti side
    LITE_DATA_WIDTH = 32,       // width of data on the nasti-lite side
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input clk, rstn,
    nasti_channel nasti_master,
    nasti_channel lite_slave
    );

   nasti_lite_writer
     #(
       .MAX_TRANSACTION  ( WRITE_TRANSACTION  ),
       .ID_WIDTH         ( ID_WIDTH           ),
       .ADDR_WIDTH       ( ADDR_WIDTH         ),
       .NASTI_DATA_WIDTH ( NASTI_DATA_WIDTH   ),
       .LITE_DATA_WIDTH  ( LITE_DATA_WIDTH    ),
       .USER_WIDTH       ( USER_WIDTH         )
       )
   writer
     (
      .*,
      .nasti_aw_id     ( nasti_master.aw_id     ),
      .nasti_aw_addr   ( nasti_master.aw_addr   ),
      .nasti_aw_len    ( nasti_master.aw_len    ),
      .nasti_aw_size   ( nasti_master.aw_size   ),
      .nasti_aw_burst  ( nasti_master.aw_burst  ),
      .nasti_aw_lock   ( nasti_master.aw_lock   ),
      .nasti_aw_cache  ( nasti_master.aw_cache  ),
      .nasti_aw_prot   ( nasti_master.aw_prot   ),
      .nasti_aw_qos    ( nasti_master.aw_qos    ),
      .nasti_aw_region ( nasti_master.aw_region ),
      .nasti_aw_user   ( nasti_master.aw_user   ),
      .nasti_aw_valid  ( nasti_master.aw_valid  ),
      .nasti_aw_ready  ( nasti_master.aw_ready  ),
      .nasti_w_data    ( nasti_master.w_data    ),
      .nasti_w_strb    ( nasti_master.w_strb    ),
      .nasti_w_last    ( nasti_master.w_last    ),
      .nasti_w_user    ( nasti_master.w_user    ),
      .nasti_w_valid   ( nasti_master.w_valid   ),
      .nasti_w_ready   ( nasti_master.w_ready   ),
      .nasti_b_id      ( nasti_master.b_id      ),
      .nasti_b_resp    ( nasti_master.b_resp    ),
      .nasti_b_user    ( nasti_master.b_user    ),
      .nasti_b_valid   ( nasti_master.b_valid   ),
      .nasti_b_ready   ( nasti_master.b_ready   ),
      .lite_aw_id      ( lite_slave.aw_id      ),
      .lite_aw_addr    ( lite_slave.aw_addr    ),
      .lite_aw_prot    ( lite_slave.aw_prot    ),
      .lite_aw_qos     ( lite_slave.aw_qos     ),
      .lite_aw_region  ( lite_slave.aw_region  ),
      .lite_aw_user    ( lite_slave.aw_user    ),
      .lite_aw_valid   ( lite_slave.aw_valid   ),
      .lite_aw_ready   ( lite_slave.aw_ready   ),
      .lite_w_data     ( lite_slave.w_data     ),
      .lite_w_strb     ( lite_slave.w_strb     ),
      .lite_w_user     ( lite_slave.w_user     ),
      .lite_w_valid    ( lite_slave.w_valid    ),
      .lite_w_ready    ( lite_slave.w_ready    ),
      .lite_b_id       ( lite_slave.b_id       ),
      .lite_b_resp     ( lite_slave.b_resp     ),
      .lite_b_user     ( lite_slave.b_user     ),
      .lite_b_valid    ( lite_slave.b_valid    ),
      .lite_b_ready    ( lite_slave.b_ready    )
      );

   nasti_lite_reader
     #(
       .MAX_TRANSACTION  ( READ_TRANSACTION   ),
       .ID_WIDTH         ( ID_WIDTH           ),
       .ADDR_WIDTH       ( ADDR_WIDTH         ),
       .NASTI_DATA_WIDTH ( NASTI_DATA_WIDTH   ),
       .LITE_DATA_WIDTH  ( LITE_DATA_WIDTH    ),
       .USER_WIDTH       ( USER_WIDTH         )
       )
   reader
     (
      .*,
      .nasti_ar_id     ( nasti_master.ar_id     ),
      .nasti_ar_addr   ( nasti_master.ar_addr   ),
      .nasti_ar_len    ( nasti_master.ar_len    ),
      .nasti_ar_size   ( nasti_master.ar_size   ),
      .nasti_ar_burst  ( nasti_master.ar_burst  ),
      .nasti_ar_lock   ( nasti_master.ar_lock   ),
      .nasti_ar_cache  ( nasti_master.ar_cache  ),
      .nasti_ar_prot   ( nasti_master.ar_prot   ),
      .nasti_ar_qos    ( nasti_master.ar_qos    ),
      .nasti_ar_region ( nasti_master.ar_region ),
      .nasti_ar_user   ( nasti_master.ar_user   ),
      .nasti_ar_valid  ( nasti_master.ar_valid  ),
      .nasti_ar_ready  ( nasti_master.ar_ready  ),
      .nasti_r_id      ( nasti_master.r_id      ),
      .nasti_r_data    ( nasti_master.r_data    ),
      .nasti_r_resp    ( nasti_master.r_resp    ),
      .nasti_r_last    ( nasti_master.r_last    ),
      .nasti_r_user    ( nasti_master.r_user    ),
      .nasti_r_valid   ( nasti_master.r_valid   ),
      .nasti_r_ready   ( nasti_master.r_ready   ),
      .lite_ar_id      ( lite_slave.ar_id       ),
      .lite_ar_addr    ( lite_slave.ar_addr     ),
      .lite_ar_prot    ( lite_slave.ar_prot     ),
      .lite_ar_qos     ( lite_slave.ar_qos      ),
      .lite_ar_region  ( lite_slave.ar_region   ),
      .lite_ar_user    ( lite_slave.ar_user     ),
      .lite_ar_valid   ( lite_slave.ar_valid    ),
      .lite_ar_ready   ( lite_slave.ar_ready    ),
      .lite_r_id       ( lite_slave.r_id        ),
      .lite_r_data     ( lite_slave.r_data      ),
      .lite_r_resp     ( lite_slave.r_resp      ),
      .lite_r_user     ( lite_slave.r_user      ),
      .lite_r_valid    ( lite_slave.r_valid     ),
      .lite_r_ready    ( lite_slave.r_ready     )
      );

endmodule // nasti_lite_bridge

module lite_nasti_bridge
  #(
    WRITE_TRANSACTION = 2,      // maximal number of parallel write transactions
    READ_TRANSACTION = 2,       // maximal number of parallel read transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    NASTI_DATA_WIDTH = 64,      // width of data on the nasti side
    LITE_DATA_WIDTH = 32,       // width of data on the nasti-lite side
    USER_WIDTH = 1              // width of user field, must > 0, let synthesizer trim it if not in use
    )
   (
    input clk, rstn,
    nasti_channel lite_master,
    nasti_channel nasti_slave
    );

   lite_nasti_writer
     #(
       .MAX_TRANSACTION  ( WRITE_TRANSACTION  ),
       .ID_WIDTH         ( ID_WIDTH           ),
       .ADDR_WIDTH       ( ADDR_WIDTH         ),
       .NASTI_DATA_WIDTH ( NASTI_DATA_WIDTH   ),
       .LITE_DATA_WIDTH  ( LITE_DATA_WIDTH    ),
       .USER_WIDTH       ( USER_WIDTH         )
       )
   writer
     (
      .*,
      .lite_aw_id      ( lite_master.aw_id      ),
      .lite_aw_addr    ( lite_master.aw_addr    ),
      .lite_aw_prot    ( lite_master.aw_prot    ),
      .lite_aw_qos     ( lite_master.aw_qos     ),
      .lite_aw_region  ( lite_master.aw_region  ),
      .lite_aw_user    ( lite_master.aw_user    ),
      .lite_aw_valid   ( lite_master.aw_valid   ),
      .lite_aw_ready   ( lite_master.aw_ready   ),
      .lite_w_data     ( lite_master.w_data     ),
      .lite_w_strb     ( lite_master.w_strb     ),
      .lite_w_user     ( lite_master.w_user     ),
      .lite_w_valid    ( lite_master.w_valid    ),
      .lite_w_ready    ( lite_master.w_ready    ),
      .lite_b_id       ( lite_master.b_id       ),
      .lite_b_resp     ( lite_master.b_resp     ),
      .lite_b_user     ( lite_master.b_user     ),
      .lite_b_valid    ( lite_master.b_valid    ),
      .lite_b_ready    ( lite_master.b_ready    ),
      .nasti_aw_id     ( nasti_slave.aw_id     ),
      .nasti_aw_addr   ( nasti_slave.aw_addr   ),
      .nasti_aw_len    ( nasti_slave.aw_len    ),
      .nasti_aw_size   ( nasti_slave.aw_size   ),
      .nasti_aw_burst  ( nasti_slave.aw_burst  ),
      .nasti_aw_lock   ( nasti_slave.aw_lock   ),
      .nasti_aw_cache  ( nasti_slave.aw_cache  ),
      .nasti_aw_prot   ( nasti_slave.aw_prot   ),
      .nasti_aw_qos    ( nasti_slave.aw_qos    ),
      .nasti_aw_region ( nasti_slave.aw_region ),
      .nasti_aw_user   ( nasti_slave.aw_user   ),
      .nasti_aw_valid  ( nasti_slave.aw_valid  ),
      .nasti_aw_ready  ( nasti_slave.aw_ready  ),
      .nasti_w_data    ( nasti_slave.w_data    ),
      .nasti_w_strb    ( nasti_slave.w_strb    ),
      .nasti_w_last    ( nasti_slave.w_last    ),
      .nasti_w_user    ( nasti_slave.w_user    ),
      .nasti_w_valid   ( nasti_slave.w_valid   ),
      .nasti_w_ready   ( nasti_slave.w_ready   ),
      .nasti_b_id      ( nasti_slave.b_id      ),
      .nasti_b_resp    ( nasti_slave.b_resp    ),
      .nasti_b_user    ( nasti_slave.b_user    ),
      .nasti_b_valid   ( nasti_slave.b_valid   ),
      .nasti_b_ready   ( nasti_slave.b_ready   )
      );

   lite_nasti_reader
     #(
       .MAX_TRANSACTION  ( READ_TRANSACTION   ),
       .ID_WIDTH         ( ID_WIDTH           ),
       .ADDR_WIDTH       ( ADDR_WIDTH         ),
       .NASTI_DATA_WIDTH ( NASTI_DATA_WIDTH   ),
       .LITE_DATA_WIDTH  ( LITE_DATA_WIDTH    ),
       .USER_WIDTH       ( USER_WIDTH         )
       )
   reader
     (
      .*,
      .lite_ar_id      ( lite_master.ar_id      ),
      .lite_ar_addr    ( lite_master.ar_addr    ),
      .lite_ar_prot    ( lite_master.ar_prot    ),
      .lite_ar_qos     ( lite_master.ar_qos     ),
      .lite_ar_region  ( lite_master.ar_region  ),
      .lite_ar_user    ( lite_master.ar_user    ),
      .lite_ar_valid   ( lite_master.ar_valid   ),
      .lite_ar_ready   ( lite_master.ar_ready   ),
      .lite_r_id       ( lite_master.r_id       ),
      .lite_r_data     ( lite_master.r_data     ),
      .lite_r_resp     ( lite_master.r_resp     ),
      .lite_r_user     ( lite_master.r_user     ),
      .lite_r_valid    ( lite_master.r_valid    ),
      .lite_r_ready    ( lite_master.r_ready    ),
      .nasti_ar_id     ( nasti_slave.ar_id      ),
      .nasti_ar_addr   ( nasti_slave.ar_addr    ),
      .nasti_ar_len    ( nasti_slave.ar_len     ),
      .nasti_ar_size   ( nasti_slave.ar_size    ),
      .nasti_ar_burst  ( nasti_slave.ar_burst   ),
      .nasti_ar_lock   ( nasti_slave.ar_lock    ),
      .nasti_ar_cache  ( nasti_slave.ar_cache   ),
      .nasti_ar_prot   ( nasti_slave.ar_prot    ),
      .nasti_ar_qos    ( nasti_slave.ar_qos     ),
      .nasti_ar_region ( nasti_slave.ar_region  ),
      .nasti_ar_user   ( nasti_slave.ar_user    ),
      .nasti_ar_valid  ( nasti_slave.ar_valid   ),
      .nasti_ar_ready  ( nasti_slave.ar_ready   ),
      .nasti_r_id      ( nasti_slave.r_id       ),
      .nasti_r_data    ( nasti_slave.r_data     ),
      .nasti_r_resp    ( nasti_slave.r_resp     ),
      .nasti_r_last    ( nasti_slave.r_last     ),
      .nasti_r_user    ( nasti_slave.r_user     ),
      .nasti_r_valid   ( nasti_slave.r_valid    ),
      .nasti_r_ready   ( nasti_slave.r_ready    )
      );

endmodule // lite_nasti_bridge
