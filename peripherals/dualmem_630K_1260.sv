
module dualmem_256K_1260(clka, clkb, dina, dinb, addra, addrb, wea, web, douta, doutb, ena, enb);

   input wire clka;
   input wire clkb;
   input wire [1259:0] dina;
   input wire [1259:0] dinb;
   input wire [8:0] addra;
   input wire [8:0] addrb;
   input wire                wea;
   input wire                web;
   input wire                ena, enb;
   output wire [1259:0]      douta;
   output wire [1259:0]      doutb;

   genvar r;

`ifdef FPGA
   
   generate for (r = 0; r < 35; r=r+1)
     RAMB16_S36_S36
     RAMB16_S36_S36_inst
       (
        .CLKA   ( clka                     ),     // Port A Clock
        .DOA    ( douta[r*36 +: 32]        ),     // Port A 1-bit Data Output
        .DOPA   ( douta[r*36+32 +: 4]      ),
        .ADDRA  ( addra                    ),     // Port A 9-bit Address Input
        .DIA    ( dina[r*36 +: 32]         ),     // Port A 1-bit Data Input
        .DIPA   ( dina[r*36+32 +: 4]       ),
        .ENA    ( ena                      ),     // Port A RAM Enable Input
        .SSRA   ( 1'b0                     ),     // Port A Synchronous Set/Reset Input
        .WEA    ( wea                      ),     // Port A Write Enable Input
        .CLKB   ( clkb                     ),     // Port B Clock
        .DOB    ( doutb[r*36 +: 32]        ),     // Port B 1-bit Data Output
        .DOPB   ( doutb[r*36+32 +: 4]      ),
        .ADDRB  ( addrb                    ),     // Port B 9-bit Address Input
        .DIB    ( dinb[r*36 +: 32]         ),     // Port B 1-bit Data Input
        .DIPB   ( dinb[r*36+32 +: 4]       ),
        .ENB    ( enb                      ),     // Port B RAM Enable Input
        .SSRB   ( 1'b0                     ),     // Port B Synchronous Set/Reset Input
        .WEB    ( web                      )      // Port B Write Enable Input
        );
   endgenerate

`else // !`ifdef FPGA

logic [7:0] uncon;
   
infer_dpram #(.RAM_SIZE(9), .BYTE_WIDTH(158)) ram1 // RAM_SIZE is in words
(
.ram_clk_a(clka),
.ram_en_a(ena),
.ram_we_a({158{wea}}),
.ram_addr_a(addra),
.ram_wrdata_a({4'b0,dina}),
.ram_rddata_a({uncon[7:4],douta}),
.ram_clk_b(clkb),
.ram_en_b(enb),
.ram_we_b({158{web}}),
.ram_addr_b(addrb),
.ram_wrdata_b({4'b0,dinb}),
.ram_rddata_b({uncon[3:0],doutb})
 );
   
`endif
   
endmodule // dualmem
