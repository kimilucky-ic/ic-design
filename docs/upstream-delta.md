# Upstream attribution and project contributions

## Upstream source and license

This project derives its five-stage RV32I core from [Arjun P Shetty's RISC-V_CPU](https://github.com/ArjunPShetty/RISC-V_CPU), specifically the historical RISC-V RTL at commit [`7e6f4af`](https://github.com/ArjunPShetty/Floating_Point_ALU_using_IEEE-754/tree/7e6f4af), dated 2026-01-24. The old repository URL currently redirects to a differently named repository. The historical snapshot already contained the MIT license when the RISC-V RTL was added. The complete historical license text, including the upstream contribution sentence, is preserved in the root [`LICENSE`](../LICENSE).

The following local files are byte-for-byte identical to the corresponding files in that upstream snapshot:

- `source/common/config.v`
- `source/common/defines.v`
- `source/decode/decoder.v`
- `source/execution/alu.v`

Other compared pipeline/core files differ from the upstream snapshot and contain subsequent edits. Preserve the upstream copyright and permission notice; do not present inherited upstream code as original team work.

## Verified project changes

Compared with upstream commit `7e6f4af`, the current release candidate includes these changes and additions:

- Pipeline and decode fixes: decoded source/destination/immediate fields are connected through the CPU pipeline; branch `funct3` values are mapped to the internal branch encodings; LUI/AUIPC handling and link-value writeback are corrected; and fetch stalls/branch flushes are connected to hazard control.
- Memory and register-file behavior: byte/halfword store lanes are formed for the enabled write strobes; load-use hazards are tested; and same-cycle register-file write-through avoids stale source operands.
- FPGA/board integration: a PG2L200H top level connects the CPU, on-chip memories, LED activity indication, and UART transmitter. UART MMIO uses `0x1000_0000` for transmit and `0x1000_0004` for busy status. The transmitter has no FIFO, so software must poll/pace writes.
- Verification: directed tests check architectural register results, branch fall-through, a CPU-to-UART string, and a CPU load-use UART marker. The suite is useful evidence but is not the official `riscv-tests` compliance suite.
- Build/release tooling: one-command ModelSim regression scripts, FPGA pin constraints, and release hygiene documentation were added.

## Board-result boundary

The CoreMark result is from a separate build with `fpga_top_coremark` and a CoreMark ROM, not this repository's default top-level and test ROM. The CPU core source revision and UART transmitter match this candidate, but the special wrapper, memory map/ROM image, and exact programmed bitstream are not included. See [BOARD_TEST_REPORT.md](../BOARD_TEST_REPORT.md). Do not describe the result as a repeatable benchmark of the default release image.

## Acknowledgement

The project team continued the upstream design through debugging, FPGA integration, directed tests, and remote-board work. AI assistance supported debugging, verification planning, and documentation; architectural choices, hardware integration, board programming, and result confirmation were carried out by the project team. AI is acknowledged as a collaboration tool, not named as a legal copyright holder.
