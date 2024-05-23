/*
 * Copyright (c) 2024 Eric Fogleman
 * SPDX-License-Identifier: Apache-2.0
 *
 * TT project wrapper for ef_smsdac
 * 1-10 MHz Segmented mismatch-shaping DAC 
 * Input clock at 1-50 MHz 
 * 8-b unsigned input data on ui_in[7:0]; sync'd to clk (oversampled)
 * uo_out[7:0] connect to {64x, 32x, 16x, 8x} weight 3-level DACs
 * uio_out[7:3] optionally connect to {4x, 2x, 1x} 3-level DACs 
 */

`default_nettype none

module tt_um_ejfogleman_smsdac8 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    // verilator lint_off UNUSEDSIGNAL
    input  wire [7:0] uio_in,   // IOs: Input path
    // verilator lint_off UNUSEDSIGNAL
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
    );
  
  // release reset when project enabled
  wire ena_and_rst_n = ena & rst_n;

  assign uio_oe[7:0] = 8'b11111100;    // uio[7:2] used to bring out extra DAC lsbs
  assign uio_out[1:0] = 2'h0;    // uio[1:0] used as control inputs

  ef_smsdac8_top u_top( 
    .i_clk(clk), 
    .i_rst_b(ena_and_rst_n), 
    .i_en_enc(uio_in[0]),
    .i_en_dith(uio_in[1]),
    .i_x(ui_in[7:0]), 
    .o_y({uo_out[7:0],uio_out[7:2]}) );

endmodule
