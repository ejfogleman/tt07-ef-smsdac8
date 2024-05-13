/*
 * Copyright (c) 2024 Eric Fogleman
 * SPDX-License-Identifier: Apache-2.0
 *
 * TT project wrapper for ef_smsdac
 * 1-10 MHz Segmented mismatch-shaping DAC 
 * Input clock at 1-50 MHz 
 * 8-b unsigned input data on ui_in[7:0]; sync'd to clk (oversampled)
 * uo_out[7:0] connect to {8x, 4x, 2x, 1x} weight 3-level DACs
 * uio currently unused (create SPI data interface in future)
 */

`default_nettype none
`timescale 1ns / 100ps

module tt_um_ejfogleman_smsdac (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
    );

 // release reset when project enabled
  wire ena_and_rst_n = ena & rst_n;

  // uio[6:2] currently unused.
  assign uio_out[6:0] = 0;
  assign uio_oe[6:0] = 0;
  assign uio_oe[7]  = 0;  // enable msb to monitor enable
  assign uio_out[7] = ena_and_rst_n;

  ef_smsdac8_top u_top( 
    .i_clk(clk), 
    .i_rst_b(ena_and_rst_n), 
    .i_en_enc(uio_in[0]),
    .i_en_dith(uio_in[1]),
    .i_x(ui_in[7:0]), 
    .o_y8(uo_out[7:6]), 
    .o_y4(uo_out[5:4]), 
    .o_y2(uo_out[3:2]), 
    .o_y1(uo_out[1:0]) );

endmodule
