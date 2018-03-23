
module dualmem_512K_64(clka, clkb, dina, dinb, addra, addrb, wea, web, douta, doutb, ena, enb);

   input wire clka, clkb;
   input [63:0] dina;
   input [63:0] dinb;
   input [10:0] addra;
   input [10:0] addrb;
   input [7:0]        wea;
   input [7:0]        web;
   input [7:0]        ena, enb;
   output [63:0]      douta;
   output [63:0]      doutb;

   genvar r;

`ifdef FPGA
   
   generate for (r = 0; r < 32; r=r+1)
     RAMB16_S2_S2
     RAMB16_S2_S2_inst
       (
        .CLKA   ( clka                     ),     // Port A Clock
        .DOA    ( douta[r*2 +: 2]          ),     // Port A 1-bit Data Output
        .DOPA   (                          ),
        .ADDRA  ( addra                    ),     // Port A 14-bit Address Input
        .DIA    ( dina[r*2 +: 2]           ),     // Port A 1-bit Data Input
        .DIPA   ( 1'b0                     ),
        .ENA    ( ena[r/4]                 ),     // Port A RAM Enable Input
        .SSRA   ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WEA    ( wea[r/4]                 ),     // Port A Write Enable Input
        .CLKB   ( clkb                     ),     // Port B Clock
        .DOB    ( doutb[r*2 +: 2]          ),     // Port B 1-bit Data Output
        .DOPB   (                          ),
        .ADDRB  ( addrb                    ),     // Port B 14-bit Address Input
        .DIB    ( dinb[r*2 +: 2]           ),     // Port B 1-bit Data Input
        .DIPB   ( 1'b0                     ),
        .ENB    ( enb[r/4]                 ),     // Port B RAM Enable Input
        .SSRB   ( 1'b0                     ),     // Port B Synchronous Set/Reset Input
        .WEB    ( web[r/4]                 )      // Port B Write Enable Input
        );
   endgenerate

`else // !`ifdef FPGA

infer_dpram #(.RAM_SIZE(13), .BYTE_WIDTH(8)) ram1 // RAM_SIZE is in words
(
.ram_clk_a(clka),
.ram_en_a(ena),
.ram_we_a(wea),
.ram_addr_a(addra),
.ram_wrdata_a(dina),
.ram_rddata_a(douta),
.ram_clk_b(clkb),
.ram_en_b(enb),
.ram_we_b(web),
.ram_addr_b(addrb),
.ram_wrdata_b(dinb),
.ram_rddata_b(doutb)
 );
   
`endif
   
endmodule // dualmem
