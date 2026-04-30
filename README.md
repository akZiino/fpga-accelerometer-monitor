# FPGA Accelerometer Monitor

A complete FPGA-based accelerometer monitoring system implemented in VHDL, targeting the **Nexys-A7 (XC7A100T)** development board using **Vivado 2023.2**. The system reads live 3-axis acceleration data from an onboard ADXL362 sensor over SPI, computes a 32-sample running average, and displays signed decimal values on the 7-segment display. Switch inputs allow the user to override accelerometer data with manual values for testing.

Achieved **87%** as part of the Digital Systems Design module (EE3070), Royal Holloway, University of London.

---

## System Architecture

The design uses a fully **structural top-level** (`display.vhd`) that instantiates and connects all components. Data flows from sensor through processing to display as follows:

```
ADXL362 Sensor
     │ SPI (MOSI/MISO/SCLK/CS)
     ▼
ADXL362Ctrl ──► avg32_from_avg16 ──► input_select ──► bin2BCD ──► mux ──► bin2seg
                                           ▲                               │
                                      SW[15:0]                             ▼
                                                                    7-segment display
                                                                    (clock + counter + DAnC)
```

---

## Components

### `display.vhd` — Top-Level Module
Structural architecture instantiating all components below. Interfaces directly with Nexys-A7 board signals: 100MHz system clock, 16 switches, SPI pins, 7-segment anodes and cathodes, and RGB LED.

### `ADXL362Ctrl.vhd` — Accelerometer Controller
Three-state-machine controller for the ADXL362 accelerometer. Handles device reset, register configuration, continuous SPI read cycles, and 16-sample hardware averaging. Outputs 12-bit two's complement X, Y, Z, and temperature values at a configurable update rate (default 100Hz). Raises `Data_Ready` for one clock period when new averaged data is available.

### `SPI_If.vhd` — SPI Interface
Full-duplex SPI controller (CPOL=0, CPHA=0) operating at 1MHz. Transfers 8 bits MSB-first. Supports multi-byte transactions via `HOLD_SS` to keep chip select asserted across sequential byte transfers. Handshake interface via `Start` and `Done` signals.

### `ACC_XYZ.vhd` — Accelerometer Wrapper
Wraps `ADXL362Ctrl` with a self-blocking reset counter, ensuring a clean 10µs reset pulse on startup before the controller begins operation.

### `avg32_from_avg16.vhd` — 32-Sample Averager
Extends the controller's internal 16-sample average to a 32-sample average by averaging consecutive 16-sample outputs. Uses signed arithmetic with overflow-safe 13-bit intermediate values and arithmetic right-shift for the final division.

### `bin2BCD.vhd` — Binary to BCD Converter
Converts a 12-bit signed two's complement binary input to 4-digit BCD plus sign using the **Double Dabble (shift-and-add-3)** algorithm. Detects the sign bit, negates if necessary, then iterates 12 shifts with conditional add-3 on each BCD column when the value exceeds 4. Outputs `thousands`, `hundreds`, `tens`, `ones`, and `sign_out`.

### `bin2seg.vhd` — BCD to 7-Segment Decoder
Combinational decoder mapping 4-bit BCD values to active-low 7-segment patterns. Handles digits 0–9, minus sign (code `1010`), and blank (all others).

### `input_select.vhd` — Input Multiplexer
Single-line combinational mux. When SW15 is high, routes SW[11:0] to the display pipeline. When SW15 is low, routes the averaged accelerometer value.

### `clock.vhd` — Display Clock Divider
Divides the 100MHz system clock to produce a 4ms tick (250Hz) by counting 400,000 clock cycles. Drives the 7-segment scanning loop.

### `counter.vhd` — Digit Select Counter
3-bit counter incrementing on the 4ms tick, cycling through digits 0–4 (5 digits: ones, tens, hundreds, thousands, sign). Resets to zero after reaching 4.

### `DAnC.vhd` — Anode Controller
Decodes the 3-bit digit select signal to an 8-bit active-low anode enable vector, activating one 7-segment digit at a time for the multiplexed scanning display.

### `mux.vhd` — Display Digit Multiplexer
Routes the correct BCD digit (ones, tens, hundreds, thousands, or sign) to the 7-segment decoder based on the current digit select value. Outputs minus sign code when sign is negative, blank otherwise.

---

## Features

- **Live 3-axis accelerometer data** read over SPI from ADXL362 at 200Hz sample rate
- **32-sample hardware averaging** for noise reduction, computed from two consecutive 16-sample averages
- **Signed decimal display** of 12-bit two's complement values on 5-digit 7-segment display with sign digit
- **Switch override mode**: SW15 routes SW[11:0] directly to the display for manual input
- **Axis selection**: SW14 and SW13 select which axis (X, Y, Z) is displayed in accelerometer mode
- **RGB LED orientation indicator**: LED colour reflects board tilt based on averaged X, Y, Z values
- **Fully structural top-level** with clearly defined component interfaces
- **Comprehensive testbench** for `bin2BCD` covering positive values, negative values, zero, and boundary cases

---

## Toolchain

| Tool | Version |
|------|---------|
| Vivado | 2023.2 |
| Target Device | XC7A100T-1CSG324C |
| Board | Nexys-A7 100T |
| Language | VHDL-93 |

---

## Repository Structure

```
├── src/
│   ├── display.vhd          # Top-level structural module
│   ├── bin2BCD.vhd          # 12-bit signed binary to BCD converter
│   ├── bin2seg.vhd          # BCD to 7-segment decoder
│   ├── clock.vhd            # 4ms tick clock divider
│   ├── counter.vhd          # Digit select counter
│   ├── DAnC.vhd             # Anode controller
│   ├── mux.vhd              # Display digit multiplexer
│   ├── input_select.vhd     # Switch / accelerometer input mux
│   ├── ACC_XYZ.vhd          # Accelerometer wrapper with reset
│   ├── ADXL362Ctrl.vhd      # ADXL362 SPI controller and averager
│   ├── SPI_If.vhd           # SPI interface controller
│   └── avg32_from_avg16.vhd # 32-sample averager
└── testbench/
    └── bin2BCD_tb.vhd       # Testbench for BCD conversion component
```

---

## How to Run

1. Open Vivado 2023.2 and create a new project targeting the XC7A100T-1CSG324C device
2. Add all `.vhd` files from `src/` as design sources
3. Add `bin2BCD_tb.vhd` as a simulation source
4. Set `display.vhd` as the top-level module
5. Add the Nexys-A7 constraints file (`.xdc`) with appropriate pin assignments
6. Run Synthesis, Implementation, and Generate Bitstream
7. Program the board via JTAG
