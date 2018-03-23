// Copyright 2018 ETH Zurich and University of Cambridge.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
// 
//////////////////////////////////////////////////////////////////////////////////

// See LICENSE for license details.

module infer_bram #(BRAM_SIZE=16, BYTE_WIDTH=8) // BRAM_SIZE is in words
(
input ram_clk, ram_en,
input [BYTE_WIDTH-1:0] ram_we,
input [BRAM_SIZE-1:0] ram_addr,
input [BYTE_WIDTH*8-1:0] ram_wrdata,
output [BYTE_WIDTH*8-1:0] ram_rddata);

   localparam BRAM_LINE          = 2 ** BRAM_SIZE;   
   integer                initvar;

   reg [BYTE_WIDTH*8-1:0] ram [0 : BRAM_LINE-1];
   reg [BRAM_SIZE-1:0]    ram_addr_delay;
   
   initial
      for (initvar = 0; initvar < BRAM_LINE; initvar = initvar+1)
        ram[initvar] = {BYTE_WIDTH {8'b0}};

   always @(posedge ram_clk)
    begin
     if(ram_en) begin
        ram_addr_delay <= ram_addr;
        foreach (ram_we[i])
          if(ram_we[i]) ram[ram_addr][i*8 +:8] <= ram_wrdata[i*8 +: 8];
     end
    end

   assign ram_rddata = ram[ram_addr_delay];
   
endmodule
