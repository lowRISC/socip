
module dualmem_630K_1260(clk, din, addr, we, dout, en);

   input wire                clk;
   input wire [1259:0]       din;
   input wire [8:0]          addr;
   input wire                we;
   input wire                en;
   output wire [1259:0]      dout;

   genvar r;

`ifdef FPGA

`ifdef FPGACAPTURE512

   generate for (r = 0; r < 35; r=r+1)
     RAMB16_S36
     RAMB16_S36_inst
       (
        .CLK    ( clk                      ),     // Port A Clock
        .DO     ( dout[r*36 +: 32]         ),     // Port A 1-bit Data Output
        .DOP    ( dout[r*36+32 +: 4]       ),
        .ADDR   ( addr                     ),     // Port A 9-bit Address Input
        .DI     ( din[r*36 +: 32]          ),     // Port A 1-bit Data Input
        .DIP    ( din[r*36+32 +: 4]        ),
        .EN     ( en                       ),     // Port A RAM Enable Input
        .SSR    ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WE     ( we                       )      // Port A Write Enable Input
        );
   endgenerate

`else

   wire [1295:0]      dinw, doutw;

   assign dout = doutw[1259:0];
   assign dinw = din[1259:0];
   
   generate for (r = 0; r < 18; r=r+1)
     RAMB16_S36_S36
     RAMB16_S36_S36_inst
       (
        .CLKA   ( clk                      ),     // Port A Clock
        .DOA    ( doutw[r*72 +: 32]         ),     // Port A 1-bit Data Output
        .DOPA   ( doutw[r*72+32 +: 4]       ),
        .ADDRA  ( {1'b0,addr[7:0]}         ),     // Port A 9-bit Address Input
        .DIA    ( dinw[r*72 +: 32]          ),     // Port A 1-bit Data Input
        .DIPA   ( dinw[r*72+32 +: 4]        ),
        .ENA    ( en                       ),     // Port A RAM Enable Input
        .SSRA   ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WEA    ( we & !addr[8]            ),     // Port A Write Enable Input
        .CLKB   ( clk                      ),     // Port B Clock
        .DOB    ( doutw[r*72+36 +: 32]      ),     // Port B 1-bit Data Output
        .DOPB   ( doutw[r*72+68 +: 4]       ),
        .ADDRB  ( {1'b1,addr[7:0]}         ),     // Port A 9-bit Address Input
        .DIB    ( dinw[r*72+36 +: 32]       ),     // Port B 1-bit Data Input
        .DIPB   ( dinw[r*72+68 +: 4]        ),
        .ENB    ( en                       ),     // Port B RAM Enable Input
        .SSRB   ( 1'b0                     ),     // Port B Synchronous Set/Reset Input
        .WEB    ( we & !addr[8]            )      // Port B Write Enable Input
        );
   endgenerate

`endif

`else // !`ifdef FPGA

logic [7:0] uncon;
   
infer_bram #(.BRAM_SIZE(9), .BYTE_WIDTH(158)) ram1 // RAM_SIZE is in words
(
.ram_clk(clk),
.ram_en(en),
.ram_we({158{we}}),
.ram_addr(addr),
.ram_wrdata({4'b0,din}),
.ram_rddata({uncon[7:4],dout})
 );
   
`endif
   
endmodule // dualmem
