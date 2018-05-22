//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2.v                                                       ////
////                                                              ////
////  This file is part of the "ps2" project                      ////
////  http://www.opencores.org/cores/ps2/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module ps2();

   reg rst, clk;
   reg [8:0]       rx_scan_code, i;
   reg [7:0]        kcode, ascii_code, revcode[0:255];
   reg              translate, shift, ctrl ;
   wire [7:0]       rx_translated_scan_code;
   reg              rx_scan_ready;
   reg              rx_released;
   
   initial
     begin
        translate = 1;
        rx_scan_ready = 1;
        rx_released = 0;
        
        rst = 1;
        clk = 0;
        for (i = 0; i < 256; i=i+1)
          begin
             revcode[i] = 8'hff;
          end
        for (rx_scan_code = 0; rx_scan_code < 255; rx_scan_code=rx_scan_code+1)
          begin
             #1000
               clk = 1;
             #1000
               clk = 0;
             rst = 0;
             revcode[ASCII_code(rx_scan_code[6:0], rx_scan_code[7])] = rx_scan_code;
          end
        $display("uint8_t kcode[] = {");
        for (i = 0; i < 128; i=i+1)
          begin
             $display("[%d] = 0x%X,", i, revcode[i]);
          end
        $display("};\n");
     end
        
   wire             ps2_k_clk_en_o_ ;
   wire             ps2_k_data_en_o_ ;
   wire             ps2_k_clk_i ;
   wire             ps2_k_data_i ;

   wire             rx_scan_read;
   reg [7:0]        tx_data;
   reg              tx_write;
   wire             tx_write_ack_o;
   wire             tx_error_no_keyboard_ack;
   wire [15:0]      divide_reg = 13000;
   reg              ascii_data_ready, data_ready_dly;
   wire             rx_translated_data_ready;

`include "ascii_code.v"

   task trantask;
      
          begin
             kcode = 0;
             case(rx_translated_scan_code[6:0])
               7'H2A, 7'H36: shift = ~rx_translated_scan_code[7];
               7'H1D: ctrl = ~rx_translated_scan_code[7];
               default: kcode = ASCII_code(rx_translated_scan_code,shift|ctrl);
             endcase
             if (kcode && !rx_translated_scan_code[7])
               begin
                  if (ctrl && (kcode >= "A") && (kcode <= "]"))
                    begin
                       kcode = kcode & ~(7'H40);
                    end
                  ascii_code = kcode;
                  ascii_data_ready = 1;
               end
          end
   endtask
   
   ps2_translation_table i_ps2_translation_table
     (
      .reset_i                    (rst),
      .clock_i                    (clk),
      .translate_i                (translate),
      .code_i                     (rx_scan_code[7:0]),
      .code_o                     (rx_translated_scan_code),
      .address_i                  (8'h00),
      .data_i                     (8'h00),
      .we_i                       (1'b0),
      .re_i                       (1'b0),
      .data_o                     (),
      .rx_data_ready_i            (rx_scan_ready),
      .rx_translated_data_ready_o (rx_translated_data_ready),
      .rx_read_i                  (rx_translated_data_ready),
      .rx_read_o                  (rx_scan_read),
      .rx_released_i              (rx_released)
      ) ;

endmodule
