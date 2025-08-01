import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_clock_12h(dut):
    """Test the 12-hour clock functionality"""
    
    # Create a 10MHz clock (100ns period)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    # Wait a few clock cycles
    await ClockCycles(dut.clk, 5)
    
    # Release reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    
    # Check initial values (should be 12:00:00 AM)
    hours = int(dut.uo_out.value) & 0x0F
    am_pm = (int(dut.uo_out.value) >> 4) & 0x01
    minutes_upper = (int(dut.uo_out.value) >> 5) & 0x07
    minutes_lower = (int(dut.uio_out.value) >> 4) & 0x0F
    minutes = (minutes_upper << 4) | minutes_lower
    seconds_upper = int(dut.uio_out.value) & 0x0F
    
    print(f"Initial time: {hours:02d}:{minutes:02d}:{seconds_upper*4:02d} {'PM' if am_pm else 'AM'}")
    
    assert hours == 12, f"Expected hours=12, got {hours}"
    assert am_pm == 0, f"Expected AM (0), got {am_pm}"
    assert minutes == 0, f"Expected minutes=0, got {minutes}"
    
    print("✓ Initial values correct")
    
    # Test reset functionality
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    
    hours = int(dut.uo_out.value) & 0x0F
    am_pm = (int(dut.uo_out.value) >> 4) & 0x01
    
    assert hours == 12, f"Expected hours=12 after reset, got {hours}"
    assert am_pm == 0, f"Expected AM (0) after reset, got {am_pm}"
    
    print("✓ Reset functionality works")
    
    # Test clock divider by running for many cycles
    # Note: With the current divider, we'd need 10M cycles for 1 second
    # So we'll just test that the design doesn't crash
    await ClockCycles(dut.clk, 1000)
    
    # Check that outputs are still valid
    hours = int(dut.uo_out.value) & 0x0F
    assert 1 <= hours <= 12, f"Hours out of range: {hours}"
    
    print("✓ Clock runs stable for extended period")
    
    print("All tests passed!")

@cocotb.test()
async def test_io_configuration(dut):
    """Test that I/O configuration is correct"""
    
    # Create clock
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 5)
    
    # Check that uio_oe is configured correctly (all outputs)
    uio_oe = int(dut.uio_oe.value)
    assert uio_oe == 0xFF, f"Expected uio_oe=0xFF, got 0x{uio_oe:02X}"
    
    print("✓ I/O configuration correct")

if __name__ == "__main__":
    import os
    os.system("make")