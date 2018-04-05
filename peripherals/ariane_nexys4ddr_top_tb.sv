// See LICENSE for license details.
`timescale 1ns/1ps

//`define FPGA_FULL
//`define ADD_PHY_DDR
`define NEXYS4

module tb;

   logic clk, rst, tck_i, trstn_i, tms_i, tdi_i, tdo_o;

   tracer_t tracer;

   ariane_nexys4ddr DUT
     (
      .*,
      .clk_p        ( clk       ),
      .clk_n        ( !clk      ),
      .rst_top      ( !rst      )         // NEXYS4's cpu_reset is active low
      );

    assign glbl.JTAG_TMS_GLBL = 1'b0;
    assign glbl.JTAG_TCK_GLBL = 1'b0;
    assign glbl.JTAG_TDI_GLBL = 1'b0;
    assign glbl.JTAG_TRST_GLBL = 1'b0;

initial
    begin
    glbl.JTAG_RESET_GLBL = 1'b1;
    glbl.JTAG_SHIFT_GLBL = 1'b0;
    glbl.JTAG_UPDATE_GLBL = 1'b0;
    glbl.JTAG_CAPTURE_GLBL = 1'b0;
    glbl.JTAG_RUNTEST_GLBL = 1'b0;
    force glbl.JTAG_TRST_GLBL = 1'b1;       
    forever
        begin
        #1000
           force glbl.JTAG_TCK_GLBL = 1'b1;
        #1000
           release glbl.JTAG_TCK_GLBL;
        #1000
           force glbl.JTAG_TCK_GLBL = 1'b1;
        #1000
           release glbl.JTAG_TCK_GLBL;
           release glbl.JTAG_TRST_GLBL;
           glbl.JTAG_RESET_GLBL = 1'b0;
        end
    end

   initial begin
      rst = 1;
      #130;
      rst = 0;
   end

   initial begin
      clk = 0;
      forever clk = #5 !clk;
   end // initial begin

   wire [15:0]  ddr_dq;
   wire [1:0]   ddr_dqs_n;
   wire [1:0]   ddr_dqs_p;
   logic [12:0] ddr_addr;
   logic [2:0]  ddr_ba;
   logic        ddr_ras_n;
   logic        ddr_cas_n;
   logic        ddr_we_n;
   logic        ddr_ck_p;
   logic        ddr_ck_n;
   logic        ddr_cke;
   logic        ddr_cs_n;
   wire [1:0]   ddr_dm;
   logic        ddr_odt;

   // behavioural DDR2 RAM
   ddr2_model u_comp_ddr2
     (
      .ck      ( ddr_ck_p        ),
      .ck_n    ( ddr_ck_n        ),
      .cke     ( ddr_cke         ),
      .cs_n    ( ddr_cs_n        ),
      .ras_n   ( ddr_ras_n       ),
      .cas_n   ( ddr_cas_n       ),
      .we_n    ( ddr_we_n        ),
      .dm_rdqs ( ddr_dm          ),
      .ba      ( ddr_ba          ),
      .addr    ( ddr_addr        ),
      .dq      ( ddr_dq          ),
      .dqs     ( ddr_dqs_p       ),
      .dqs_n   ( ddr_dqs_n       ),
      .rdqs_n  (                 ),
      .odt     ( ddr_odt         )
      );

   wire         rxd;
   wire         txd;
   wire         rts;
   wire         cts;

   assign rxd = 'b1;
   assign cts = 'b1;

reg u_trans;
reg [15:0] u_baud;
wire received, recv_err, is_recv, is_trans, u_tx, u_rx;
wire [7:0] u_rx_byte;
reg  [7:0] u_tx_byte;

   assign u_trans = received;
   assign u_tx_byte = u_rx_byte;
   assign u_baud = 16'd52;
   assign u_rx = txd;
   
uart i_uart(
    .clk(clk), // The master clock for this module
    .rst(rst), // Synchronous reset.
    .rx(u_rx), // Incoming serial line
    .tx(u_tx), // Outgoing serial line
    .transmit(u_trans), // Signal to transmit
    .tx_byte(u_tx_byte), // Byte to transmit
    .received(received), // Indicated that a byte has been received.
    .rx_byte(u_rx_byte), // Byte received
    .is_receiving(is_recv), // Low when receive line is idle.
    .is_transmitting(is_trans), // Low when transmit line is idle.
    .recv_error(recv_err), // Indicates error in receiving packet.
    .baud(u_baud),
    .recv_ack(received)
    );

   // 4-bit full SD interface
   wire         sd_sclk;
   wire         sd_detect = 1'b0; // Simulate SD-card always there
   wire [3:0]   sd_dat_to_host;
   wire         sd_cmd_to_host;
   wire         sd_reset, oeCmd, oeDat;
   wand [3:0]   sd_dat = oeDat ? sd_dat_to_host : 4'b1111;
   wand         sd_cmd = oeCmd ? sd_cmd_to_host : 4'b1;

sd_verilator_model sdflash1 (
             .sdClk(sd_sclk),
             .cmd(sd_cmd),
             .cmdOut(sd_cmd_to_host),
             .dat(sd_dat),
             .datOut(sd_dat_to_host),
             .oeCmd(oeCmd),
             .oeDat(oeDat)
);

   // LED and DIP switch
   wire [7:0]   o_led;
   wire [15:0]   i_dip;

   assign i_dip = 16'h1;

   // push button array
   wire         GPIO_SW_C;
   wire         GPIO_SW_W;
   wire         GPIO_SW_E;
   wire         GPIO_SW_N;
   wire         GPIO_SW_S;

   assign GPIO_SW_C = 'b1;
   assign GPIO_SW_W = 'b1;
   assign GPIO_SW_E = 'b1;
   assign GPIO_SW_N = 'b1;
   assign GPIO_SW_S = 'b1;

   //keyboard
   wire         PS2_CLK;
   wire         PS2_DATA;

   assign PS2_CLK = 'bz;
   assign PS2_DATA = 'bz;

  // display
   wire        VGA_HS_O;
   wire        VGA_VS_O;
   wire [3:0]  VGA_RED_O;
   wire [3:0]  VGA_BLUE_O;
   wire [3:0]  VGA_GREEN_O;

   string      dumpname;
   
   // vcd
   initial
     begin
     if ($value$plusargs("vcd=%s", dumpname))
       begin
         $dumpfile(dumpname);
         $dumpvars(0, tb.DUT.i_ariane);
         $dumpvars(0, tb.DUT.i_master0);
         $dumpvars(0, tb.DUT.i_master1);
         $dumpvars(0, tb.DUT.i_master_behav);
         $dumpon;
       end
     if ($value$plusargs("vpd=%s", dumpname))
       begin
         $vcdplusfile(dumpname);
         $vcdpluson;
       end
     end // initial begin
   
  wire         o_erefclk; // RMII clock out
  wire [1:0]   i_erxd ;
  wire         i_erx_dv ;
  wire         i_erx_er ;
  wire         i_emdint ;
  wire [1:0]   o_etxd ;
  wire         o_etx_en ;
  wire         o_emdc ;
  wire         io_emdio ;
  wire         o_erstn ;

   assign i_emdint = 1'b1;
   assign i_erx_dv = o_etx_en;
   assign i_erxd = o_etxd;
   assign i_erx_er = 1'b0;
 
   assign trstn_i = !rst;
   assign tck_i = 'b0;
   assign tms_i = 1'b0;
   assign tdi_i = 'b0;
   
    string s;
    int f;
    logic [63:0] cycles;

    import "DPI-C" function int pipe_init(input string s);
   
    import "DPI-C" function int pipe27(
                        input longint arg1, input longint arg2, input longint arg3, input longint arg4, input longint arg5, 
                        input longint arg6, input longint arg7, input longint arg8, input longint arg9, input longint arg10, 
                        input longint arg11, input longint arg12, input longint arg13, input longint arg14, input longint arg15, 
                        input longint arg16, input longint arg17, input longint arg18, input longint arg19, input longint arg20, 
                        input longint arg21, input longint arg22, input longint arg23, input longint arg24, input longint arg25,
                        input longint arg26, input longint arg27);

    function fdisplay27(int f);

      begin
         if (f == -1)
           begin
              pipe27(tracer.rstn, tracer.commit_ack, tracer.commit_instr.pc, tracer.commit_instr.ex.tval[31:0], tracer.exception.valid, 
                     tracer.commit_instr.ex.cause, tracer.flush_unissued, tracer.flush, tracer.instruction[31:0], tracer.fetch_valid, 
                     tracer.fetch_ack, tracer.issue_ack, tracer.waddr, tracer.wdata, tracer.we, 
                     tracer.commit_ack, tracer.st_valid, tracer.paddr, tracer.ld_valid, tracer.ld_kill, 
                     tracer.priv_lvl, tracer.raddr_a_i, tracer.rdata_a_o, tracer.raddr_b_i,
                     tracer.rdata_b_o, tracer.waddr_a_i, tracer.wdata_a_i);
`ifdef VERBOSE              
           if (tracer.commit_ack)
             $display("%0h (%h) %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                     tracer.commit_instr.pc, tracer.commit_instr.ex.tval[31:0], tracer.exception.valid, 
                     tracer.commit_instr.ex.cause, tracer.flush_unissued, tracer.flush, tracer.instruction, tracer.fetch_valid, 
                     tracer.fetch_ack, tracer.issue_ack, tracer.waddr, tracer.wdata, tracer.we, 
                     tracer.commit_ack, tracer.st_valid, tracer.paddr, tracer.ld_valid, tracer.ld_kill, 
                     tracer.priv_lvl, tracer.raddr_a_i, tracer.rdata_a_o, tracer.raddr_b_i,
                     tracer.rdata_b_o, tracer.waddr_a_i, tracer.wdata_a_i);
