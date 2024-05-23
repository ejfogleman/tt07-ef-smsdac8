/*
 * Copyright (c) 2024 Eric Fogleman
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * 8-b fully-segmented mismatch shaping encoder 
 * from SEGMENTED MISMATCH-SHAPING D/A CONVERSION, 
 * Fishov, Fogleman, Siragusa, Galton 
 * 2002 IEEE International Symposium on Circuits and Systems (ISCAS)
 * y0 drives 1x 3-level DAC
 * y1: 2x, y2: 4x, ..., y6: 64x
 * 128x DAC driven by x7, yc
 * i_en == 1'b0 stops mismatch shaping (static encoder)
 */
/* verilator lint_off DECLFILENAME */

// 8-b hierarchical encoder
// seg switching blocks to requantize the input
// binary switching blocks for each scaled 3-level DAC
module ef_smsdac8_mse ( 
	input i_clk,
	input i_rst_b,
	input i_en,
	input [7:0] i_x,
	input i_xc,
	input [7:0] i_r,
	output [13:0] o_y );	// y64[1:0], y32[1:0], ..., y1[1;0] 
 
	// 8 layers:  input 7, output 0
	// elements numbered top to bottom.  
	// signals and instances use layer, element notation:
	// u_s70 is 0th switching block in layer 7
	// y70 is output of layer 7, element 0

	// carry outs from segmenting switching blocks
	wire yc70, yc60, yc50, yc40, yc30, yc20, yc10;

	wire [1:0] y10, y20, y30, y40, y50, y60;  // to binary encoders
    // verilator lint_off UNUSEDSIGNAL
	wire [1:0] y70;	 // unused
    // verilator lint_on UNUSEDSIGNAL

	// layer 7
	ef_smsdac_mse_seg_sb u_s70( 
		.i_x(i_x[0]), 
		.i_xc(i_xc), 
		.i_r(i_r[7]), 
		.i_en(i_en),
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc70), 
		.o_y(y70[1:0]) );  // unused

	// layer 6
	ef_smsdac_mse_seg_sb u_s60( 
		.i_x(i_x[1]), 
		.i_xc(yc70), 
		.i_r(i_r[6]), 
		.i_en(i_en),
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc60), 
		.o_y(y60[1:0]) );

	ef_smsdac_mse_bin_sb u_s06(
		.i_x(y60[1]), 
		.i_xc(y60[0]),
		.i_r(i_r[6]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[1:0]) );	// 1*delta DAC

	// layer 5
	ef_smsdac_mse_seg_sb u_s50( 
		.i_x(i_x[2]), 
		.i_xc(yc60), 
		.i_r(i_r[5]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc50), 
		.o_y(y50[1:0]) );

	ef_smsdac_mse_bin_sb u_s05(
		.i_x(y50[1]), 
		.i_xc(y50[0]),
		.i_r(i_r[5]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[3:2]) );	// 2*delta DAC

	// layer 4
	ef_smsdac_mse_seg_sb u_s40( 
		.i_x(i_x[3]), 
		.i_xc(yc50), 
		.i_r(i_r[4]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc40), 
		.o_y(y40[1:0]) );

	ef_smsdac_mse_bin_sb u_s04(
		.i_x(y40[1]), 
		.i_xc(y40[0]),
		.i_r(i_r[4]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[5:4]) );	// 4*delta DAC

	// layer 3
	ef_smsdac_mse_seg_sb u_s30( 
		.i_x(i_x[4]), 
		.i_xc(yc40), 
		.i_r(i_r[3]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc30), 
		.o_y(y30[1:0]) );
		
	ef_smsdac_mse_bin_sb u_s03(
		.i_x(y30[1]), 
		.i_xc(y30[0]),
		.i_r(i_r[3]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[7:6]) );	// 8*delta DAC
		
	// layer 2
	ef_smsdac_mse_seg_sb u_s20( 
		.i_x(i_x[5]), 
		.i_xc(yc30), 
		.i_r(i_r[2]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc20), 
		.o_y(y20[1:0]) );
		
	ef_smsdac_mse_bin_sb u_s02(
		.i_x(y20[1]), 
		.i_xc(y20[0]),
		.i_r(i_r[2]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[9:8]) );	// 16*delta DAC

	// layer 1
	ef_smsdac_mse_seg_sb u_s10( 
		.i_x(i_x[6]), 
		.i_xc(yc20), 
		.i_r(i_r[1]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_yc(yc10), 
		.o_y(y10[1:0]) );
		
	ef_smsdac_mse_bin_sb u_s01(
		.i_x(y10[1]), 
		.i_xc(y10[0]),
		.i_r(i_r[1]), 
		.i_en(i_en),
		.i_clk(i_clk),
		.i_rst_b(i_rst_b),
		.o_y(o_y[11:10]) );	// 32*delta DAC
		
	// layer 0
	// {i_x[7], yc10};		
	// ms-segment from {input msb, final carry out}
	ef_smsdac_mse_bin_sb u_s00( 
		.i_x(i_x[7]), 
		.i_xc(yc10), 
		.i_r(i_r[0]),
		.i_en(i_en), 
		.i_clk(i_clk), 
		.i_rst_b(i_rst_b), 
		.o_y(o_y[13:12]) );	// 64*delta DAC

endmodule


// DAC top level 
//
module ef_smsdac8_top( 
    input i_clk, 
    input i_rst_b, 
    input i_en_enc, 
    input i_en_dith, 
    input [7:0] i_x, 
    output wire [13:0] o_y );	// y64[1:0], y32[1:0], ..., y1[1;0] 

    wire [7:0] x_sync1, x_sync2; // input data synchronizer
    wire [7:0] r;  // random dither bits
    wire [13:0] y;  // encoder outputs to final reclock

    // input data sync reg
    ef_smsdac_reg #(.BITS(8)) u_sync1(
        .i_clk(i_clk), 
        .i_rst_b(i_rst_b), 
        .i_d(i_x), 
        .o_q(x_sync1) );  

    // input data sync reg
    ef_smsdac_reg #(.BITS(8)) u_sync2(
        .i_clk(i_clk), 
        .i_rst_b(i_rst_b), 
        .i_d(x_sync1), 
        .o_q(x_sync2) );  

    // mismatch-shaping encoder
    ef_smsdac8_mse u_dac(
        .i_clk(i_clk), 
        .i_rst_b(i_rst_b), 
        .i_en(i_en_enc),
        .i_x(x_sync2), 
        .i_xc(1'b0),  // no carry in
        .i_r(r), 
        .o_y(y) );

    // LFSR
    ef_lfsr20_8 u_lfsr(
        .i_clk(i_clk),
        .i_rst_b(i_rst_b),
        .i_en(i_en_dith),
        .o_r(r) );

    // output retiming reg
    ef_smsdac_reg #(.BITS(14)) u_reg(
        .i_clk(i_clk), 
        .i_rst_b(i_rst_b), 
        .i_d(y), 
        .o_q(o_y) );

endmodule
/* verilator lint_on DECLFILENAME */
