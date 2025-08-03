# ==========================================================
# Description: Cocotb testbench for verifying RFDC Driver
# Author: Abdullah Alnafisah
# ==========================================================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
import logging

# DUT configuration
CLK_FREQ_HZ = 100_000_000  # 100 MHz
CLK_PERIOD_NS = 1e9 / CLK_FREQ_HZ  # ~20 ns


async def reset_dut(rst_n):
    """Generate an active-low reset pulse."""
    rst_n.value = 0
    await Timer(5 * CLK_PERIOD_NS, units="ns")
    rst_n.value = 1
    await Timer(5 * CLK_PERIOD_NS, units="ns")


@cocotb.test()
async def test_rfdc_driver(dut):
    """Test RFDC driver functionality."""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, CLK_PERIOD_NS, units="ns").start())

    # Initialize inputs
    dut.enable.value = 0
    dut.s_axis_tready.value = 0

    # Apply reset
    await reset_dut(dut.rst_n)

    await FallingEdge(dut.clk)
    dut.s_axis_tready.value = 1

    await FallingEdge(dut.clk)
    dut.enable.value = 1

    # Extra wait to capture full waveform
    await Timer(CLK_PERIOD_NS * 100, units="ns")

    await FallingEdge(dut.clk)
    dut.s_axis_tready.value = 0

    # Extra wait to capture full waveform
    await Timer(CLK_PERIOD_NS * 10, units="ns")
