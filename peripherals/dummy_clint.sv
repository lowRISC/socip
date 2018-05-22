// See LICENSE for license details.
`default_nettype none

module dummy_clint
  (
   input wire          rstn, msoc_clk,
   input wire [15:0]   addr,
   input wire [63:0]   wdata,
   input wire [7:0]    we_d,
   input wire          ce_d,
   output logic [63:0] rdata
   );

   logic [15:0]        addr_dly;   
   logic               ce_d_dly;
   logic [63:0]        reg0,reg1,reg2,reg3,reg4,reg5,reg6,reg7;
   
always @(posedge msoc_clk)
  if (!rstn)
    begin
       addr_dly <= 0;
       ce_d_dly <= 1'b0;
       reg0 <= 'b0;
       reg1 <= 'b0;
       reg2 <= 'b0;
       reg3 <= 'b0;
       reg4 <= 'b0;
       reg5 <= 'b0;
       reg6 <= 'b0;
       reg7 <= 'b0;
    end
  else
    begin
    addr_dly <= addr;
    ce_d_dly <= ce_d;
    if (ce_d&(|we_d))
      begin
         case(we_d)
           8'b11110000: $display("clint_store(%x,%x,%x)", addr, 4, wdata);
           8'b00001111: $display("clint_store(%x,%x,%x)", addr, 4, wdata);
           8'b11111111: $display("clint_store(%x,%x,%x)", addr, 8, wdata);
         endcase; // case (we_d)
         
      case({addr[15:14],addr[3]})
        0: reg0 <= wdata;
        1: reg1 <= wdata;
        2: reg2 <= wdata;
        3: reg3 <= wdata;
        4: reg4 <= wdata;
        5: reg5 <= wdata;
        6: reg6 <= wdata;
        7: reg7 <= wdata;
      endcase // case (addr[6:3])
      end
    end

always @*
  casez({addr_dly[15:14],addr_dly[3]})
    3'b000 : rdata = reg0;
    3'b001 : rdata = reg1;
    3'b010 : rdata = reg2;
    3'b011 : rdata = reg3;
    3'b100 : rdata = reg4;
    3'b101 : rdata = reg5;
    3'b110 : rdata = reg6;
    3'b111 : rdata = reg7;
  endcase

always @(ce_d_dly or addr or rdata)   
  if (ce_d_dly)
    $display("clint_load(%x,%x,%x)", addr, 4, rdata);
   
endmodule // top
`default_nettype wire
