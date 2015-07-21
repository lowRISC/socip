// See LICENSE for license details.

// Define the SV interfaces for NASTI channels

`ifndef NASTI_CHANNEL_VH
 `define NASTI_CHANNEL_VH

`define MAX_NASTI_ID_WIDTH 16
`define MAX_NASTI_ADDR_WIDTH 64
`define MAX_NASTI_DATA_WIDTH 256
`define MAX_NASTI_USER_WIDTH 8


interface nasti_aw;
   logic [`MAX_NASTI_ID_WIDTH-1:0]     id;
   logic [`MAX_NASTI_ADDR_WIDTH-1:0]   addr;
   logic [7:0]                         len;
   logic [2:0]                         size;
   logic [1:0]                         burst;
   logic [3:0]                         cache;
   logic [2:0]                         prot;
   logic [3:0]                         qos;
   logic [3:0]                         region;
   logic [`MAX_NASTI_USER_WIDTH-1:0]   user;
   logic                               valid;
   logic                               ready;
endinterface // nasti_wa

interface nasti_w;
   logic [`MAX_NASTI_DATA_WIDTH-1:0]   data;
   logic [`MAX_NASTI_DATA_WIDTH/8-1:0] strb;
   logic                               last;
   logic [`MAX_NASTI_USER_WIDTH-1:0]   user;
   logic                               valid;
   logic                               ready;
endinterface // nasti_w

interface nasti_b;
   logic [`MAX_NASTI_ID_WIDTH-1:0]     id;
   logic [1:0]                         resp;
   logic [`MAX_NASTI_USER_WIDTH-1:0]   user;
   logic                               valid;
   logic                               ready;
endinterface // nasti_b

interface nasti_ar;
   logic [`MAX_NASTI_ID_WIDTH-1:0]     id;
   logic [`MAX_NASTI_ADDR_WIDTH-1:0]   addr;
   logic [7:0]                         len;
   logic [2:0]                         size;
   logic [1:0]                         burst;
   logic [3:0]                         cache;
   logic [2:0]                         prot;
   logic [3:0]                         qos;
   logic [3:0]                         region;
   logic [`MAX_NASTI_USER_WIDTH-1:0]   user;
   logic                               valid;
   logic                               ready;
endinterface // nasti_ar

interface nasti_r;
   logic [`MAX_NASTI_ID_WIDTH-1:0]     id;
   logic [`MAX_NASTI_DATA_WIDTH-1:0]   data;
   logic [1:0]                         resp;
   logic                               last;
   logic [`MAX_NASTI_USER_WIDTH-1:0]   user;
   logic                               valid;
   logic                               ready;
endinterface // nasti_r

`endif
