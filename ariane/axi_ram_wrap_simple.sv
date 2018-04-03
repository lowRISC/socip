module axi_ram_wrap_simple #(
    AXI_ID_WIDTH = 10,               // id width
    AXI_ADDR_WIDTH = 64,             // address width
    AXI_DATA_WIDTH = 64,             // width of data
    AXI_USER_WIDTH = 1,              // width of user field, must > 0, let synthesizer trim it if not in use
    MEM_ADDR_WIDTH = 13
    )
(
AXI_BUS.Slave slave,
input clk_i, rst_ni,
output wire [AXI_DATA_WIDTH/8-1 : 0] bram_we_a,
output wire [MEM_ADDR_WIDTH-1 : 0] bram_addr_a,
output wire [AXI_DATA_WIDTH-1 : 0] bram_wrdata_a,
input  wire [AXI_DATA_WIDTH-1 : 0] bram_rddata_a,
output wire          bram_rst_a, bram_clk_a, bram_en_a
);

    logic        data_req;
    logic [63:0] data_address;
    logic        data_we;
    logic [7:0]  data_be;
    logic [63:0] data_wdata;
    logic [63:0] data_rdata;

axi2mem #(
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH      ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH    ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH    ),
        .AXI_USER_WIDTH ( AXI_USER_WIDTH    )
    ) i_data (
        .clk_i  ( clk_i        ),
        .rst_ni ( rst_ni       ),
        .slave  ( slave        ),
        .req_o  ( data_req     ),
        .we_o   ( data_we      ),
        .addr_o ( data_address ),
        .be_o   ( data_be      ),
        .data_o ( data_wdata   ),
        .data_i ( data_rdata   )
    );

   assign bram_we_a = data_we ? data_be : 'b0;
   assign bram_addr_a = data_address;
   assign bram_wrdata_a = data_wdata;
   assign data_rdata = bram_rddata_a;
   assign bram_rst_a = !rst_ni;
   assign bram_clk_a = clk_i;
   assign bram_en_a = |data_be;
   
endmodule
