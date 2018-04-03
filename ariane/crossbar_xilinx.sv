module crossbar_xilinx(
                       AXI_BUS.Slave slave0_if, slave1_if, slave2_if, slave3_if, slave4_if,
                       AXI_BUS.Master master0_if, master1_if, master2_if, master3_if,
                       input clk_i, rst_ni
                       );
  
axi_crossbar_0 crossbar (
  .aclk(clk_i),                      // input wire aclk
  .aresetn(rst_ni),                // input wire aresetn
  .s_axi_awid({slave4_if.aw_id,slave3_if.aw_id,slave2_if.aw_id,slave1_if.aw_id,slave0_if.aw_id}),          // input wire [29 : 0] s_axi_awid
  .s_axi_awaddr({slave4_if.aw_addr,slave3_if.aw_addr,slave2_if.aw_addr,slave1_if.aw_addr,slave0_if.aw_addr}),      // input wire [191 : 0] s_axi_awaddr
  .s_axi_awlen({slave4_if.aw_len,slave3_if.aw_len,slave2_if.aw_len,slave1_if.aw_len,slave0_if.aw_len}),        // input wire [23 : 0] s_axi_awlen
  .s_axi_awsize({slave4_if.aw_size,slave3_if.aw_size,slave2_if.aw_size,slave1_if.aw_size,slave0_if.aw_size}),      // input wire [8 : 0] s_axi_awsize
  .s_axi_awburst({slave4_if.aw_burst,slave3_if.aw_burst,slave2_if.aw_burst,slave1_if.aw_burst,slave0_if.aw_burst}),    // input wire [5 : 0] s_axi_awburst
  .s_axi_awlock({slave4_if.aw_lock,slave3_if.aw_lock,slave2_if.aw_lock,slave1_if.aw_lock,slave0_if.aw_lock}),      // input wire [2 : 0] s_axi_awlock
  .s_axi_awcache({slave4_if.aw_cache,slave3_if.aw_cache,slave2_if.aw_cache,slave1_if.aw_cache,slave0_if.aw_cache}),    // input wire [11 : 0] s_axi_awcache
  .s_axi_awprot({slave4_if.aw_prot,slave3_if.aw_prot,slave2_if.aw_prot,slave1_if.aw_prot,slave0_if.aw_prot}),      // input wire [8 : 0] s_axi_awprot
  .s_axi_awqos({slave4_if.aw_qos,slave3_if.aw_qos,slave2_if.aw_qos,slave1_if.aw_qos,slave0_if.aw_qos}),        // input wire [11 : 0] s_axi_awqos
  .s_axi_awuser({slave4_if.aw_user,slave3_if.aw_user,slave2_if.aw_user,slave1_if.aw_user,slave0_if.aw_user}),      // input wire [2 : 0] s_axi_awuser
  .s_axi_awvalid({slave4_if.aw_valid,slave3_if.aw_valid,slave2_if.aw_valid,slave1_if.aw_valid,slave0_if.aw_valid}),    // input wire [2 : 0] s_axi_awvalid
  .s_axi_awready({slave4_if.aw_ready,slave3_if.aw_ready,slave2_if.aw_ready,slave1_if.aw_ready,slave0_if.aw_ready}),    // output wire [2 : 0] s_axi_awready
  .s_axi_wdata({slave4_if.w_data,slave3_if.w_data,slave2_if.w_data,slave1_if.w_data,slave0_if.w_data}),        // input wire [191 : 0] s_axi_wdata
  .s_axi_wstrb({slave4_if.w_strb,slave3_if.w_strb,slave2_if.w_strb,slave1_if.w_strb,slave0_if.w_strb}),        // input wire [23 : 0] s_axi_wstrb
  .s_axi_wlast({slave4_if.w_last,slave3_if.w_last,slave2_if.w_last,slave1_if.w_last,slave0_if.w_last}),        // input wire [2 : 0] s_axi_wlast
  .s_axi_wuser({slave4_if.w_user,slave3_if.w_user,slave2_if.w_user,slave1_if.w_user,slave0_if.w_user}),        // input wire [2 : 0] s_axi_wuser
  .s_axi_wvalid({slave4_if.w_valid,slave3_if.w_valid,slave2_if.w_valid,slave1_if.w_valid,slave0_if.w_valid}),      // input wire [2 : 0] s_axi_wvalid
  .s_axi_wready({slave4_if.w_ready,slave3_if.w_ready,slave2_if.w_ready,slave1_if.w_ready,slave0_if.w_ready}),      // output wire [2 : 0] s_axi_wready
  .s_axi_bid({slave4_if.b_id,slave3_if.b_id,slave2_if.b_id,slave1_if.b_id,slave0_if.b_id}),            // output wire [29 : 0] s_axi_bid
  .s_axi_bresp({slave4_if.b_resp,slave3_if.b_resp,slave2_if.b_resp,slave1_if.b_resp,slave0_if.b_resp}),        // output wire [5 : 0] s_axi_bresp
  .s_axi_buser({slave4_if.b_user,slave3_if.b_user,slave2_if.b_user,slave1_if.b_user,slave0_if.b_user}),        // output wire [2 : 0] s_axi_buser
  .s_axi_bvalid({slave4_if.b_valid,slave3_if.b_valid,slave2_if.b_valid,slave1_if.b_valid,slave0_if.b_valid}),      // output wire [2 : 0] s_axi_bvalid
  .s_axi_bready({slave4_if.b_ready,slave3_if.b_ready,slave2_if.b_ready,slave1_if.b_ready,slave0_if.b_ready}),      // input wire [2 : 0] s_axi_bready
  .s_axi_arid({slave4_if.ar_id,slave3_if.ar_id,slave2_if.ar_id,slave1_if.ar_id,slave0_if.ar_id}),          // input wire [29 : 0] s_axi_arid
  .s_axi_araddr({slave4_if.ar_addr,slave3_if.ar_addr,slave2_if.ar_addr,slave1_if.ar_addr,slave0_if.ar_addr}),      // input wire [191 : 0] s_axi_araddr
  .s_axi_arlen({slave4_if.ar_len,slave3_if.ar_len,slave2_if.ar_len,slave1_if.ar_len,slave0_if.ar_len}),        // input wire [23 : 0] s_axi_arlen
  .s_axi_arsize({slave4_if.ar_size,slave3_if.ar_size,slave2_if.ar_size,slave1_if.ar_size,slave0_if.ar_size}),      // input wire [8 : 0] s_axi_arsize
  .s_axi_arburst({slave4_if.ar_burst,slave3_if.ar_burst,slave2_if.ar_burst,slave1_if.ar_burst,slave0_if.ar_burst}),    // input wire [5 : 0] s_axi_arburst
  .s_axi_arlock({slave4_if.ar_lock,slave3_if.ar_lock,slave2_if.ar_lock,slave1_if.ar_lock,slave0_if.ar_lock}),      // input wire [2 : 0] s_axi_arlock
  .s_axi_arcache({slave4_if.ar_cache,slave3_if.ar_cache,slave2_if.ar_cache,slave1_if.ar_cache,slave0_if.ar_cache}),    // input wire [11 : 0] s_axi_arcache
  .s_axi_arprot({slave4_if.ar_prot,slave3_if.ar_prot,slave2_if.ar_prot,slave1_if.ar_prot,slave0_if.ar_prot}),      // input wire [8 : 0] s_axi_arprot
  .s_axi_arqos({slave4_if.ar_qos,slave3_if.ar_qos,slave2_if.ar_qos,slave1_if.ar_qos,slave0_if.ar_qos}),        // input wire [11 : 0] s_axi_arqos
  .s_axi_aruser({slave4_if.ar_user,slave3_if.ar_user,slave2_if.ar_user,slave1_if.ar_user,slave0_if.ar_user}),      // input wire [2 : 0] s_axi_aruser
  .s_axi_arvalid({slave4_if.ar_valid,slave3_if.ar_valid,slave2_if.ar_valid,slave1_if.ar_valid,slave0_if.ar_valid}),    // input wire [2 : 0] s_axi_arvalid
  .s_axi_arready({slave4_if.ar_ready,slave3_if.ar_ready,slave2_if.ar_ready,slave1_if.ar_ready,slave0_if.ar_ready}),    // output wire [2 : 0] s_axi_arready
  .s_axi_rid({slave4_if.r_id,slave3_if.r_id,slave2_if.r_id,slave1_if.r_id,slave0_if.r_id}),            // output wire [29 : 0] s_axi_rid
  .s_axi_rdata({slave4_if.r_data,slave3_if.r_data,slave2_if.r_data,slave1_if.r_data,slave0_if.r_data}),        // output wire [191 : 0] s_axi_rdata
  .s_axi_rresp({slave4_if.r_resp,slave3_if.r_resp,slave2_if.r_resp,slave1_if.r_resp,slave0_if.r_resp}),        // output wire [5 : 0] s_axi_rresp
  .s_axi_rlast({slave4_if.r_last,slave3_if.r_last,slave2_if.r_last,slave1_if.r_last,slave0_if.r_last}),        // output wire [2 : 0] s_axi_rlast
  .s_axi_ruser({slave4_if.r_user,slave3_if.r_user,slave2_if.r_user,slave1_if.r_user,slave0_if.r_user}),        // output wire [2 : 0] s_axi_ruser
  .s_axi_rvalid({slave4_if.r_valid,slave3_if.r_valid,slave2_if.r_valid,slave1_if.r_valid,slave0_if.r_valid}),      // output wire [2 : 0] s_axi_rvalid
  .s_axi_rready({slave4_if.r_ready,slave3_if.r_ready,slave2_if.r_ready,slave1_if.r_ready,slave0_if.r_ready}),      // input wire [2 : 0] s_axi_rready
  .m_axi_awid({master3_if.aw_id,master2_if.aw_id,master1_if.aw_id,master0_if.aw_id}),          // input wire [29 : 0] s_axi_awid
  .m_axi_awaddr({master3_if.aw_addr,master2_if.aw_addr,master1_if.aw_addr,master0_if.aw_addr}),      // input wire [191 : 0] s_axi_awaddr
  .m_axi_awlen({master3_if.aw_len,master2_if.aw_len,master1_if.aw_len,master0_if.aw_len}),        // input wire [23 : 0] s_axi_awlen
  .m_axi_awsize({master3_if.aw_size,master2_if.aw_size,master1_if.aw_size,master0_if.aw_size}),      // input wire [8 : 0] s_axi_awsize
  .m_axi_awburst({master3_if.aw_burst,master2_if.aw_burst,master1_if.aw_burst,master0_if.aw_burst}),    // input wire [5 : 0] s_axi_awburst
  .m_axi_awlock({master3_if.aw_lock,master2_if.aw_lock,master1_if.aw_lock,master0_if.aw_lock}),      // input wire [2 : 0] s_axi_awlock
  .m_axi_awcache({master3_if.aw_cache,master2_if.aw_cache,master1_if.aw_cache,master0_if.aw_cache}),    // input wire [11 : 0] s_axi_awcache
  .m_axi_awprot({master3_if.aw_prot,master2_if.aw_prot,master1_if.aw_prot,master0_if.aw_prot}),      // input wire [8 : 0] s_axi_awprot
  .m_axi_awqos({master3_if.aw_qos,master2_if.aw_qos,master1_if.aw_qos,master0_if.aw_qos}),        // input wire [11 : 0] s_axi_awqos
  .m_axi_awuser({master3_if.aw_user,master2_if.aw_user,master1_if.aw_user,master0_if.aw_user}),      // input wire [2 : 0] s_axi_awuser
  .m_axi_awvalid({master3_if.aw_valid,master2_if.aw_valid,master1_if.aw_valid,master0_if.aw_valid}),    // input wire [2 : 0] s_axi_awvalid
  .m_axi_awready({master3_if.aw_ready,master2_if.aw_ready,master1_if.aw_ready,master0_if.aw_ready}),    // output wire [2 : 0] s_axi_awready
  .m_axi_awregion({master3_if.aw_region,master2_if.aw_region,master1_if.aw_region,master0_if.aw_region}),    // output s_axi_awregion
  .m_axi_wdata({master3_if.w_data,master2_if.w_data,master1_if.w_data,master0_if.w_data}),        // input wire [191 : 0] s_axi_wdata
  .m_axi_wstrb({master3_if.w_strb,master2_if.w_strb,master1_if.w_strb,master0_if.w_strb}),        // input wire [23 : 0] s_axi_wstrb
  .m_axi_wlast({master3_if.w_last,master2_if.w_last,master1_if.w_last,master0_if.w_last}),        // input wire [2 : 0] s_axi_wlast
  .m_axi_wuser({master3_if.w_user,master2_if.w_user,master1_if.w_user,master0_if.w_user}),        // input wire [2 : 0] s_axi_wuser
  .m_axi_wvalid({master3_if.w_valid,master2_if.w_valid,master1_if.w_valid,master0_if.w_valid}),      // input wire [2 : 0] s_axi_wvalid
  .m_axi_wready({master3_if.w_ready,master2_if.w_ready,master1_if.w_ready,master0_if.w_ready}),      // output wire [2 : 0] s_axi_wready
  .m_axi_bid({master3_if.b_id,master2_if.b_id,master1_if.b_id,master0_if.b_id}),            // output wire [29 : 0] s_axi_bid
  .m_axi_bresp({master3_if.b_resp,master2_if.b_resp,master1_if.b_resp,master0_if.b_resp}),        // output wire [5 : 0] s_axi_bresp
  .m_axi_buser({master3_if.b_user,master2_if.b_user,master1_if.b_user,master0_if.b_user}),        // output wire [2 : 0] s_axi_buser
  .m_axi_bvalid({master3_if.b_valid,master2_if.b_valid,master1_if.b_valid,master0_if.b_valid}),      // output wire [2 : 0] s_axi_bvalid
  .m_axi_bready({master3_if.b_ready,master2_if.b_ready,master1_if.b_ready,master0_if.b_ready}),      // input wire [2 : 0] s_axi_bready
  .m_axi_arid({master3_if.ar_id,master2_if.ar_id,master1_if.ar_id,master0_if.ar_id}),          // input wire [29 : 0] s_axi_arid
  .m_axi_araddr({master3_if.ar_addr,master2_if.ar_addr,master1_if.ar_addr,master0_if.ar_addr}),      // input wire [191 : 0] s_axi_araddr
  .m_axi_arlen({master3_if.ar_len,master2_if.ar_len,master1_if.ar_len,master0_if.ar_len}),        // input wire [23 : 0] s_axi_arlen
  .m_axi_arsize({master3_if.ar_size,master2_if.ar_size,master1_if.ar_size,master0_if.ar_size}),      // input wire [8 : 0] s_axi_arsize
  .m_axi_arburst({master3_if.ar_burst,master2_if.ar_burst,master1_if.ar_burst,master0_if.ar_burst}),    // input wire [5 : 0] s_axi_arburst
  .m_axi_arlock({master3_if.ar_lock,master2_if.ar_lock,master1_if.ar_lock,master0_if.ar_lock}),      // input wire [2 : 0] s_axi_arlock
  .m_axi_arcache({master3_if.ar_cache,master2_if.ar_cache,master1_if.ar_cache,master0_if.ar_cache}),    // input wire [11 : 0] s_axi_arcache
  .m_axi_arprot({master3_if.ar_prot,master2_if.ar_prot,master1_if.ar_prot,master0_if.ar_prot}),      // input wire [8 : 0] s_axi_arprot
  .m_axi_arqos({master3_if.ar_qos,master2_if.ar_qos,master1_if.ar_qos,master0_if.ar_qos}),        // input wire [11 : 0] s_axi_arqos
  .m_axi_aruser({master3_if.ar_user,master2_if.ar_user,master1_if.ar_user,master0_if.ar_user}),      // input wire [2 : 0] s_axi_aruser
  .m_axi_arvalid({master3_if.ar_valid,master2_if.ar_valid,master1_if.ar_valid,master0_if.ar_valid}),    // input wire [2 : 0] s_axi_arvalid
  .m_axi_arready({master3_if.ar_ready,master2_if.ar_ready,master1_if.ar_ready,master0_if.ar_ready}),    // output wire [2 : 0] s_axi_arready
  .m_axi_arregion({master3_if.ar_region,master2_if.ar_region,master1_if.ar_region,master0_if.ar_region}),    // output s_axi_arregion
  .m_axi_rid({master3_if.r_id,master2_if.r_id,master1_if.r_id,master0_if.r_id}),            // output wire [29 : 0] s_axi_rid
  .m_axi_rdata({master3_if.r_data,master2_if.r_data,master1_if.r_data,master0_if.r_data}),        // output wire [191 : 0] s_axi_rdata
  .m_axi_rresp({master3_if.r_resp,master2_if.r_resp,master1_if.r_resp,master0_if.r_resp}),        // output wire [5 : 0] s_axi_rresp
  .m_axi_rlast({master3_if.r_last,master2_if.r_last,master1_if.r_last,master0_if.r_last}),        // output wire [2 : 0] s_axi_rlast
  .m_axi_ruser({master3_if.r_user,master2_if.r_user,master1_if.r_user,master0_if.r_user}),        // output wire [2 : 0] s_axi_ruser
  .m_axi_rvalid({master3_if.r_valid,master2_if.r_valid,master1_if.r_valid,master0_if.r_valid}),      // output wire [2 : 0] s_axi_rvalid
  .m_axi_rready({master3_if.r_ready,master2_if.r_ready,master1_if.r_ready,master0_if.r_ready})      // input wire [2 : 0] s_axi_rready
);

endmodule
