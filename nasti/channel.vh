// See LICENSE for license details.

// Define the SV interfaces for NASTI channels

`ifndef NASTI_CHANNEL_VH
 `define NASTI_CHANNEL_VH

interface nasti_aw
  #(
    ID_WIDTH = 1,
    ADDR_WIDTH = 8,
    USER_WIDTH = 1
    );
   logic [ID_WIDTH-1:0]   id;
   logic [ADDR_WIDTH-1:0] addr;
   logic [7:0]            len;
   logic [2:0]            size;
   logic [1:0]            burst;
   logic                  lock;
   logic [3:0]            cache;
   logic [2:0]            prot;
   logic [3:0]            qos;
   logic [3:0]            region;
   logic [USER_WIDTH-1:0] user;
   logic                  valid;
   logic                  ready;
endinterface // nasti_wa

interface nasti_w
  #(
    DATA_WIDTH = 8,
    USER_WIDTH = 1
    );
   logic [DATA_WIDTH-1:0]   data;
   logic [DATA_WIDTH/8-1:0] strb;
   logic                    last;
   logic [USER_WIDTH-1:0]   user;
   logic                    valid;
   logic                    ready;
endinterface // nasti_w

interface nasti_b
  #(
    ID_WIDTH = 1,
    USER_WIDTH = 1
    );
   logic [ID_WIDTH-1:0]   id;
   logic [1:0]            resp;
   logic [USER_WIDTH-1:0] user;
   logic                  valid;
   logic                  ready;
endinterface // nasti_b

interface nasti_ar
  #(
    ID_WIDTH = 1,
    ADDR_WIDTH = 8,
    USER_WIDTH = 1
    );
   logic [ID_WIDTH-1:0]   id;
   logic [ADDR_WIDTH-1:0] addr;
   logic [7:0]            len;
   logic [2:0]            size;
   logic [1:0]            burst;
   logic                  lock;
   logic [3:0]            cache;
   logic [2:0]            prot;
   logic [3:0]            qos;
   logic [3:0]            region;
   logic [USER_WIDTH-1:0] user;
   logic                  valid;
   logic                  ready;
endinterface // nasti_ar

interface nasti_r
  #(
    ID_WIDTH = 1,
    DATA_WIDTH = 8,
    USER_WIDTH = 1
    );
   logic [ID_WIDTH-1:0]   id;
   logic [DATA_WIDTH-1:0] data;
   logic [1:0]            resp;
   logic                  last;
   logic [USER_WIDTH-1:0] user;
   logic                  valid;
   logic                  ready;
endinterface // nasti_r

`endif
