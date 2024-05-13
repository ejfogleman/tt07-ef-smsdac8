# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 1, units="us")
  cocotb.start_soon(clock.start())

  for mode in range(4):
    # Reset
    dut._log.info(f"Reset / Mode = {mode}")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = mode   #  uio_in[1:0] = {dith_en,enc_en}; 0: static, 1: 1st-order, 2: whitening, 3: dithered 1st-order
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # apply input code and check after 4 cycles
    dut._log.info("Check number conservation")
    in_val = 0x10;
    for ix in range(0xF):
      dut.ui_in.value = in_val  
      await ClockCycles(dut.clk, 4)
      dut._log.info(f"Input = {dut.ui_in.value}, Output = {dut.uo_out.value}, DAC Output = {dut.dac_v.value}")
      assert dut.ui_in.value // 16 + 7 == dut.dac_v.value  # test number conservation
      assert dut.uio_out.value == 0x80  # check ena_and_rst_n is high
      in_val += 0x10  
    


  

