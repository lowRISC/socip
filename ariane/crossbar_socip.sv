// See LICENSE for license details.
// The terms master and slave are not very useful in this file.

module crossbar_socip
  #(
    ID_WIDTH = 10,              // id width
    ADDR_WIDTH = 64,            // address width
    DATA_WIDTH = 64,            // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not in use
    LITE_MODE = 0               // whether work in Lite mode
    )
  (
   // clock and reset
   AXI_BUS.Slave slave0_if, slave1_if, slave2_if, slave3_if, slave4_if,
   AXI_BUS.Master master0_if, master1_if, master2_if, master3_if,
   input         clk_i,
   input         rst_ni
   );

   localparam NUM_MASTER = 5;
   localparam NUM_SLAVE = 4;

   nasti_channel
     #(
       .ID_WIDTH    ( ID_WIDTH      ),
       .USER_WIDTH  ( USER_WIDTH    ),
       .ADDR_WIDTH  ( ADDR_WIDTH    ),
       .DATA_WIDTH  ( DATA_WIDTH    ))
   slave0_nasti(), slave1_nasti(), slave2_nasti(), slave3_nasti(), slave4_nasti(),
   master0_nasti(), master1_nasti(), master2_nasti(), master3_nasti(), master4_nasti();

   // input of the IO crossbar
   nasti_channel
     #(
       .N_PORT      ( NUM_MASTER    ),
       .ID_WIDTH    ( ID_WIDTH      ),
       .USER_WIDTH  ( USER_WIDTH    ),
       .ADDR_WIDTH  ( ADDR_WIDTH    ),
       .DATA_WIDTH  ( DATA_WIDTH    ))
   master_nasti();

   nasti_channel mem_dmm5(), mem_dmm6(), mem_dmm7(); // dummy channels
   
   nasti_channel_combiner #(NUM_MASTER)
   mem_combiner (
                  .master_0  ( master0_nasti ),
                  .master_1  ( master1_nasti ),
                  .master_2  ( master2_nasti ),
                  .master_3  ( master3_nasti ),
                  .master_4  ( master4_nasti ),
                  .master_5  ( mem_dmm5      ),
                  .master_6  ( mem_dmm6      ),
                  .master_7  ( mem_dmm7      ),
                  .slave     ( master_nasti  )
                  );

   // output of the IO crossbar
   nasti_channel
     #(
       .N_PORT      ( NUM_SLAVE     ),
       .ID_WIDTH    ( ID_WIDTH      ),
       .USER_WIDTH  ( USER_WIDTH    ),
       .ADDR_WIDTH  ( ADDR_WIDTH    ),
       .DATA_WIDTH  ( DATA_WIDTH    ))
   combined_nasti();

   nasti_crossbar
     #(
       .N_INPUT       ( NUM_MASTER            ),
       .N_OUTPUT      ( NUM_SLAVE             ),
       .IB_DEPTH      ( 0                     ),
       .OB_DEPTH      ( 1                     ),
       .W_MAX         ( 1                     ),
       .R_MAX         ( 1                     ),
       .ID_WIDTH      ( ID_WIDTH              ),
       .ADDR_WIDTH    ( ADDR_WIDTH            ),
       .DATA_WIDTH    ( DATA_WIDTH            ),
       .ESCAPE_ENABLE ( 0                     ), // to cascade on slave0
       .BASE0         ( 32'h41000000          ),
       .MASK0         ( 32'h00FFFFFF          ),
       .BASE1         ( 32'h40000000          ),
       .MASK1         ( 32'h00FFFFFF          ),
       .BASE2         ( 32'h80000000          ),
       .MASK2         ( 32'h07FFFFFF          ),
       .BASE3         ( 32'h42000000          ),
       .MASK3         ( 32'h0000FFFF          ),
       .LITE_MODE     ( 0                     )
       )
   mem_crossbar
     (
      .clk    ( clk_i            ),
      .rstn   ( rst_ni           ),
      .master ( master_nasti     ),
      .slave  ( combined_nasti   )
      );

   nasti_channel mem_dms4(), mem_dms5(), mem_dms6(), mem_dms7(); // dummy channels

   nasti_channel_slicer #(NUM_SLAVE)
   mem_slicer (
                  .master   ( combined_nasti ),
                  .slave_0  ( slave0_nasti   ),
                  .slave_1  ( slave1_nasti   ),
                  .slave_2  ( slave2_nasti   ),
                  .slave_3  ( slave3_nasti   ),
                  .slave_4  ( mem_dms4       ),
                  .slave_5  ( mem_dms5       ),
                  .slave_6  ( mem_dms6       ),
                  .slave_7  ( mem_dms7       )
                  );

   nasti_converter #(
    .ID_WIDTH(ID_WIDTH),               // id width
    .ADDR_WIDTH(ADDR_WIDTH),             // address width
    .DATA_WIDTH(DATA_WIDTH),             // width of data
    .USER_WIDTH(USER_WIDTH)              // width of user field, must > 0, let synthesizer trim it if not in use
    ) cnvi(.incoming_if(slave0_if), .outgoing_nasti(master0_nasti)),
      cnvd(.incoming_if(slave1_if), .outgoing_nasti(master1_nasti)),
      cnvb(.incoming_if(slave2_if), .outgoing_nasti(master2_nasti)),
      cnvg(.incoming_if(slave3_if), .outgoing_nasti(master3_nasti)),
      cnvo(.incoming_if(slave4_if), .outgoing_nasti(master4_nasti));

   if_converter #(
    .ID_WIDTH(ID_WIDTH),               // id width
    .ADDR_WIDTH(ADDR_WIDTH),             // address width
    .DATA_WIDTH(DATA_WIDTH),             // width of data
    .USER_WIDTH(USER_WIDTH)              // width of user field, must > 0, let synthesizer trim it if not in use
    ) cnv0(.incoming_nasti(slave0_nasti), .outgoing_if(master0_if)),
      cnv1(.incoming_nasti(slave1_nasti), .outgoing_if(master1_if)),
      cnv2(.incoming_nasti(slave2_nasti), .outgoing_if(master2_if)),
      cnv3(.incoming_nasti(slave3_nasti), .outgoing_if(master3_if));
   
endmodule // crossbar_socip
