# CoreMark on XiaoYanjin RISC-V

This is a first-class benchmark package for the Logos2 PG2L200H build. The archived remote serial transcripts include a 2026-09-28 run that stated `Correct operation validated`, with 1000 iterations in about 52 seconds (19 iterations/second as displayed). Dividing the displayed integer rate by the 27 MHz clock gives approximately 0.70 CoreMark/MHz; this is a rounded reference, not a precision score. The user-provided transcript is fragmented and does not identify the programmed bitstream by hash.

## What is included

- The EEMBC CoreMark source files used by this firmware, pinned to upstream commit [`1f483d5`](https://github.com/eembc/coremark/tree/1f483d5b8316753a742cbf5590caf5bd0a4e4777), with its original `LICENSE.md`.
- XiaoYanjin's PG2L200H port sources, startup/linker inputs, and the fixed performance ELF/HEX image.
- The ROM generator and the exact generated `coremark_rom.v` used by the FPGA build.
- The dedicated FPGA wrapper, 27 MHz timing constraint, and a PDS Tcl build script using this repository's CPU RTL.
- The later prebuilt `fpga_top_coremark.sbit` (PDS build time 2026-09-26 15:57:35) for convenience and a sanitized PDS timing summary.
- `firmware/pg2l200h/verify_rom.ps1` checks that the archived ELF regenerates the committed ROM byte-for-byte.

## Reproduce the image inputs

From the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File benchmarks/coremark/firmware/pg2l200h/verify_rom.ps1
```

For an FPGA build, create/open a Logos2 PG2L200H PDS project for the release candidate and run `benchmarks/coremark/run_coremark_clocked.tcl`. The script selects `fpga_top_coremark`, the candidate CPU modules, the checked-in ROM, the board pin constraints, and the 27 MHz clock constraint. The prebuilt `.sbit` is the output artifact from the preserved PDS build; a new build requires the vendor tool. Programming an image and capturing a fresh UART run should record the `.sbit` SHA-256 before upload.

## Evidence boundary

The preserved serial output and build artifacts support a CoreMark run on the same CPU RTL revision. The later packaged bitstream was generated after the earlier saved image and has matching candidate CPU RTL and ROM, but the historical serial capture is fragmented and does not contain a bitstream hash. We therefore cannot claim that this exact later `.sbit` produced that transcript. This is strong board-run evidence plus an exact firmware-ELF-to-ROM reproduction and FPGA build package, but not yet a fully hash-linked rerun from a clean checkout. The original fixed ELF is archived so its ROM output can be reproduced exactly; a clean source-to-identical-ELF rebuild has not yet been established.

The upstream CoreMark sources remain under EEMBC's supplied license and notices; XiaoYanjin-specific PG2L200H porting code is identified separately. Keep benchmark source changes out of the upstream CoreMark files. Review `upstream/LICENSE.md` before redistribution. CoreMark is an EEMBC trademark; use the name only to identify the benchmark and its results in accordance with the official terms.
