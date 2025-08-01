# 12hr-s-clock - TinyTapeout Digital Clock

A complete 12-hour digital clock implementation for TinyTapeout that outputs time in binary format with proper AM/PM handling.

![Clock Demo](https://img.shields.io/badge/Time-12%3A00%3A00%20AM-blue) ![TinyTapeout](https://img.shields.io/badge/TinyTapeout-Ready-green) ![Verilog](https://img.shields.io/badge/Language-Verilog-orange)

## 🕐 Overview

This project implements a fully functional 12-hour digital clock that:
- **Counts in true 12-hour format** (1-12 hours, not 0-11)
- **Proper AM/PM transitions** at midnight and noon
- **Binary time output** across TinyTapeout pins
- **Accurate 1-second timing** with configurable clock divider
- **Clean reset behavior** to 12:00:00 AM

## 📁 Project Structure

```
12hr-s-clock/
├── src/
│   └── 12hr-s-clock.v        # Main Verilog implementation
├── test/
│   ├── tb.v                  # Verilog testbench
│   └── test.py               # Python Cocotb tests
├── info.yaml                 # TinyTapeout configuration
├── Makefile                  # Build automation
└── README.md                 # This documentation
```

## ⚡ Quick Start

### Testing Locally
```bash
# Basic simulation
make sim

# Comprehensive tests  
make test

# View waveforms
make wave

# Validate design
make validate
```

### TinyTapeout Submission
1. Ensure files are in correct structure (see above)
2. Update author name in `info.yaml`
3. Commit to your GitHub repository
4. Submit repository URL to TinyTapeout

## 🔧 How It Works

### Architecture
```
10MHz Clock → Clock Divider → Seconds → Minutes → Hours → AM/PM
     ↓             ↓            ↓         ↓        ↓       ↓
   Input      1Hz Tick      (0-59)    (0-59)   (1-12)  Toggle
```

### Key Components

**Clock Divider:**
- Converts 10MHz input to 1Hz for second timing
- Configurable for different input frequencies
- Controlled by enable signal for power management

**Time Counters:**
- **Seconds:** 0-59, cascades to minutes
- **Minutes:** 0-59, cascades to hours  
- **Hours:** 1-12 (proper 12-hour format)
- **AM/PM:** Toggles at 11:59:59→12:00:00

### 12-Hour Logic
The clock correctly handles all 12-hour format quirks:
- Starts at **12:00:00 AM** (midnight)
- **12 AM** → **1 AM** → ... → **11 AM** → **12 PM** → **1 PM** → ... → **11 PM** → **12 AM**
- AM/PM changes when transitioning from 11:59:59 to 12:00:00
- Hour 12 wraps to hour 1 (never goes to 0)

## 📌 Pin Mapping

### Dedicated Outputs (`uo_out[7:0]`)
| Pin | Function | Description |
|-----|----------|-------------|
| `uo_out[0]` | Hours[0] | LSB of hours (1-12) |
| `uo_out[1]` | Hours[1] | Hours bit 1 |
| `uo_out[2]` | Hours[2] | Hours bit 2 |
| `uo_out[3]` | Hours[3] | MSB of hours |
| `uo_out[4]` | AM/PM | 0=AM, 1=PM |
| `uo_out[5]` | Minutes[3] | Minutes bit 3 |
| `uo_out[6]` | Minutes[4] | Minutes bit 4 |
| `uo_out[7]` | Minutes[5] | MSB of minutes |

### Bidirectional Pins (`uio[7:0]` - All Outputs)
| Pin | Function | Description |
|-----|----------|-------------|
| `uio[0]` | Seconds[2] | Seconds bit 2 |
| `uio[1]` | Seconds[3] | Seconds bit 3 |
| `uio[2]` | Seconds[4] | Seconds bit 4 |
| `uio[3]` | Seconds[5] | MSB of available seconds |
| `uio[4]` | Minutes[0] | LSB of minutes |
| `uio[5]` | Minutes[1] | Minutes bit 1 |
| `uio[6]` | Minutes[2] | Minutes bit 2 |
| `uio[7]` | Minutes[3] | Minutes bit 3 |

### Reading Time Values (Verilog Example)
```verilog
wire [3:0] hours = uo_out[3:0];          // 1-12
wire am_pm = uo_out[4];                  // 0=AM, 1=PM
wire [5:0] minutes = {uo_out[7:5], uio_out[7:5]}; // 0-59
wire [3:0] seconds_upper = uio_out[3:0]; // Upper 4 bits only
```

## 🧪 Testing

### Included Tests

**Verilog Testbench (`test/tb.v`):**
- Basic functionality verification
- Reset behavior testing
- Enable signal testing
- I/O configuration checks
- Extended runtime testing

**Python Tests (`test/test.py`):**
- Comprehensive Cocotb test suite
- Clock boundary testing
- Clock divider verification
- State machine validation

### Running Tests
```bash
# Quick compilation check
make quick-test

# Full Verilog simulation
make sim

# Python test suite
make test

# Synthesis verification
make synth

# Lint checking
make lint
```

## 🔌 External Hardware

### Option 1: LED Binary Display
Connect LEDs directly to output pins to show time in binary:
- 4 LEDs for hours (1-12 in binary)
- 6 LEDs for minutes (0-59 in binary) 
- 4 LEDs for seconds (upper bits only)
- 1 LED for AM/PM indication

### Option 2: 7-Segment Displays
Use binary-to-7-segment decoders:
- 2 digits for hours (01-12)
- 2 digits for minutes (00-59)
- 2 digits for seconds (00-59, limited precision)
- AM/PM indicator

### Option 3: Microcontroller Interface
Connect all pins to a microcontroller GPIO for custom display formatting.

### Example Connections
```
uo_out[3:0] → Hours decoder/display
uo_out[4]   → AM/PM LED
uo_out[7:5] + uio_out[7:4] → Minutes decoder/display  
uio_out[3:0] → Seconds decoder/display
rst_n → Reset button (with pull-up resistor)
```

## ⚙️ Customization

### Clock Frequency Adjustment
Modify the clock divider in `src/12hr-s-clock.v`:
```verilog
localparam CLK_DIV_MAX = 24'd9_999_999; // For 10MHz

// For other frequencies:
// 1MHz:  24'd999_999
// 50MHz: 24'd49_999_999  
// Formula: (input_freq_hz - 1)
```

### Adding Features
- **Time Setting:** Use `ui_in` pins to set time
- **Alarm:** Add alarm comparison logic
- **24-Hour Mode:** Modify hour counter logic
- **Date Counter:** Extend to track days/months

## 🚀 Design Features

### ✅ Verified Functionality
- Proper 12-hour format (1-12, not 0-11)
- Correct AM/PM transitions
- Clean reset to 12:00:00 AM
- Stable clock divider operation
- All time values within valid bounds

### 🔧 Technical Details
- **Language:** Verilog (synthesizable)
- **Clock:** 10MHz input (configurable)
- **Reset:** Active-low synchronous reset
- **Power:** Enable-controlled operation
- **I/O:** 8 dedicated outputs + 8 bidirectional (as outputs)

### 📊 Resource Usage
- **Registers:** ~50 flip-flops
- **Logic:** Minimal combinational logic
- **Memory:** None required
- **Size:** Fits easily in 1x1 TinyTapeout tile

## 🐛 Known Limitations

1. **Seconds Resolution:** Only upper 4 bits available on outputs (4-second resolution)
2. **No Time Setting:** Always starts from 12:00:00 AM (could be extended)
3. **Clock Accuracy:** Depends on input clock stability
4. **Simulation Speed:** Real-time testing requires long simulations

## 🤝 Contributing

This project is open source! Improvements welcome:
- Add time-setting functionality
- Implement different display modes
- Add alarm features
- Optimize resource usage
- Improve test coverage

## 📄 License

This project is licensed under Apache-2.0. Free for educational and commercial use.

## 🏆 TinyTapeout Integration

This design is fully compatible with TinyTapeout requirements:
- ✅ Proper module naming (`tt_um_*`)
- ✅ Standard I/O interface  
- ✅ Synthesizable Verilog
- ✅ Complete test suite
- ✅ Comprehensive documentation
- ✅ Apache-2.0 license

---

**Ready for silicon!** 🚀

*This project brings accurate timekeeping to custom silicon through TinyTapeout's accessible chip manufacturing program.*