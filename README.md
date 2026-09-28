# XiaoYanjin RISC-V CPU

A five-stage RV32I RISC-V CPU developed for learning, simulation, and FPGA experimentation.

The project includes directed tests for arithmetic, branches, jumps, byte/halfword/word memory access, forwarding, load-use hazards, and UART output. On the 27 MHz Logos2 PG2L200H remote FPGA, a CoreMark run reported 1,000 iterations at 19 iterations/second and printed `Correct operation validated`; the displayed integer rate corresponds to approximately 0.70 CoreMark/MHz. This is an approximate result, and the archived serial transcript does not identify the programmed bitstream by hash, so it is not a hash-linked score for the packaged bitstream.

## Current status

This repository is a release candidate for a five-stage RV32I CPU derived from Arjun P Shetty's MIT-licensed RISC-V_CPU project. See [the upstream and change record](docs/upstream-delta.md) and [LICENSE](LICENSE).

- Five-stage pipeline: IF / ID / EX / MEM / WB
- Directed RV32I ModelSim regression with architectural assertions for x0-x31
- Directed coverage includes arithmetic, logic, shifts, branches, jumps, byte/half/word memory operations, RAW forwarding, and load-use stalls
- UART TX MMIO path: implemented and integrated
- UART standalone simulation: PASS
- CPU-to-MMIO-to-UART integration simulation: PASS for complete `RV32I_CPU_OK` string
- CoreMark: remote PG2L200H transcripts reported `Correct operation validated`, including a 2026-09-28 rerun with 1000 iterations, about 52 seconds and 19 iterations/sec. Using the displayed integer rate and 27 MHz clock gives approximately 0.70 CoreMark/MHz. The dedicated CoreMark top-level, fixed ELF-to-ROM inputs, ROM generator, 27 MHz constraint, PDS flow, prebuilt `.sbit`, and sanitized PNR timing summary are packaged under [benchmarks/coremark](benchmarks/coremark/README.md). The serial capture still lacks an exact programmed-bitstream hash link, and a clean source-to-identical-ELF rebuild remains unverified.
- FPGA UART smoke test: `RV32I_CPU_OK` was observed from a dedicated image. The exact bitstream hash is not archived, so this does not establish that the current release-candidate image was programmed.
- Real ILA capture: pending
- Timing report: pending

## UART interface

The top-level FPGA design maps the UART transmitter and status register to:

```text
UART_TX_ADDR = 0x1000_0000
```

A byte written to this address is sent through `uart_tx`. A busy status register is available, but there is no transmit FIFO. The board smoke test uses a dedicated paced program and is not evidence of CoreMark-ready throughput.

## Reproducibility

The simulation scripts use ModelSim and run without the original competition build artifacts.

Relevant entry points:

- `sim/run_regression.ps1` — runs six directed regressions: architectural state, UART byte TX, UART MMIO, CPU UART string, RV32I UART, and load-use UART
- `benchmarks/coremark/firmware/pg2l200h/verify_rom.ps1` — verifies the archived firmware ELF regenerates the committed FPGA ROM exactly
- `benchmarks/coremark/run_coremark_clocked.tcl` — PDS build flow for the dedicated 27 MHz CoreMark FPGA top
- `sim/run_sim.do` — CPU core simulation
- `sim/run_fpga_sim.do` — FPGA top-level simulation
- `sim/run_uart_tx.do` — UART unit simulation
- `sim/tb_uart_tx.v` — UART byte-level test

On Windows with ModelSim installed, run `powershell -ExecutionPolicy Bypass -File sim/run_regression.ps1`. If ModelSim is installed elsewhere, set `MODELSIM_BIN` or pass `-ModelSim`.

## Scope and publication notes

The core is modified from the upstream RISC-V_CPU project. Its historical source snapshot carried MIT terms; preserve the complete upstream notice in this repository. The project team added FPGA/Logos2 integration, UART MMIO, fixes, tests, and board verification; see [the change record](docs/upstream-delta.md).

AI assistance was used for debugging, test planning, verification, and release documentation. The project team made design decisions, integrated the hardware, programmed the remote board, and confirmed the observed results. AI is acknowledged as a development tool/collaborator, not named as a legal copyright holder.

Before public release, confirm team authorization for newly added work and publication rights for competition-derived materials. Do not upload vendor libraries, generated implementation work, credentials, or private platform files.
