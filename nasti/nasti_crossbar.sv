// See LICENSE for license details.

// up to 8x8 slave ports
module nasti_crossbar
  #(
    IB_DEPTH = 0,               // input buffer depth
    OB_DEPTH = 0,               // output buffer depth
    W_MAX = 2,                  // maximal parallel write transactions
    R_MAX = 2,                  // maximal parallel read transactions
    ID_WIDTH = 1,               // id width
    ADDR_WIDTH = 8,             // address width
    DATA_WIDTH = 8,             // width of data
    USER_WIDTH = 1,             // width of user field, must > 0, let synthesizer trim it if not
    [ADDR_WIDTH-1:0] BASE0 = 0, // base address for port 0
    [ADDR_WIDTH-1:0] BASE1 = 0, // base address for port 1
    [ADDR_WIDTH-1:0] BASE2 = 0, // base address for port 2
    [ADDR_WIDTH-1:0] BASE3 = 0, // base address for port 3
    [ADDR_WIDTH-1:0] BASE4 = 0, // base address for port 4
    [ADDR_WIDTH-1:0] BASE5 = 0, // base address for port 5
    [ADDR_WIDTH-1:0] BASE6 = 0, // base address for port 6
    [ADDR_WIDTH-1:0] BASE7 = 0, // base address for port 7
    [ADDR_WIDTH-1:0] MASK0 = 0, // address mask for port 0
    [ADDR_WIDTH-1:0] MASK1 = 0, // address mask for port 1
    [ADDR_WIDTH-1:0] MASK2 = 0, // address mask for port 2
    [ADDR_WIDTH-1:0] MASK3 = 0, // address mask for port 3
    [ADDR_WIDTH-1:0] MASK4 = 0, // address mask for port 4
    [ADDR_WIDTH-1:0] MASK5 = 0, // address mask for port 5
    [ADDR_WIDTH-1:0] MASK6 = 0, // address mask for port 6
    [ADDR_WIDTH-1:0] MASK7 = 0  // address mask for port 7
    )
   (
    input clk, rstn,
    nasti_channel.slave  s,
    nasti_channel.master m
    );



endmodule // nasti_crossbar

    
    
