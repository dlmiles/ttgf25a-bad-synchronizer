# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 0

    dut.rst_n.value = 0
    dut.ui_in.value = 0x00 # BASE2 mode
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    dut.ui_in.value = 0x04 # BASE2 mode (enable counter)
    await ClockCycles(dut.clk, 1)

    for n in range(0, 32):
        dut._log.info("BASE2[{:02d}] 0x{:02x} 0x{:02x}  {} {}  UO UIO".format(n,
            dut.uo_out.value.to_unsigned(), dut.uio_out.value.to_unsigned(),
            str(dut.uo_out.value), str(dut.uio_out.value)))
        #await ClockCycles(dut.clk, 1)
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0x05
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x04

    dut.rst_n.value = 0
    dut.ui_in.value = 0x06 # GRAY CODE mode (counter on to flush reset)
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1
    dut.ui_in.value = 0x04 # GRAY CODE mode (counter off)
    await ClockCycles(dut.clk, 1)
    dut.ui_in.value = 0x06 # GRAY CODE mode (enable counter)
    await ClockCycles(dut.clk, 1) # GRAY CODE is one cycle delayed

    for n in range(0, 32):
        dut._log.info("GRAY[{:02d}]  0x{:02x} 0x{:02x}  {} {}  UO UIO".format(n,
            dut.uo_out.value.to_unsigned(), dut.uio_out.value.to_unsigned(),
            str(dut.uo_out.value), str(dut.uio_out.value)))
        #await ClockCycles(dut.clk, 1)
        await RisingEdge(dut.clk)
        dut.ui_in.value = 0x07
        await FallingEdge(dut.clk)
        dut.ui_in.value = 0x06

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
