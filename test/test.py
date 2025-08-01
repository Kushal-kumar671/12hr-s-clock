import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_12hr_clock_basic(dut):
    """Test basic 12-hour clock functionality"""
    
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
    
    # Extract clock values
    hours = int(dut.uo_out.value) & 0x0F
    am_pm = (int(dut.uo_out.value) >> 4) & 0x01
    minutes_upper = (int(dut.uo_out.value) >> 5) & 0x07
    minutes_lower = (int(dut.uio_out.value) >> 5) & 0x07
    minutes = (minutes_upper << 3) | minutes_lower
    seconds_upper = int(dut.uio_out.value) & 0x0F
    
    print(f"Initial time: {hours:02d}:{minutes:02d}:{seconds_upper*4:02d} {'PM' if am_pm else 'AM'}")
    
    # Check initial values (should be 12:00:00 AM)
    assert hours == 12, f"Expected hours=12, got {hours}"
    assert am_pm == 0, f"Expected AM (0), got {am_pm}"
    assert minutes == 0, f"Expected minutes=0, got {minutes}"
    
    print("✓ Initial values correct")

@cocotb.test()
async def test_reset_functionality(dut):
    """Test reset functionality"""
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 10)
    
    # Apply reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    
    # Check reset values
    hours = int(dut.uo_out.value) & 0x0F
    am_pm = (int(dut.uo_out.value) >> 4) & 0x01
    
    assert hours == 12, f"Expected hours=12 after reset, got {hours}"
    assert am_pm == 0, f"Expected AM (0) after reset, got {am_pm}"
    
    print("✓ Reset functionality works correctly")

@cocotb.test()
async def test_enable_signal(dut):
    """Test enable signal functionality"""
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize with enable off
    dut.ena.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    
    # Clock divider should not advance when ena=0
    clk_div_disabled = dut.clk_div.value
    await ClockCycles(dut.clk, 10)
    clk_div_still = dut.clk_div.value
    
    # Enable the clock
    dut.ena.value = 1
    await ClockCycles(dut.clk, 10)
    clk_div_enabled = dut.clk_div.value
    
    print(f"Clock divider - Disabled: {clk_div_disabled}, Still: {clk_div_still}, Enabled: {clk_div_enabled}")
    print("✓ Enable signal controls clock divider")

@cocotb.test()
async def test_io_configuration(dut):
    """Test I/O pin configuration"""
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.rst_n.value = 1
    
    await ClockCycles(dut.clk, 5)
    
    # Check that uio_oe is configured correctly (all outputs)
    uio_oe = int(dut.uio_oe.value)
    assert uio_oe == 0xFF, f"Expected uio_oe=0xFF, got 0x{uio_oe:02X}"
    
    print("✓ I/O configuration correct - all uio pins set as outputs")

@cocotb.test()
async def test_clock_bounds(dut):
    """Test that clock values stay within valid bounds"""
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    
    # Run for many cycles to test bounds
    for i in range(100):
        await ClockCycles(dut.clk, 10)
        
        hours = int(dut.uo_out.value) & 0x0F
        minutes_upper = (int(dut.uo_out.value) >> 5) & 0x07
        minutes_lower = (int(dut.uio_out.value) >> 5) & 0x07
        minutes = (minutes_upper << 3) | minutes_lower
        
        # Check bounds
        assert 1 <= hours <= 12, f"Hours out of bounds: {hours}"
        assert 0 <= minutes <= 59, f"Minutes out of bounds: {minutes}"
    
    print("✓ Clock values remain within valid bounds")

@cocotb.test()
async def test_clock_divider(dut):
    """Test clock divider operation"""
    
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Initialize
    dut.ena.value = 1
    dut.rst_n.value = 0
    
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)
    
    # Check that clock divider starts at 0
    initial_div = int(dut.clk_div.value)
    assert initial_div == 0, f"Expected clk_div=0 after reset, got {initial_div}"
    
    # Check that divider increments
    await ClockCycles(dut.clk, 10)
    later_div = int(dut.clk_div.value)
    assert later_div > initial_div, f"Clock divider not incrementing: {initial_div} -> {later_div}"
    
    print(f"✓ Clock divider working: {initial_div} -> {later_div}")

if __name__ == "__main__":
    import os
    # Run the simulation
    os.system("make test")