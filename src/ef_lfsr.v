/*
 * Copyright (c) 2024 Eric Fogleman
 * SPDX-License-Identifier: Apache-2.0
  *
 * LFSR w/ multiple tapped outputs
 * updates K states at a time to avoid correlation in tapped bits
 * From: A 3.3-V SINGLE-POLY CMOS AUDIO ADC DELTA–SIGMA MODULATOR WITH 98-DB 
 * PEAK SINAD AND 105-DB PEAK SFDR, Fogleman et al
 */

/* verilator lint_off DECLFILENAME */
// n = 20, 1 + x^3 + x^n, K = 8
module ef_lfsr20_8 ( 
	input i_clk, 
	input i_rst_b, 
	input i_en, 
	output wire [7:0] o_r );

	reg [19:0] q;
	assign o_r[7:0] = q[8:1];  

	always @( posedge i_clk, negedge i_rst_b ) begin
		if( ~i_rst_b ) begin
			q[19:1] <= 19'b0;
			q[0] <= 1'b1;
		end
		else begin
			if ( i_en ) begin
				// jumps 8 states per clock
				q[19:12] <= q[7:0] ^ q[10:3];
				q[11:0] <= q[19:8];
			end
		end
	end
	
endmodule
/* verilator lint_on DECLFILENAME */