`endif     
           end
         else
           begin
           if (!tracer.rstn)
              cycles <= 0;
           else
             begin
                if (tracer.commit_ack) 
                  $fdisplay(f, "%d %0h (%h) %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h",
                            cycles, tracer.commit_instr.pc, tracer.commit_instr.ex.tval[31:0], tracer.exception.valid, 
                            tracer.commit_instr.ex.cause, tracer.flush_unissued, tracer.flush, tracer.instruction, tracer.fetch_valid, 
                            tracer.fetch_ack, tracer.issue_ack, tracer.waddr, tracer.wdata, tracer.we, 
                            tracer.commit_ack, tracer.st_valid, tracer.paddr, tracer.ld_valid, tracer.ld_kill, 
                            tracer.priv_lvl, tracer.raddr_a_i, tracer.rdata_a_o, tracer.raddr_b_i,
                            tracer.rdata_b_o, tracer.waddr_a_i, tracer.wdata_a_i);
                cycles <= cycles + 1;
             end // else: !if(arg1)
           end
      end

    endfunction // fdisplay27
   
    initial begin
       if ($test$plusargs("pipe"))
         begin
            if ($value$plusargs("readmemh=%s", s))
              pipe_init(s);
            else
              pipe_init("cnvmem64.hex");
         f = -1;
         end
       else if ($value$plusargs("trace=%s", s))
         f = $fopen(s, "w");
       else
         f = $fopen("trace_core_00_0.dasm", "w");
    end

    always_ff @(posedge clk) begin
       fdisplay27(f);
    end

    final begin
        if (f != -1)
          $fclose(f);
    end

endmodule // tb
