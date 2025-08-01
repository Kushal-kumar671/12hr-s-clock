# 12-Hour Digital Clock - TinyTapeout Project

A 12-hour digital clock implementation for TinyTapeout that displays time in binary format with AM/PM indication.

## Overview

This project implements a complete 12-hour digital clock that:
- Counts seconds, minutes, and hours in proper 12-hour format (1-12)
- Includes AM/PM indication
- Starts at 12:00:00 AM on reset
- Outputs time values in binary across available pins

## How It Works

### Clock Architecture
```
Input Clock → Clock Divider → Second Counter → Minute Counter → Hour Counter
                    ↓              ↓              ↓             ↓
               1 Second Tick    0-59 Seconds   0-59 Minutes  1-12 Hours + AM/PM
```

### Key Components

1. **Clock Divider**: Generates 1-second pulses from the input clock (assumes 10MHz)
2. **Cascaded Counters**: Seconds overflow to minutes, minutes overflow to hours
3. **12-Hour Logic**: Properly handles 12→1 transitions and AM/PM switching
4. **Reset Logic**: Initializes to 12:00:00 AM (midnight)

### Pin Mapping

| Pin Range | Function | Description |
|-----------|----------|-------------|
| `uo_out[3:0]` | Hours | Binary hours (1-12) |
| `uo_out[4]` | AM/PM | 0=AM, 1=PM |
| `uo_out[7:5]` | Minutes[6:4] | Upper 3 bits of minutes |
| `uio_out[7:4]` | Minutes[3:0] | Lower 4 bits of minutes |
| `uio_out[3:0]` | Seconds[5:2] | Upper 4 bits of seconds |

## Files Description

- **`tt_um_clock_12h.v`**: Main Verilog module
- **`tb.v`**: Verilog testbench for basic simulation
- **`test.py`**: Cocotb Python test suite
- **`info.yaml`**: TinyTapeout project configuration
- **`Makefile`**: Build and test automation
- **`README.md`**: This documentation

## Testing

### Quick Test with iverilog
```bash
make sim
make wave  # View waveforms
```

### Comprehensive Test with Cocotb
```bash
make test
```

### Synthesis Check
```bash
make synth  # Requires yosys
make lint   # Requires verilator
```

## Usage Instructions

### Hardware Setup
1. Connect your external display hardware to decode the binary outputs
2. Use `uo_out[4]` to drive an AM/PM indicator LED
3. Connect a reset button to `rst_n` (active low)

### Software Operation
1. **Reset**: Pull `rst_n` low to initialize clock to 12:00:00 AM
2. **Enable**: Set `ena` high to start clock operation
3. **Read Time**: Decode binary values from output pins

### Example Time Decoding (Verilog)
```verilog
wire [3:0] hours = uo_out[3:0];
wire am_pm = uo_out[4];
wire [5:0] minutes = {uo_out[7:5], uio_out[7:4]};
wire [5:0] seconds = {uio_out[3:0], 2'b00}; // Only upper 4 bits available
```

## Design Features

### 12-Hour Format Compliance
- Hours count 1→2→...→11→12→1→... (not 0-based)
- AM/PM toggles at 11:59:59→12:00:00 transitions
- Midnight starts as 12:00:00 AM
- Noon is 12:00:00 PM

### Clock Accuracy
- Uses parametrizable clock divider
- Default assumes 10MHz input clock
- Adjust `clk_div` comparison value for different frequencies

### Reset Behavior
- Synchronous reset with active-low `rst_n`
- Always resets to 12:00:00 AM (midnight)
- Clean startup guaranteed

## Customization

### Clock Frequency Adjustment
Modify the clock divider in `tt_um_clock_12h.v`:
```verilog
// For 10MHz clock: 10,000,000 - 1 = 9,999,999
wire sec_tick = (clk_div == 24'd9_999_999);

// For different frequencies, adjust this value:
// Formula: (clock_freq_hz - 1)
```

### Extended Outputs
Current design uses most available pins. To add features:
- Use spare `uo_out[7:5]` bits for additional functionality
- Consider multiplexing if more outputs needed

## Verification

The design has been verified to:
- ✅ Start correctly at 12:00:00 AM
- ✅ Count seconds, minutes, hours properly
- ✅ Handle 59→0 rollovers correctly
- ✅ Maintain proper 12-hour format
- ✅ Toggle AM/PM at correct times
- ✅ Reset reliably to initial state

## Known Limitations

1. **Seconds Resolution**: Only upper 4 bits of seconds available on outputs
2. **Clock Accuracy**: Depends on input clock stability
3. **No Time Setting**: Clock always starts from 12:00:00 AM (could be extended)

## Future Enhancements

- Add time-setting inputs using `ui_in` pins
- Implement alarm functionality
- Add different time formats (24-hour mode)
- Include day/date counting

## License

This project is open source and suitable for educational and commercial use.

---

*Created for TinyTapeout - bringing custom silicon to everyone!*