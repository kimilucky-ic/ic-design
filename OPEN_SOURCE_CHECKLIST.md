# Open-source release checklist

## Functional

- [x] Preserve the competition baseline separately
- [x] Compile the FPGA top-level with the UART module
- [x] Pass a standalone UART byte test
- [x] Add a UART ready/busy status interface
- [ ] Add a buffered UART path for software output
- [x] Add a CPU MMIO UART test program
- [x] Run CoreMark on remote FPGA (separate CoreMark top/ROM; rounded reference score)
- [x] Package the exact CoreMark ELF-to-ROM path, EEMBC source notices, FPGA wrapper, clock constraint, and PDS build script
- [x] Include the prebuilt CoreMark bitstream and sanitized timing summary
- [x] Verify archived CoreMark ELF regenerates the committed ROM byte-for-byte
- [ ] Establish a clean source-to-identical-ELF firmware rebuild and link the exact programmed bitstream hash to a fresh board run
- [x] Capture real FPGA UART output (dedicated smoke-test image; exact image/hash linkage still pending)
- [ ] Capture real ILA waveforms
- [x] Archive a sanitized CoreMark-top timing summary (27 MHz constraint met; zero setup/hold failing endpoints)

## Verification

- [x] Assert x0-x31 in the directed RV32I regression
- [x] Repair stale expectations and malformed branch/store encodings in `tb_top.v`
- [x] Add focused forwarding, load-use, branch-flush, and jump tests
- [x] Add and run a one-command six-test regression (`sim/run_regression.ps1`); all six emitted their expected PASS markers on 2026-09-28

## Release hygiene

- [x] Add ignore rules for simulator work libraries, generated PDS output, logs, and local environment files
- [x] Verify the exact GitHub upload/staging file list (73 files staged locally; simulator work libraries are ignored)
- [ ] Remove competition-only files and credentials
- [x] Identify upstream RISC-V_CPU source and preserve its historical MIT license
- [x] Include CoreMark upstream source subset and its complete EEMBC license/acceptable-use terms
- [ ] Finish review of all remaining third-party benchmark/tool references and competition-derived material
- [ ] Confirm publication permission for competition-derived material
- [x] Include the complete historical upstream MIT license and attribution
- [x] Acknowledge AI-assisted development separately from legal copyright ownership
- [ ] Add the names/roles of human project contributors
- [ ] Tag the first reproducible public release
