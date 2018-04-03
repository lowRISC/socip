// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Date: 19.03.2017
// Description: Ariane Top-level module

module ddr_bram #(BRAM_SIZE=16, BYTE_WIDTH=8) // BRAM_SIZE is in words
(
input ram_clk, ram_en,
input [BYTE_WIDTH-1:0] ram_we,
input [BRAM_SIZE-1:3] ram_addr,
input [BYTE_WIDTH*8-1:0] ram_wrdata,
output reg [BYTE_WIDTH*8-1:0] ram_rddata);

   localparam BRAM_LINE          = 2 ** BRAM_SIZE;   
   integer                initvar;

   reg [BYTE_WIDTH*8-1:0] ram [0 : BRAM_LINE-1];
   string                 testname;

   wire [BYTE_WIDTH*8-1:0] mem0, mem1, mem2, mem3;
   
   initial
     if ($value$plusargs("readmemh=%s", testname))
       begin
          $readmemh(testname, ram);
       end
     else
       begin
          for (initvar = 0; initvar < BRAM_LINE; initvar = initvar+1)
            ram[initvar] = {BYTE_WIDTH {8'b0}};
          $readmemh("cnvmem64.hex", ram);
       end
   
   always @(posedge ram_clk)
     begin
        if (!ram_we)
          ram_rddata = ram[ram_addr];
        else if (ram_en)
          begin
             foreach (ram_we[i])
               if (ram_we[i]) ram[ram_addr][i*8 +:8] <= ram_wrdata[i*8 +: 8];
          end
     end

   assign mem0 = ram[0];
   assign mem1 = ram[1];
   assign mem2 = ram[2];
   assign mem3 = ram[3];

endmodule

